import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final String? mask; // Adicionando a máscara como um parâmetro opcional

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.mask, // Adicionando a máscara como um parâmetro opcional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaskTextInputFormatter? maskFormatter;
    if (mask != null) {
      maskFormatter = MaskTextInputFormatter(mask: mask!, filter: {"#": RegExp(r'[0-9]')});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.blue),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          inputFormatters: mask != null ? [maskFormatter!] : null, // Aplicar a máscara se fornecida
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(255, 229, 229, 229),
            hintStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w400),
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
