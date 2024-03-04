// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomMultiSelectDropdown<T> extends StatefulWidget {
  final String? hintText;
  final String? labelText; // Nova propriedade para o rótulo
  final List<T>? items;
  final List<T>? selectedItems;
  final Function(List<T>)? onSelectionChanged;
  final ButtonStyleData buttonStyleData;
  final MenuItemStyleData menuItemStyleData;
  final double itemHeight;

  const CustomMultiSelectDropdown({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
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
            menuItemStyleData ?? const MenuItemStyleData(height: 40),
        super(key: key);

  @override
  _CustomMultiSelectDropdownState<T> createState() =>
      _CustomMultiSelectDropdownState<T>();
}

class _CustomMultiSelectDropdownState<T>
    extends State<CustomMultiSelectDropdown<T>> {
  List<T> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedItems ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Text(
              widget.labelText!,
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
              widget.hintText ?? 'Selecione o Item',
              style: TextStyle(
                fontSize: 15.5,
                color: Theme.of(context).hintColor,
              ),
            ),
            items: widget.items
                    ?.map((T item) => DropdownMenuItem<T>(
                          value: item,
                          child: StatefulBuilder(
                            builder: (context, menuSetState) {
                              final isSelected = _selectedItems.contains(item);
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    isSelected
                                        ? _selectedItems.remove(item)
                                        : _selectedItems.add(item);
                                  });
                                  widget.onSelectionChanged
                                      ?.call(_selectedItems);
                                  menuSetState(() {});
                                },
                                child: Container(
                                  height: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30.0),
                                  child: Row(
                                    children: [
                                      if (isSelected)
                                        const Icon(Icons.check_box_outlined)
                                      else
                                        const Icon(
                                            Icons.check_box_outline_blank),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          item.toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                    .toList() ??
                [],
            onChanged: (value) {},
            buttonStyleData: widget.buttonStyleData,
            menuItemStyleData: widget.menuItemStyleData,
          ),
        ),
      ],
    );
  }
}
