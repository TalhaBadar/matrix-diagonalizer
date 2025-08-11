import 'package:flutter/material.dart';
import 'dart:math';

class VectorCheckScreen extends StatefulWidget {
  @override
  _VectorCheckScreenState createState() => _VectorCheckScreenState();
}

class _VectorCheckScreenState extends State<VectorCheckScreen> {
  int numVectors = 2;
  int vectorSize = 3;
  late List<List<TextEditingController>> controllers;
  String result = '';

  final List<String> subscriptMap = ['₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈'];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    controllers = List.generate(
      numVectors,
      (_) => List.generate(vectorSize, (_) => TextEditingController()),
    );
  }

  void _checkVectors() {
    List<List<double>> vectors = controllers.map((row) {
      return row.map((controller) {
        return double.tryParse(controller.text.trim()) ?? 0.0;
      }).toList();
    }).toList();

    bool isOrthogonal = true;
    bool isOrthonormal = true;

    for (int i = 0; i < vectors.length; i++) {
      if ((_magnitude(vectors[i]) - 1).abs() > 1e-4) {
        isOrthonormal = false;
      }
      for (int j = i + 1; j < vectors.length; j++) {
        double dot = _dotProduct(vectors[i], vectors[j]);
        if (dot.abs() > 1e-4) {
          isOrthogonal = false;
        }
      }
    }

    String status = '';
    if (isOrthogonal && isOrthonormal) {
      status = '✅ Vectors are orthonormal';
    } else if (isOrthogonal) {
      status = '✅ Vectors are orthogonal but not orthonormal';
    } else {
      status = '❌ Vectors are not orthogonal';
    }

    setState(() {
      result = status;
    });
  }

  double _dotProduct(List<double> a, List<double> b) {
    return List.generate(a.length, (i) => a[i] * b[i]).reduce((x, y) => x + y);
  }

  double _magnitude(List<double> v) {
    return sqrt(v.map((e) => e * e).reduce((x, y) => x + y));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vector Check',
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
                  "Vectors: ",
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButton<int>(
                  value: numVectors,
                  items: List.generate(6, (i) => i + 2)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (val) => setState(() {
                    numVectors = val!;
                    _initControllers();
                    result = '';
                  }),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Dimensions: ",
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButton<int>(
                  value: vectorSize,
                  items: List.generate(6, (i) => i + 2)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                  onChanged: (val) => setState(() {
                    vectorSize = val!;
                    _initControllers();
                    result = '';
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(numVectors, (i) {
                String label =
                    'v${i + 1 <= subscriptMap.length ? subscriptMap[i] : i + 1}';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(vectorSize, (j) {
                          return Container(
                            width: 70,
                            margin: const EdgeInsets.all(5),
                            child: TextField(
                              controller: controllers[i][j],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                labelText: 'x${j + 1}',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkVectors,
              child: const Text(
                'Check Orthogonality',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SelectableText(result, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
