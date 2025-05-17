import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.deepPurple.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.deepPurple.shade200,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.deepPurple.shade200,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.deepPurple,
              width: 1.2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
      home: CurrencyConverterPage(),
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final List<String> currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK', 'NOK'
  ];

  String fromCurrency = 'EUR';
  String toCurrency = 'USD';
  double? rate;
  double amount = 1.0;
  bool isLoading = false;
  final TextEditingController amountController = TextEditingController(text: '1');

  Future<void> fetchExchangeRate() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      'https://api.frankfurter.app/latest?amount=$amount&from=$fromCurrency&to=$toCurrency',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rate = (data['rates'][toCurrency] as num).toDouble();
        });
      } else {
        throw Exception('Failed to load exchange rate');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching rate: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateAmount(String value) {
    setState(() {
      amount = double.tryParse(value) ?? 1.0;
    });
    fetchExchangeRate();
  }

  @override
  void initState() {
    super.initState();
    fetchExchangeRate();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Colors.deepPurple.shade50;
    final textColor = Colors.deepPurple.shade900;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Text('💱 Currency Converter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchExchangeRate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount input
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: updateAmount,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.money),
              ),
            ),
            SizedBox(height: 20),

            // From currency dropdown
            buildDropdown('From', fromCurrency, (val) {
              setState(() => fromCurrency = val);
              fetchExchangeRate();
            }),

            SizedBox(height: 16),

            // To currency dropdown
            buildDropdown('To', toCurrency, (val) {
              setState(() => toCurrency = val);
              fetchExchangeRate();
            }),

            SizedBox(height: 40),

            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : rate != null
                      ? Column(
                          children: [
                            Text(
                              '$amount $fromCurrency =',
                              style: TextStyle(fontSize: 20, color: textColor),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${rate!.toStringAsFixed(2)} $toCurrency',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        )
                      : Text('No data 😕'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown(String label, String value, ValueChanged<String> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade200,
          width: 1.0,
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down),
        underline: SizedBox(),
        dropdownColor: Colors.white,
        onChanged: (newValue) => onChanged(newValue!),
        items: currencies.map((code) {
          return DropdownMenuItem(
            value: code,
            child: Text('$label: $code'),
          );
        }).toList(),
      ),
    );
  }
}
