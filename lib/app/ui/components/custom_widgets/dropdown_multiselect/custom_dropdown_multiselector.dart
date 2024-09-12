import 'package:flutter/material.dart';

class MultiSelectDropdownWidget<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) displayItem;
  final Function(List<T>) onSelectionChanged;
  List<T>? selectedItems;

  MultiSelectDropdownWidget(
      {required this.items,
      required this.displayItem,
      required this.onSelectionChanged,
      this.selectedItems});

  @override
  _MultiSelectDropdownWidgetState<T> createState() =>
      _MultiSelectDropdownWidgetState<T>();
}

class _MultiSelectDropdownWidgetState<T>
    extends State<MultiSelectDropdownWidget<T>> {
  List<T> selectedItems = [];
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedItems != null) {
      setState(() {
        selectedItems = List.from(widget.selectedItems!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        children: [
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              "Seleccionar todo",
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12),
            ),
            value: selectAll,
            onChanged: (bool? value) {
              setState(() {
                selectAll = value!;
                if (selectAll) {
                  selectedItems = List.from(widget.items);
                } else {
                  selectedItems.clear();
                }
              });
              widget.onSelectionChanged(selectedItems);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final displayText = widget.displayItem(item);
                  return Center(
                    child: Container(
                      height: 50,
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          displayText,
                          style: TextStyle(fontSize: 12),
                        ),
                        value: selectedItems.contains(item),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected!) {
                              selectedItems.add(item);
                            } else {
                              selectedItems.remove(item);
                            }
                            selectAll =
                                selectedItems.length == widget.items.length;
                          });
                          widget.onSelectionChanged(selectedItems);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
