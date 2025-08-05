import 'package:flutter/material.dart';

class ColumnSpaceBasisPage extends StatefulWidget {
  @override
  State<ColumnSpaceBasisPage> createState() => _ColumnSpaceBasisPageState();
}

class _ColumnSpaceBasisPageState extends State<ColumnSpaceBasisPage> {
  int rows = 5;
  int cols = 3;
  List<List<TextEditingController>> controllers = [];

  String result = "";

  @override
  void initState() {
    super.initState();
    _generateControllers();
  }

  void _generateControllers() {
    controllers = List.generate(
      rows,
      (_) => List.generate(cols, (_) => TextEditingController()),
    );
  }

  bool _validateInputs() {
    for (var row in controllers) {
      for (var c in row) {
        if (c.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please fill in all matrix fields.")),
          );
          return false;
        }
      }
    }
    return true;
  }

  void computeBasis() {
    List<List<double>> A = controllers
        .map<List<double>>(
          (row) => row
              .map<double>(
                (c) =>
                    double.tryParse(c.text.trim()) ??
                    0.0, // defaults to 0 if null/invalid
              )
              .toList(),
        )
        .toList();

    List<List<double>> reduced = _rowReduce(A);

    List<List<double>> basis = [];
    for (int col = 0; col < cols; col++) {
      bool isPivot = reduced.any((row) => row[col].abs() > 1e-6);
      if (isPivot) {
        basis.add([for (var row in A) row[col]]);
      }
    }

    setState(() {
      result = "Basis vectors:\n" + basis.map((v) => v.toString()).join("\n");
    });
  }

  List<List<double>> _rowReduce(List<List<double>> matrix) {
    List<List<double>> m = matrix
        .map<List<double>>((r) => List<double>.from(r))
        .toList();

    int lead = 0;
    for (int r = 0; r < m.length; r++) {
      if (lead >= m[0].length) return m;
      int i = r;
      while (m[i][lead] == 0) {
        i++;
        if (i == m.length) {
          i = r;
          lead++;
          if (lead == m[0].length) return m;
        }
      }

      var temp = m[r];
      m[r] = m[i];
      m[i] = temp;

      double lv = m[r][lead];
      m[r] = m[r].map((e) => e / lv).toList();

      for (int i = 0; i < m.length; i++) {
        if (i != r) {
          double lv = m[i][lead];
          for (int j = 0; j < m[0].length; j++) {
            m[i][j] -= lv * m[r][j];
          }
        }
      }
      lead++;
    }

    return m;
  }

  @override
  Widget build(BuildContext context) {
    final subscriptMap = ['₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          "Column Space Basis",
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
                Text("Rows: ", style: TextStyle(fontFamily: 'Urbanist')),
                DropdownButton<int>(
                  value: rows,
                  items: List.generate(6, (i) => i + 2)
                      .map((v) => DropdownMenuItem(value: v, child: Text("$v")))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      rows = val!;
                      _generateControllers();
                      result = "";
                    });
                  },
                ),
                Text("   Columns: ", style: TextStyle(fontFamily: 'Urbanist')),
                DropdownButton<int>(
                  value: cols,
                  items: List.generate(5, (i) => i + 2)
                      .map((v) => DropdownMenuItem(value: v, child: Text("$v")))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      cols = val!;
                      _generateControllers();
                      result = "";
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            ...List.generate(rows, (i) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(cols, (j) {
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
              onPressed: computeBasis,
              child: Text(
                "Compute Basis",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(result),
          ],
        ),
      ),
    );
  }
}
