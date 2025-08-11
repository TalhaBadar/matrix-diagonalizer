import 'package:Linearcraze/advancedtools.dart';
import 'package:Linearcraze/diagonalizability_checker.dart';
import 'package:Linearcraze/orthogonality_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:Linearcraze/eigen_screen.dart';
import 'package:Linearcraze/gaussian_screen.dart';
import 'column_space_basis.dart';

void main() {
  runApp(MatrixMathApp());
}

class MatrixMathApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix Math App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Matrix Math App',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            Container(
              height: 56,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GaussianEliminationPage()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Gaussian Elimination ",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 56,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ColumnSpaceBasisPage()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Column Space Basis ",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 56,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EigenCalculatorPage()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Eigenvalues & Eigenspace ",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 56,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DiagonalizabilityChecker()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Diagnolizeable Check!",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 56,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrthogonalityMenuScreen()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Orthogonality Tools!",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 56,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdvancedTools()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Advanced Tools!",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Application by Talha Badar",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
