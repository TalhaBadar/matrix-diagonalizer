import 'package:flutter/material.dart';
import 'dart:math';

class QRDecompositionScreen extends StatefulWidget {
  @override
  _QRDecompositionScreenState createState() => _QRDecompositionScreenState();
}

class _QRDecompositionScreenState extends State<QRDecompositionScreen> {
  int rows = 3, cols = 3;
  late List<List<TextEditingController>> controllers;
  List<List<double>>? Q, R;

  final List<int> sizeOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    controllers = List.generate(
      rows,
      (_) => List.generate(cols, (_) => TextEditingController()),
    );
  }

  void _updateMatrixSize() {
    setState(() {
      _initControllers();
      Q = null;
      R = null;
    });
  }

  List<List<double>> _getMatrix() {
    return List.generate(
      rows,
      (i) => List.generate(
        cols,
        (j) => double.tryParse(controllers[i][j].text) ?? 0.0,
      ),
    );
  }

  void _computeQR() {
    final A = _getMatrix();
    final m = A.length;
    final n = A[0].length;

    // Check if m >= n, otherwise QR is not defined the same way
    if (m < n) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Number of rows should be >= number of columns'),
        ),
      );
      return;
    }

    List<List<double>> Q = List.generate(m, (_) => List.filled(n, 0));
    List<List<double>> R = List.generate(n, (_) => List.filled(n, 0));

    for (int k = 0; k < n; k++) {
      for (int i = 0; i < m; i++) {
        Q[i][k] = A[i][k];
      }

      for (int j = 0; j < k; j++) {
        double r = 0;
        for (int i = 0; i < m; i++) r += Q[i][j] * A[i][k];
        R[j][k] = r;
        for (int i = 0; i < m; i++) Q[i][k] -= r * Q[i][j];
      }

      double norm = sqrt(
        Q.map((row) => row[k] * row[k]).reduce((a, b) => a + b),
      );

      if (norm == 0) {
        // Avoid division by zero if the column is zero vector
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Column $k leads to zero vector during QR decomposition',
            ),
          ),
        );
        return;
      }

      R[k][k] = norm;
      for (int i = 0; i < m; i++) Q[i][k] /= norm;
    }

    setState(() {
      this.Q = Q;
      this.R = R;
    });
  }

  Widget _matrixDisplay(String label, List<List<double>> matrix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
        ...matrix.map(
          (row) => Text(
            '[${row.map((v) => v.toStringAsFixed(3)).join(', ')}]',
            style: const TextStyle(fontFamily: 'Urbanist'),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  void dispose() {
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'QR Decomposition',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Set Matrix Size:',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: rows,
                  decoration: const InputDecoration(
                    labelText: 'Rows',
                    border: OutlineInputBorder(),
                  ),
                  items: sizeOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      rows = value!;
                      _updateMatrixSize();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: cols,
                  decoration: const InputDecoration(
                    labelText: 'Columns',
                    border: OutlineInputBorder(),
                  ),
                  items: sizeOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      cols = value!;
                      _updateMatrixSize();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Enter Matrix:',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            children: List.generate(
              rows,
              (i) => Row(
                children: List.generate(
                  cols,
                  (j) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      child: TextField(
                        controller: controllers[i][j],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _computeQR,
            child: const Text(
              'Compute QR',
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (Q != null && R != null) ...[
            _matrixDisplay('Q', Q!),
            _matrixDisplay('R', R!),
          ],
        ],
      ),
    );
  }
}
