// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class ClubSpeedContainer extends StatelessWidget {
  final double value;
  final String label;
  final String unit;

  const ClubSpeedContainer({
    super.key,
    required this.value,
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Enhanced gradient background
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A), 
            Color(0xFF1F1F1F), 
            Color(0xFF252525), 
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),

        border: GradientBoxBorder(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(255, 255, 255, 0.3),
              Color.fromRGBO(255, 255, 255, 0.05), 
              Color.fromRGBO(255, 255, 255, 0.0), 
              Color.fromRGBO(255, 255, 255, 0.15), 
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
          width: 1.2,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
                fontFamily: GoogleFonts.oswald().fontFamily,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Label with better styling
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
                fontFamily: GoogleFonts.roboto().fontFamily,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),
            Text(
              unit,
              style: TextStyle(
                fontSize: 11,
                fontFamily: GoogleFonts.roboto().fontFamily,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
                height: 1.0,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
