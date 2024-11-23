import 'package:flutter/material.dart';

class OptionsWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const OptionsWidget({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: brightness == Brightness.dark
                ? Colors.grey[850]  
                : Colors.white,  
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: brightness == Brightness.dark
                    ? Colors.black38 
                    : const Color(0x3416202A),  
                offset: const Offset(0.0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            shape: BoxShape.rectangle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: brightness == Brightness.dark
                      ? Colors.white  
                      : Colors.black,  
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                        color: brightness == Brightness.dark
                            ? Colors.white  
                            : Colors.black,  
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0.9, 0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: brightness == Brightness.dark
                        ? Colors.white  
                        : Colors.black,  
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
