// ignore_for_file: deprecated_member_use, unused_element_parameter

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slurvo_task/controllers/home_controller.dart';
import 'package:slurvo_task/screens/home.dart';
import 'package:slurvo_task/widget/common_image_view_widget.dart';

class BtmNavBar extends StatefulWidget {
  const BtmNavBar({super.key});

  @override
  State<BtmNavBar> createState() => _BtmNavBarState();
}

class _BtmNavBarState extends State<BtmNavBar> with TickerProviderStateMixin {
  final List<Widget> screens = [
    const HomeScreen(),
    const HomeScreen(),
    const HomeScreen(),
    const HomeScreen(),
  ];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cont = Get.put<HomeController>(HomeController());
    return Scaffold(
      body: GetBuilder<HomeController>(
        builder: (home) {
          return screens[home.selectedIndex];
        },
      ),
      bottomNavigationBar: GetBuilder<HomeController>(
        builder: (home) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ Color(0xFF1A1A1A), Color(0xFF1F1F1F)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withOpacity(0.5),
                selectedLabelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: GoogleFonts.roboto().fontFamily,
                  height: 1.2,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.5),
                  fontFamily: GoogleFonts.roboto().fontFamily,
                  height: 1.2,
                ),
                elevation: 0,
                items: [
                  _buildNavItem(
                    iconPath: "assets/home.png",
                    label: 'Home',
                    isSelected: home.selectedIndex == 0,
                  ),
                  _buildNavItem(
                    iconPath: "assets/golf.png",
                    label: 'Shot Analysis',
                    isSelected: home.selectedIndex == 1,
                  ),
                  _buildNavItem(
                    iconPath: "assets/joystick.png",
                    label: 'Practice games',
                    isSelected: home.selectedIndex == 2,
                  ),
                  _buildNavItem(
                    iconPath: "assets/folder.png",
                    label: 'Shot Library',
                    isSelected: home.selectedIndex == 3,
                  ),
                ],
                currentIndex: home.selectedIndex,
                onTap: (index) {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  home.onItemTapped(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required String iconPath,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(isSelected ? 8 : 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
              : null,
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: CommonImageView(
            fit: BoxFit.contain,
            assetImageColor: isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            height: 22,
            width: 22,
            imagePath: iconPath,
          ),
        ),
      ),
      label: label,
    );
  }
}

class _SvgIcon extends StatelessWidget {
  final String? svgIconOutline, svgIconFill;
  final bool selectedColor;
  const _SvgIcon({
    this.svgIconOutline,
    this.selectedColor = false,
    this.svgIconFill,
  });

  @override
  Widget build(BuildContext context) {
    return CommonImageView(
      svgPath: (selectedColor) ? svgIconFill : svgIconOutline,
      // svgIconColor: (selectedColor) ? kSecondaryColor : kQuaternaryColor,
    );
  }
}
