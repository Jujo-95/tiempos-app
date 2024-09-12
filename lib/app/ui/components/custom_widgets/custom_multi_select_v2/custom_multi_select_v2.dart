import 'package:flutter/material.dart';

class MultiSelector<T> extends StatefulWidget {
  final List<T> itemsFuture;
  final String Function(T) displayItem;
  final Function(List<T>) onSelectItem;
  List<T>? initialSelectedItems = [];
  bool? clearItems;
  final Function(bool) resetClearBool;

  MultiSelector(
      {required this.itemsFuture,
      required this.displayItem,
      required this.onSelectItem,
      this.initialSelectedItems,
      this.clearItems,
      required this.resetClearBool});

  @override
  _MultiSelectorState<T> createState() => _MultiSelectorState<T>();

  static Widget emptyCheckBox() => CheckboxListTile(
        title: Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          width: 50,
          height: 20,
        ),
        enabled: false,
        value: false,
        onChanged: (value) {},
      );
}

class _MultiSelectorState<T> extends State<MultiSelector<T>> {
  List<T> selectedItems = [];
  late List<T> _itemsFuture;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _itemsFuture = widget.itemsFuture;
    selectedItems = widget.initialSelectedItems!;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.itemsFuture.length + 1, //_itemsFuture.length,
        itemBuilder: (context, index) {
          // createSelectAll
          if (index == 0) {
            return CheckboxListTile(
              value: _selectAll,
              title: Text('Seleccionar todo'),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedItems.clear();
                    selectedItems.addAll(widget.itemsFuture);
                    _selectAll = true;
                  } else {
                    selectedItems.clear();
                    _selectAll = false;
                  }
                  widget.onSelectItem(selectedItems);
                });
              },
            );
          } else {
            index = index - 1;
            T item = widget.itemsFuture[index]; //_itemsFuture[index];
            bool isSelected = selectedItems.contains(item);
            return CheckboxListTile(
              title: Text(widget.displayItem(item)),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (widget.clearItems!) {
                    selectedItems.clear();
                    widget.resetClearBool(false);
                  }
                  if (value == true) {
                    selectedItems.add(item);
                    if (selectedItems.length == _itemsFuture.length) {
                      _selectAll = true;
                    }
                  } else {
                    selectedItems.remove(item);
                    _selectAll = false;
                  }
                });

                widget.onSelectItem(selectedItems);
              },
            );
          }
        },
      ),
    );
  }
}
