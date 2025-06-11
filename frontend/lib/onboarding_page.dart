import 'package:flutter/material.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA87EDD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/skill.png', width: 247, height: 325),
            const SizedBox(height: 20),
            const Text(
              '"Learn. Grow. Level Up."',
              style: TextStyle(
                fontFamily: 'Jersey15',
                fontSize: 40,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 60),
            CustomButton(
              label: 'Get Started',
              onTap: () {
                Navigator.pushNamed(context, '/signup');
              },
            ),
          ],
        ),
      ),
    );
  }
}
