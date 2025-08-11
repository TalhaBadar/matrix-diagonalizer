import 'package:flutter/material.dart';
import 'dart:math';

class OrthonormalizationScreen extends StatefulWidget {
  @override
  _OrthonormalizationScreenState createState() =>
      _OrthonormalizationScreenState();
}

class _OrthonormalizationScreenState extends State<OrthonormalizationScreen> {
  int numVectors = 2;
  int vectorSize = 3;
  late List<List<TextEditingController>> controllers;
  String result = '';

  final subscriptMap = ['₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈'];

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

  List<List<double>> _getVectors() {
    return List.generate(
      numVectors,
      (i) => List.generate(
        vectorSize,
        (j) => double.tryParse(controllers[i][j].text.trim()) ?? 0.0,
      ),
    );
  }

  List<List<double>> _gramSchmidtNormalized(List<List<double>> vectors) {
    List<List<double>> ortho = [];

    for (var v in vectors) {
      List<double> w = List.from(v);
      for (var u in ortho) {
        double dotVU = _dot(v, u);
        double dotUU = _dot(u, u);
        for (int i = 0; i < w.length; i++) {
          w[i] -= dotVU / dotUU * u[i];
        }
      }
      double norm = _magnitude(w);
      if (norm != 0) {
        for (int i = 0; i < w.length; i++) {
          w[i] /= norm;
        }
      }
      ortho.add(w);
    }

    return ortho;
  }

  double _dot(List<double> a, List<double> b) {
    return List.generate(a.length, (i) => a[i] * b[i]).reduce((x, y) => x + y);
  }

  double _magnitude(List<double> v) {
    return sqrt(v.map((e) => e * e).reduce((x, y) => x + y));
  }

  void _orthonormalize() {
    List<List<double>> vectors = _getVectors();
    List<List<double>> ortho = _gramSchmidtNormalized(vectors);

    String display = '';
    for (int i = 0; i < ortho.length; i++) {
      display +=
          'u${i + 1 <= subscriptMap.length ? subscriptMap[i] : i + 1} = [${ortho[i].map((e) => e.toStringAsFixed(2)).join(', ')}]\n';
    }

    setState(() {
      result = display;
    });
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
          'Orthonormalization',
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
              onPressed: _orthonormalize,
              child: const Text(
                'Orthonormalize',
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
