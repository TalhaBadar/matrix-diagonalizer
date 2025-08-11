import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JordanFormScreen extends StatefulWidget {
  @override
  _JordanFormScreenState createState() => _JordanFormScreenState();
}

class _JordanFormScreenState extends State<JordanFormScreen> {
  int size = 2;
  late List<List<TextEditingController>> controllers;
  String result = '';
  bool isLoading = false;
  List<List<double>>? _jordanMatrix;
  List<List<double>>? _pMatrix;
  List<List<double>>? _aMatrix;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    controllers = List.generate(
      size,
      (_) => List.generate(size, (_) => TextEditingController()),
    );
  }

  void _updateSize(int newSize) {
    setState(() {
      size = newSize;
      _initControllers();
      result = '';
    });
  }

  List<List<double>> _getMatrix() {
    return List.generate(
      size,
      (i) => List.generate(
        size,
        (j) => double.tryParse(controllers[i][j].text.trim()) ?? 0.0,
      ),
    );
  }

  Future<void> _getJordanForm() async {
    setState(() {
      isLoading = true;
      result = '';
    });

    // 🔌 Internet check
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() => isLoading = false);
      _showNoInternetDialog();
      return;
    }

    try {
      final lookup = await InternetAddress.lookup('example.com');
      if (lookup.isEmpty || lookup[0].rawAddress.isEmpty) {
        setState(() => isLoading = false);
        _showNoInternetDialog();
        return;
      }
    } on SocketException {
      setState(() => isLoading = false);
      _showNoInternetDialog();
      return;
    }

    List<List<double>> matrix = _getMatrix();

    try {
      final response = await http.post(
        Uri.parse(
          'https://diagonalizer-api-production-0743.up.railway.app/jordan_form',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'matrix': matrix}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jordan = (data['jordan'] as List)
            .map<List<double>>((row) => List<double>.from(row))
            .toList();
        final p = (data['P'] as List)
            .map<List<double>>((row) => List<double>.from(row))
            .toList();
        final aReconstructed = (data['A_reconstructed'] as List)
            .map<List<double>>((row) => List<double>.from(row))
            .toList();

        setState(() {
          result = ''; // We'll use widgets instead
          _jordanMatrix = jordan;
          _pMatrix = p;
          _aMatrix = aReconstructed;
        });
      } else {
        setState(() {
          result = '❌ Server Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        result = '⚠️ Error: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'No Internet',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Please connect to WiFi or mobile data and try again',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  final List<String> subscriptMap = ['₁', '₂', '₃', '₄', '₅', '₆'];

  @override
  void dispose() {
    for (var row in controllers) {
      for (var c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jordan Canonical Form',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Matrix size: ',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<int>(
                  value: size,
                  items: List.generate(4, (i) => i + 2)
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e, child: Text('$e × $e')),
                      )
                      .toList(),
                  onChanged: (val) => _updateSize(val!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(size, (i) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(size, (j) {
                      String label = j < subscriptMap.length
                          ? 'x${subscriptMap[j]}'
                          : 'x$j';
                      return Container(
                        width: 70,
                        margin: const EdgeInsets.all(5),
                        child: TextField(
                          controller: controllers[i][j],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: label,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _getJordanForm,
              child: const Text(
                'Compute Jordan Form',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            else ...[
              if (_jordanMatrix != null)
                buildMatrix(
                  _jordanMatrix!,
                  title: '📌 Jordan Canonical Form (J)',
                ),
              const SizedBox(height: 20),
              if (_pMatrix != null)
                buildMatrix(_pMatrix!, title: '🔁 Transformation Matrix (P)'),
              const SizedBox(height: 20),
              if (_aMatrix != null)
                buildMatrix(
                  _aMatrix!,
                  title: '🧠 Reconstructed Matrix A = P × J × P⁻¹',
                ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget buildMatrix(List<List<double>> matrix, {String? title}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Urbanist',
            ),
          ),
        ),
      Table(
        border: TableBorder.all(color: Colors.grey),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: matrix
            .map(
              (row) => TableRow(
                children: row
                    .map(
                      (val) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          val.toStringAsFixed(3),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      ),
    ],
  );
}
