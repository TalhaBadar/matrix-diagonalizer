import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(MaterialApp(home: DiagonalizabilityChecker()));
}

class DiagonalizabilityChecker extends StatefulWidget {
  @override
  _DiagonalizabilityCheckerState createState() =>
      _DiagonalizabilityCheckerState();
}

class _DiagonalizabilityCheckerState extends State<DiagonalizabilityChecker> {
  int size = 2;
  List<List<TextEditingController>> controllers = [];
  Map<String, dynamic>? lastResult;

  @override
  void initState() {
    super.initState();
    initControllers();
  }

  void initControllers() {
    controllers = List.generate(
      size,
      (i) => List.generate(size, (j) => TextEditingController()),
    );
  }

  void updateSize(int newSize) {
    setState(() {
      size = newSize;
      initControllers();
    });
  }

  Future<void> saveMatrixHistory(List<List<double>> matrix) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> flat = matrix
        .expand((row) => row.map((e) => e.toString()))
        .toList();
    prefs.setStringList('matrix_history', flat);
  }

  Future<List<List<double>>> loadLastMatrix() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? saved = prefs.getStringList('matrix_history');
    if (saved == null) return [];
    int n = sqrt(saved.length).toInt();
    return List.generate(
      n,
      (i) => List.generate(n, (j) => double.parse(saved[i * n + j])),
    );
  }

  Future<void> checkMatrix() async {
    List<List<double>> matrix = List.generate(
      size,
      (i) => List.generate(
        size,
        (j) => double.tryParse(controllers[i][j].text) ?? 0,
      ),
    );

    final response = await http.post(
      Uri.parse('http://192.168.1.9:5000/check'), // change IP here
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'matrix': matrix}),
    );

    final Map<String, dynamic> json = jsonDecode(response.body);

    setState(() {
      lastResult = json;
    });

    await saveMatrixHistory(matrix);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(json['result']),
        content: json['result'] == 'Diagonalizable'
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Text('P Matrix:'),
                    _matrixWidget(json['P']),
                    SizedBox(height: 10),
                    Text('D Matrix:'),
                    _matrixWidget(json['D']),
                    SizedBox(height: 10),
                    Text('P⁻¹ Matrix:'),
                    _matrixWidget(json['P_inv']),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        exportToPdf(
                          'Diagonalizable',
                          json['P'],
                          json['D'],
                          json['P_inv'],
                        );
                      },
                      child: Text("Download PDF"),
                    ),
                  ],
                ),
              )
            : Text(json['error'] ?? 'Matrix is not diagonalizable'),
      ),
    );
  }

  void exportToPdf(
    String result,
    List<dynamic>? p,
    List<dynamic>? d,
    List<dynamic>? pInv,
  ) {
    final pdf = pw.Document();

    pw.Table matrixTable(List<dynamic> matrix) {
      return pw.Table.fromTextArray(
        data: matrix
            .map<List<String>>((row) => row.map((e) => e.toString()).toList())
            .toList(),
        cellAlignment: pw.Alignment.center,
      );
    }

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Matrix Diagonalization Result',
              style: pw.TextStyle(fontSize: 24),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Status: $result', style: pw.TextStyle(fontSize: 18)),

            if (result == 'Diagonalizable') ...[
              pw.SizedBox(height: 16),
              pw.Text('Matrix P:', style: pw.TextStyle(fontSize: 16)),
              matrixTable(p!),

              pw.SizedBox(height: 16),
              pw.Text('Matrix D:', style: pw.TextStyle(fontSize: 16)),
              matrixTable(d!),

              pw.SizedBox(height: 16),
              pw.Text('Matrix P⁻¹:', style: pw.TextStyle(fontSize: 16)),
              matrixTable(pInv!),
            ],
          ],
        ),
      ),
    );

    Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Widget _matrixWidget(List<dynamic> matrix) {
    return Column(
      children: matrix.map<Widget>((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (row as List<dynamic>).map<Widget>((item) {
            return Container(
              margin: EdgeInsets.all(4),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(item.toString(), style: TextStyle(fontSize: 14)),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diagonalizability Checker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<int>(
              value: size,
              items: [2, 3]
                  .map(
                    (n) => DropdownMenuItem(value: n, child: Text('${n}x$n')),
                  )
                  .toList(),
              onChanged: (val) => updateSize(val!),
            ),
            SizedBox(height: 16),
            Column(
              children: List.generate(size, (i) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(size, (j) {
                    return Container(
                      width: 60,
                      margin: EdgeInsets.all(4),
                      child: TextField(
                        controller: controllers[i][j],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d*'),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: checkMatrix, child: Text("Check")),
          ],
        ),
      ),
    );
  }
}
