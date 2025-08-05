import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:io'; // for InternetAddress.lookup

import 'package:http/http.dart' as http;

class DiagonalizabilityChecker extends StatefulWidget {
  @override
  _DiagonalizabilityCheckerState createState() =>
      _DiagonalizabilityCheckerState();
}

class _DiagonalizabilityCheckerState extends State<DiagonalizabilityChecker> {
  int size = 2;
  late List<List<TextEditingController>> controllers;
  String result = '';
  bool isLoading = false;

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

  Future<void> _checkDiagonalizability() async {
    setState(() {
      isLoading = true;
      result = '';
    });
    // ✅ Check internet connection first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isLoading = false;
      });
      _showNoInternetDialog();
      return;
    }
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        setState(() {
          isLoading = false;
        });
        _showNoInternetDialog();
        return;
      }
    } on SocketException catch (_) {
      setState(() {
        isLoading = false;
      });
      _showNoInternetDialog();
      return;
    }

    List<List<double>> matrix = _getMatrix();

    try {
      final response = await http.post(
        Uri.parse(
          'https://diagonalizer-api-production-0743.up.railway.app/check_diagonalizable',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'matrix': matrix}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isDiag = data['is_diagonalizable'];
        final eigenvalues = (data['eigenvalues'] as List)
            .map((e) => (e as num).toDouble().toStringAsFixed(4))
            .toList();
        final independent = data['total_independent_vectors'];

        setState(() {
          result =
              (isDiag
                  ? '✅ Matrix IS diagonalizable'
                  : '❌ Matrix is NOT diagonalizable') +
              '\n\nEigenvalues: ${eigenvalues.join(', ')}\n' +
              'Independent eigenvectors: $independent / $size';
        });
      } else {
        setState(() {
          result = '⚠️ Server error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        result = '⚠️ Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'No Internet',
          style: TextStyle(
            fontSize: 17,
            color: Colors.black,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Please connect to WiFi or mobile data and try again',
          style: TextStyle(fontFamily: 'Urbanist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return;
  }

  @override
  void dispose() {
    for (var row in controllers) {
      for (var c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  final List<String> subscriptMap = ['₁', '₂', '₃', '₄', '₅', '₆'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Diagonalizability Checker',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  items: List.generate(5, (i) => i + 2)
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
              onPressed: isLoading ? null : _checkDiagonalizability,
              child: const Text(
                'Check Diagonalizability',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            else
              SelectableText(result, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
