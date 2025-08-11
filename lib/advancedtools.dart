import 'package:Linearcraze/jordan_form_screen.dart';
import 'package:Linearcraze/qr_decomposition_screen.dart';
import 'package:flutter/material.dart';

class AdvancedTools extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Advanced Tools',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  MaterialPageRoute(builder: (_) => QRDecompositionScreen()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Qr Decompositon!",
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
                  MaterialPageRoute(builder: (_) => JordanFormScreen()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Jordan Canonical Form",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
