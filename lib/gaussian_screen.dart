import 'package:flutter/material.dart';

class GaussianEliminationPage extends StatefulWidget {
  @override
  State<GaussianEliminationPage> createState() =>
      _GaussianEliminationPageState();
}

class _GaussianEliminationPageState extends State<GaussianEliminationPage> {
  int size = 3; // number of variables
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
      (_) => List.generate(size + 1, (_) => TextEditingController()),
    );
  }

  void solve() {
    List<List<double>> matrix = controllers
        .map((row) => row.map((c) => double.tryParse(c.text) ?? 0).toList())
        .toList();

    int n = matrix.length;

    // Gaussian elimination
    for (int i = 0; i < n; i++) {
      double diag = matrix[i][i];
      if (diag == 0) continue;
      for (int j = 0; j <= n; j++) matrix[i][j] /= diag;

      for (int k = 0; k < n; k++) {
        if (k != i) {
          double factor = matrix[k][i];
          for (int j = 0; j <= n; j++) {
            matrix[k][j] -= factor * matrix[i][j];
          }
        }
      }
    }

    setState(() {
      result = List.generate(
        n,
        (i) => "x${i + 1} = ${matrix[i][n].toStringAsFixed(2)}",
      ).join('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptMap = ['₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          "Gaussian Elimination",
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
                  "Number of variables: ",
                  style: TextStyle(fontFamily: 'Urbanist'),
                ),
                DropdownButton<int>(
                  value: size,
                  items: [2, 3, 4]
                      .map(
                        (val) =>
                            DropdownMenuItem(value: val, child: Text("$val")),
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

            ...List.generate(size, (i) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(size + 1, (j) {
                    String label;
                    if (j < size) {
                      // Use x₁, x₂, x₃ with subscripts
                      label = 'x${subscriptMap[j]}';
                    } else {
                      label = '=';
                    }

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
              onPressed: solve,
              child: Text(
                "Solve",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(result, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
