import 'package:flutter/material.dart';

class Inputwidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?) validator;

  const Inputwidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
      child: Container(
        width: 370,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          autofillHints: [AutofillHints.email],
          obscureText: false,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              letterSpacing: 0.0,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black, 
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black54, 
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.blue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.redAccent
                    : Colors.red, 
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.redAccent
                    : Colors.red, 
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black87
                : Colors.white, 
          ),
          style: TextStyle(
            fontFamily: 'Inter',
            letterSpacing: 0.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black, 
          ),
          keyboardType: TextInputType.emailAddress,
          validator: validator,
        ),
      ),
    );
  }
}
