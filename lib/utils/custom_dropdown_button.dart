import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final String? hintText;
  final String? labelText; 
  final List<T>? items;
  final T? value;
  final Function(T?)? onChanged;
  final ButtonStyleData buttonStyleData;
  final MenuItemStyleData menuItemStyleData;
  final double itemHeight;

  const CustomDropdownButton({
    super.key,
    required this.items,
    required this.onChanged,
    required this.value,
    this.hintText,
    this.labelText,
    ButtonStyleData? buttonStyleData,
    MenuItemStyleData? menuItemStyleData,
    this.itemHeight = 40,
  })  : buttonStyleData = buttonStyleData ??
            const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 229, 229, 229),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
        menuItemStyleData =
            menuItemStyleData ?? const MenuItemStyleData(height: 40);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Text(
              labelText!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue
              ),
            ),
          ),
        DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            hint: Text(
              hintText ?? 'Selecione o Item',
              style: TextStyle(
                fontSize: 15.5,
                color: Theme.of(context).hintColor,
              ),
            ),
            items: items
                    ?.map((T item) => DropdownMenuItem<T>(
                          value: item,
                          child: Text(
                            item.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList() ??
                [],
            value: value,
            onChanged: onChanged,
            buttonStyleData: buttonStyleData,
            menuItemStyleData: menuItemStyleData,
          ),
        ),
      ],
    );
  }
}
