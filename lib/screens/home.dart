// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:slurvo_task/utls/constants.dart';
import 'package:slurvo_task/widget/common_image_view_widget.dart';
import 'package:slurvo_task/widget/custom_app_bar_widget.dart';
import 'package:slurvo_task/widget/my_text_widget.dart';
import 'package:slurvo_task/widgets/data_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions safely
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: logoAppBar(false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),

              // Header Row with better alignment
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: MyText(
                        text: "Shot Analysis",
                        size: 24,
                        weight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36), // Balance the back arrow
                ],
              ),

              SizedBox(height: screenHeight * 0.04),

              // Customize Container with enhanced styling
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(50),
                  border: const GradientBoxBorder(
                    gradient: LinearGradient(
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
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: "Customize",
                      textAlign: TextAlign.center,
                      color: Colors.white,
                      weight: FontWeight.w600,
                      size: 16,
                    ),
                     CommonImageView(
                      height: 20,
                      width: 20,
                      fit: BoxFit.contain,
                      assetImageColor: Colors.white,
                      imagePath: "assets/control.png",
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Enhanced Grid with better styling and null safety
              _buildMetricsGrid(),

              SizedBox(height: screenHeight * 0.04),

              // Enhanced Button Row
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      text: "Delete Shot",
                      onTap: () {},
                      screenWidth: screenWidth,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      text: "Dispersion",
                      icon: "assets/bullseye.png",
                      onTap: () {},
                      screenWidth: screenWidth,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // Session View Button
              _buildActionButton(
                text: "Session View",
                isFullWidth: true,
                onTap: () {},
                screenWidth: screenWidth,
              ),

              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    // Add null safety check for metrics
    if (metrics.isEmpty) {
      return Container(
        height: 200,
        child: const Center(
          child: Text(
            'No metrics available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        // Add bounds checking
        if (index >= metrics.length) {
          return const SizedBox.shrink();
        }
        
        final metric = metrics[index];
        
        // Add null safety checks for metric data
        final value = metric['value'];
        final label = metric['label'];
        final unit = metric['unit'];
        
        // Validate data types and provide defaults
        if (value == null || label == null || unit == null) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Invalid data',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return ClubSpeedContainer(
          value: _safeToDouble(value),
          label: label.toString(),
          unit: unit.toString(),
        );
      },
    );
  }

  // Safe conversion to double with fallback
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    
    return 0.0;
  }

  Widget _buildActionButton({
    required String text,
    String? icon,
    bool isFullWidth = false,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return Container(
      width: isFullWidth ? screenWidth : null,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   CommonImageView(
                    imagePath: "assets/bullseye.png", // Use const string
                    height: 20, 
                    width: 20
                  ),
                  const SizedBox(width: 10),
                  MyText(
                    text: text,
                    fontFamily: GoogleFonts.roboto().fontFamily,
                    color: Colors.black,
                    weight: FontWeight.w600,
                    size: 16,
                  ),
                ],
              )
            : MyText(
                text: text,
                color: Colors.black,
                weight: FontWeight.w600,
                size: 16,
              ),
      ),
    );
  }
}