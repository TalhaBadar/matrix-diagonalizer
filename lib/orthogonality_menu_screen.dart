import 'package:Linearcraze/orthogonality/orthogonalization_screen.dart';
import 'package:Linearcraze/orthogonality/orthonormalization_screen.dart';
import 'package:Linearcraze/orthogonality/vector_check_screen.dart';
import 'package:flutter/material.dart';

class OrthogonalityMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          'Orthogonality Tools',
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
                  MaterialPageRoute(builder: (_) => OrthogonalizationScreen()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Orthogonalization",
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
                  MaterialPageRoute(builder: (_) => OrthonormalizationScreen()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Orthonormalization",
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
                  MaterialPageRoute(builder: (_) => VectorCheckScreen()),
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                child: const Text(
                  "Check Vectors",
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
