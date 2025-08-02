import 'package:flutter/material.dart';
import 'package:slurvo_task/widget/my_text_widget.dart';

// ignore: must_be_immutable
class MyTextField extends StatelessWidget {
  MyTextField({
    Key? key,
    this.controller,
    this.hint,
    this.label,
    this.onChanged,
    this.isObSecure = false,
    this.marginBottom = 16.0,
    this.maxLines = 1,
    this.labelSize,
    this.prefix,
    this.suffix,
    this.isReadOnly,
    this.validator,
    this.onTap,
  }) : super(key: key);

  String? label, hint;
  TextEditingController? controller;
  ValueChanged<String>? onChanged;
  bool? isObSecure, isReadOnly;
  double? marginBottom;
  int? maxLines;
  double? labelSize;
  Widget? prefix, suffix;
  final VoidCallback? onTap;
  String? Function(String?)? validator;
  Color? hintColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            MyText(
              text: label ?? '',
              size: labelSize ?? 12,
              paddingBottom: 6,
              weight: FontWeight.w500,
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TextFormField(
              onTap: onTap,
              textAlignVertical: prefix != null || suffix != null
                  ? TextAlignVertical.center
                  : null,
              validator: validator,
              maxLines: maxLines,
              readOnly: isReadOnly ?? false,
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.next,
              obscureText: isObSecure!,
              obscuringCharacter: '*',
              style: TextStyle(
                fontSize: 12,
              ),
              decoration: InputDecoration(
                filled: true,
                prefixIcon: prefix,
                suffixIcon: suffix,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: maxLines! > 1 ? 15 : 0,
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: hintColor,
                ),
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff333333),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff333333),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
