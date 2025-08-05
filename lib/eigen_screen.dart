import 'dart:math';

import 'package:flutter/material.dart';

class EigenCalculatorPage extends StatefulWidget {
  @override
  State<EigenCalculatorPage> createState() => _EigenCalculatorPageState();
}

class _EigenCalculatorPageState extends State<EigenCalculatorPage> {
  int size = 3;
  List<List<TextEditingController>> controllers = [];

  String result = "";

  @override
  void initState() {
    super.initState();
    _generateControllers();
  }

  void _generateControllers() {
    controllers = List.generate(
      size,
      (_) => List.generate(size, (_) => TextEditingController()),
    );
  }

  void calculateEigenValues() {
    if (size != 2 && size != 3) {
      setState(() {
        result = "Eigenvalue support currently limited to 2x2 and 3x3.";
      });
      return;
    }

    List<List<double>> A = controllers
        .map((row) => row.map((c) => double.tryParse(c.text) ?? 0).toList())
        .toList();

    if (size == 2) {
      double trace = A[0][0] + A[1][1];
      double det = A[0][0] * A[1][1] - A[0][1] * A[1][0];
      double discriminant = trace * trace - 4 * det;

      if (discriminant >= 0) {
        double sqrtD = sqrt(discriminant);
        double lambda1 = (trace + sqrtD) / 2;
        double lambda2 = (trace - sqrtD) / 2;

        result =
            "Eigenvalues:\nλ1 = ${lambda1.toStringAsFixed(2)}\nλ2 = ${lambda2.toStringAsFixed(2)}";
      } else {
        result = "Complex eigenvalues not supported in this version.";
      }
    } else {
      // 3x3: just output characteristic polynomial
      double a = 1;
      double b = -(A[0][0] + A[1][1] + A[2][2]);
      double c =
          A[0][0] * A[1][1] +
          A[0][0] * A[2][2] +
          A[1][1] * A[2][2] -
          A[0][1] * A[1][0] -
          A[0][2] * A[2][0] -
          A[1][2] * A[2][1];
      double d = -_det3x3(A);

      result =
          "Characteristic polynomial:\nλ³ + (${b.toStringAsFixed(2)})λ² + (${c.toStringAsFixed(2)})λ + (${d.toStringAsFixed(2)})";
    }

    setState(() {});
  }

  double _det3x3(List<List<double>> m) {
    return m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
        m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
        m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
  }

  @override
  Widget build(BuildContext context) {
    final subscriptMap = ['₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          "Eigenvalue Calculator",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Matrix size: ",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<int>(
                  value: size,
                  items: [2, 3]
                      .map(
                        (val) => DropdownMenuItem(
                          value: val,
                          child: Text("${val}x$val"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      size = val!;
                      _generateControllers();
                      result = "";
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            ...List.generate(size, (i) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(size, (j) {
                    String label = j < subscriptMap.length
                        ? 'x${subscriptMap[j]}'
                        : 'x$j';

                    return Container(
                      width: 75,
                      margin: EdgeInsets.all(5),
                      child: TextField(
                        controller: controllers[i][j],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: label,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: calculateEigenValues,
              child: Text(
                "Calculate",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(result),
          ],
        ),
      ),
    );
  }
}
