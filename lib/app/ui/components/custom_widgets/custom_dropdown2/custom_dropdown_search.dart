library dropdown_search;

import 'dart:async';

import 'src/properties/icon_button_props.dart';
import 'src/properties/selection_list_view_props.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/modal_dialog.dart';
import 'src/popupMenu.dart';
import 'src/properties/popup_safearea_props.dart';
import 'src/properties/scrollbar_props.dart';
import 'src/properties/text_field_props.dart';
import 'src/selection_widget.dart';

export 'src/properties/icon_button_props.dart';
export 'src/properties/popup_safearea_props.dart';
export 'src/properties/scrollbar_props.dart';
export 'src/properties/selection_list_view_props.dart';
export 'src/properties/text_field_props.dart';

typedef CustomDropdownSearchOnFind<T> = Future<List<T>> Function(String? text);
typedef CustomDropdownSearchItemAsString<T> = String Function(T? item);
typedef CustomDropdownSearchFilterFn<T> = bool Function(T? item, String? filter);
typedef CustomDropdownSearchCompareFn<T> = bool Function(T? item, T? selectedItem);
typedef CustomDropdownSearchBuilder<T> = Widget Function(
    BuildContext context, T? selectedItem);
typedef CustomDropdownSearchBuilderMultiSelection<T> = Widget Function(
    BuildContext context, List<T> selectedItems);
typedef CustomDropdownSearchPopupItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool isSelected,
);
typedef CustomDropdownSearchPopupItemEnabled<T> = bool Function(T item);
typedef ErrorBuilder<T> = Widget Function(
    BuildContext context, String? searchEntry, dynamic exception);
typedef EmptyBuilder<T> = Widget Function(BuildContext context, String? searchEntry);
typedef LoadingBuilder<T> = Widget Function(BuildContext context, String? searchEntry);
typedef BeforeChange<T> = Future<bool?> Function(T? prevItem, T? nextItem);
typedef BeforeChangeMultiSelection<T> = Future<bool?> Function(
    List<T> prevItems, List<T> nextItems);
typedef FavoriteItemsBuilder<T> = Widget Function(
    BuildContext context, T item, bool isSelected);
typedef ValidationMultiSelectionBuilder<T> = Widget Function(
    BuildContext context, List<T> item);

typedef PositionCallback = RelativeRect Function(
    RenderBox popupButtonObject, RenderBox overlay);

typedef OnItemAdded<T> = void Function(List<T> selectedItems, T addedItem);
typedef OnItemRemoved<T> = void Function(List<T> selectedItems, T removedItem);

///[items] are the original item from [items] or/and [onFind]
typedef FavoriteItems<T> = List<T> Function(List<T> items);

enum Mode { DIALOG, BOTTOM_SHEET, MENU }

class CustomDropdownSearch<T> extends StatefulWidget {
  ///show/hide the search box
  final bool showSearchBox;

  ///true if the filter on items is applied onlie (via API)
  final bool isFilteredOnline;

  ///show/hide clear selected item
  final bool showClearButton;

  ///offline items list
  final List<T>? items;

  ///selected item
  final T? selectedItem;

  ///selected items
  final List<T> selectedItems;

  ///function that returns item from API
  final CustomDropdownSearchOnFind<T>? onFind;

  ///called when a new item is selected
  final ValueChanged<T?>? onChanged;

  ///called when a new items are selected
  final ValueChanged<List<T>>? onChangedMultiSelection;

  ///to customize list of items UI
  final CustomDropdownSearchBuilder<T>? dropdownBuilder;

  ///to customize list of items UI in MultiSelection mode
  final CustomDropdownSearchBuilderMultiSelection<T>?
      dropdownBuilderMultiSelection;

  ///to customize selected item
  final CustomDropdownSearchPopupItemBuilder<T>? popupItemBuilder;

  ///the title for dialog/menu/bottomSheet
  final Color? popupBackgroundColor;

  ///custom widget for the popup title
  final Widget? popupTitle;

  ///customize the fields the be shown
  final CustomDropdownSearchItemAsString<T>? itemAsString;

  ///	custom filter function
  final CustomDropdownSearchFilterFn<T>? filterFn;

  ///enable/disable dropdownSearch
  final bool enabled;

  ///MENU / DIALOG/ BOTTOM_SHEET
  final Mode mode;

  ///the max height for dialog/bottomSheet/Menu
  final double? maxHeight;

  ///the max width for the dialog
  final double? dialogMaxWidth;

  ///select the selected item in the menu/dialog/bottomSheet of items
  final bool showSelectedItems;

  ///function that compares two object with the same type to detected if it's the selected item or not
  final CustomDropdownSearchCompareFn<T>? compareFn;

  ///dropdownSearch input decoration
  final InputDecoration? dropdownSearchDecoration;

  /// style on which to base the label
  final TextStyle? dropdownSearchBaseStyle;

  /// How the text in the decoration should be aligned horizontally.
  final TextAlign? dropdownSearchTextAlign;

  /// How the text should be aligned vertically.
  final TextAlignVertical? dropdownSearchTextAlignVertical;

  ///custom layout for empty results
  final EmptyBuilder? emptyBuilder;

  ///custom layout for loading items
  final LoadingBuilder? loadingBuilder;

  ///custom layout for error
  final ErrorBuilder? errorBuilder;

  ///custom shape for the popup
  final ShapeBorder? popupShape;

  final AutovalidateMode? autoValidateMode;

  /// An optional method to call with the final value when the form is saved via
  final FormFieldSetter<T>? onSaved;

  /// An optional method to call with the final value when the form is saved via
  final FormFieldSetter<List<T>>? onSavedMultiSelection;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  final FormFieldValidator<T>? validator;
  final FormFieldValidator<List<T>>? validatorMultiSelection;

  ///If true, the dropdownBuilder will continue the uses of material behavior
  ///This will be useful if you want to handle a custom UI only if the item !=null
  final bool dropdownBuilderSupportsNullItem;

  ///defines if an item of the popup is enabled or not, if the item is disabled,
  ///it cannot be clicked
  final CustomDropdownSearchPopupItemEnabled<T>? popupItemDisabled;

  ///set a custom color for the popup barrier
  final Color? popupBarrierColor;

  ///called when popup is dismissed
  final VoidCallback? onPopupDismissed;

  /// callback executed before applying value change
  ///delay before searching, change it to Duration(milliseconds: 0)
  ///if you do not use online search
  final Duration? searchDelay;

  /// callback executed before applying value change
  final BeforeChange<T>? onBeforeChange;

  /// callback executed before applying values changes
  final BeforeChangeMultiSelection<T>? onBeforeChangeMultiSelection;

  ///show or hide favorites items
  final bool showFavoriteItems;

  ///to customize favorites chips
  final FavoriteItemsBuilder<T>? favoriteItemBuilder;

  ///favorites items list
  final FavoriteItems<T>? favoriteItems;

  ///favorite items alignment
  final MainAxisAlignment? favoriteItemsAlignment;

  ///set properties of popup safe area
  final PopupSafeAreaProps popupSafeArea;

  /// object that passes all props to search field
  final TextFieldProps? searchFieldProps;

  /// scrollbar properties
  final ScrollbarProps? scrollbarProps;

  /// whether modal can be dismissed by tapping the modal barrier
  final bool popupBarrierDismissible;

  ///define whatever we are in multi selection mode or single selection mode
  final bool isMultiSelectionMode;

  ///called when a new item added on Multi selection mode
  final OnItemAdded<T>? popupOnItemAdded;

  ///called when a new item added on Multi selection mode
  final OnItemRemoved<T>? popupOnItemRemoved;

  ///widget used to show checked items in multiSelection mode
  final CustomDropdownSearchPopupItemBuilder<T>? popupSelectionWidget;

  ///widget used to validate items in multiSelection mode
  final ValidationMultiSelectionBuilder<T>? popupValidationMultiSelectionWidget;

  ///widget to add custom widget like addAll/removeAll on popup multi selection mode
  final ValidationMultiSelectionBuilder<T>? popupCustomMultiSelectionWidget;

  /// elevation for popup items
  final double popupElevation;

  /// props for selection list view
  final SelectionListViewProps selectionListViewProps;

  /// props for selection focus node
  final FocusNode? focusNode;

  /// function to override position calculation
  final PositionCallback? positionCallback;

  ///custom dropdown clear button icon properties
  final IconButtonProps? clearButtonProps;

  ///custom dropdown icon button properties
  final IconButtonProps? dropdownButtonProps;

  const CustomDropdownSearch({
    Key? key,
    this.onSaved,
    this.validator,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.onChanged,
    this.mode = Mode.DIALOG,
    this.isFilteredOnline = false,
    this.popupTitle,
    this.items,
    this.selectedItem,
    this.onFind,
    this.dropdownBuilder,
    this.popupItemBuilder,
    this.clearButtonProps,
    this.showSearchBox = false,
    this.showClearButton = false,
    this.popupBackgroundColor,
    this.enabled = true,
    this.maxHeight,
    this.filterFn,
    this.itemAsString,
    this.showSelectedItems = false,
    this.compareFn,
    this.dropdownSearchDecoration,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.dialogMaxWidth,
    this.dropdownBuilderSupportsNullItem = false,
    this.popupShape,
    this.popupItemDisabled,
    this.popupBarrierColor,
    this.onPopupDismissed,
    this.dropdownButtonProps,
    this.searchDelay,
    this.onBeforeChange,
    this.favoriteItemBuilder,
    this.favoriteItems,
    this.showFavoriteItems = false,
    this.favoriteItemsAlignment = MainAxisAlignment.start,
    this.popupSafeArea = const PopupSafeAreaProps(),
    TextFieldProps? searchFieldProps,
    this.scrollbarProps,
    this.popupBarrierDismissible = true,
    this.dropdownSearchBaseStyle,
    this.dropdownSearchTextAlign,
    this.dropdownSearchTextAlignVertical,
    this.popupElevation = 8,
    this.selectionListViewProps = const SelectionListViewProps(),
    this.focusNode,
    this.positionCallback,
  })  : assert(!showSelectedItems || T == String || compareFn != null),
        searchFieldProps = searchFieldProps ?? const TextFieldProps(),
        isMultiSelectionMode = false,
        dropdownBuilderMultiSelection = null,
        validatorMultiSelection = null,
        onBeforeChangeMultiSelection = null,
        selectedItems = const [],
        onSavedMultiSelection = null,
        onChangedMultiSelection = null,
        popupOnItemAdded = null,
        popupOnItemRemoved = null,
        popupSelectionWidget = null,
        popupValidationMultiSelectionWidget = null,
        popupCustomMultiSelectionWidget = null,
        super(key: key);

  const CustomDropdownSearch.multiSelection({
    Key? key,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.mode = Mode.DIALOG,
    this.isFilteredOnline = false,
    this.popupTitle,
    this.items,
    this.onFind,
    this.popupItemBuilder,
    this.showSearchBox = false,
    this.showClearButton = false,
    this.popupBackgroundColor,
    this.clearButtonProps,
    this.enabled = true,
    this.maxHeight,
    this.filterFn,
    this.itemAsString,
    this.showSelectedItems = false,
    this.compareFn,
    this.dropdownSearchDecoration,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.dropdownButtonProps,
    this.dialogMaxWidth,
    this.dropdownBuilderSupportsNullItem = false,
    this.popupShape,
    this.popupItemDisabled,
    this.popupBarrierColor,
    this.onPopupDismissed,
    this.searchDelay,
    this.favoriteItemBuilder,
    this.favoriteItems,
    this.showFavoriteItems = false,
    this.favoriteItemsAlignment = MainAxisAlignment.start,
    this.popupSafeArea = const PopupSafeAreaProps(),
    TextFieldProps? searchFieldProps,
    this.scrollbarProps,
    this.popupBarrierDismissible = true,
    this.dropdownSearchBaseStyle,
    this.dropdownSearchTextAlign,
    this.dropdownSearchTextAlignVertical,
    this.selectedItems = const [],
    FormFieldSetter<List<T>>? onSaved,
    ValueChanged<List<T>>? onChanged,
    BeforeChangeMultiSelection<T>? onBeforeChange,
    FormFieldValidator<List<T>>? validator,
    CustomDropdownSearchBuilderMultiSelection<T>? dropdownBuilder,
    this.popupOnItemAdded,
    this.popupOnItemRemoved,
    this.popupSelectionWidget,
    this.popupValidationMultiSelectionWidget,
    this.popupCustomMultiSelectionWidget,
    this.popupElevation = 8,
    this.selectionListViewProps = const SelectionListViewProps(),
    this.focusNode,
    this.positionCallback,
  })  : assert(!showSelectedItems || T == String || compareFn != null),
        searchFieldProps = searchFieldProps ?? const TextFieldProps(),
        onChangedMultiSelection = onChanged,
        onSavedMultiSelection = onSaved,
        onBeforeChangeMultiSelection = onBeforeChange,
        validatorMultiSelection = validator,
        dropdownBuilderMultiSelection = dropdownBuilder,
        isMultiSelectionMode = true,
        dropdownBuilder = null,
        validator = null,
        onBeforeChange = null,
        selectedItem = null,
        onSaved = null,
        onChanged = null,
        super(key: key);

  @override
  CustomDropdownSearchState<T> createState() => CustomDropdownSearchState<T>();
}

class CustomDropdownSearchState<T> extends State<CustomDropdownSearch<T>> {
  final ValueNotifier<List<T>> _selectedItemsNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _isFocused = ValueNotifier(false);
  final _popupStateKey = GlobalKey<SelectionWidgetState<T>>();

  @override
  void initState() {
    super.initState();
    _selectedItemsNotifier.value = isMultiSelectionMode
        ? List.from(widget.selectedItems)
        : _itemToList(widget.selectedItem);
  }

  @override
  void didUpdateWidget(CustomDropdownSearch<T> oldWidget) {
    List<T> oldSelectedItems = isMultiSelectionMode
        ? oldWidget.selectedItems
        : _itemToList(oldWidget.selectedItem);

    List<T> newSelectedItems = isMultiSelectionMode
        ? widget.selectedItems
        : _itemToList(widget.selectedItem);

    if (!listEquals(oldSelectedItems, newSelectedItems)) {
      _selectedItemsNotifier.value = List.from(newSelectedItems);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<T?>>(
      valueListenable: _selectedItemsNotifier,
      builder: (context, data, wt) {
        return IgnorePointer(
          ignoring: !widget.enabled,
          child: InkWell(
            onTap: () => _selectSearchMode(),
            child: _formField(),
          ),
        );
      },
    );
  }

  List<T> _itemToList(T? item) {
    List<T?> nullableList = List.filled(1, item);
    return nullableList.whereType<T>().toList();
  }

  Widget _defaultSelectedItemWidget() {
    Widget defaultItemMultiSelectionMode(T item) {
      return Container(
        height: 40,
        padding: const EdgeInsets.only(left: 8, bottom: 3, top: 3),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColorLight,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedItemAsString(item),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            MaterialButton(
              height: 20,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(0),
              minWidth: 20,
              onPressed: () {
                removeItem(item);
              },
              child: const Icon(
                Icons.close_outlined,
                size: 20,
              ),
            )
          ],
        ),
      );
    }

    Widget selectedItemWidget() {
      if (widget.dropdownBuilder != null) {
        return widget.dropdownBuilder!(
          context,
          getSelectedItem,
        );
      } else if (widget.dropdownBuilderMultiSelection != null)
        return widget.dropdownBuilderMultiSelection!(
          context,
          getSelectedItems,
        );
      else if (isMultiSelectionMode) {
        return Wrap(
          children: getSelectedItems
              .map((e) => defaultItemMultiSelectionMode(e))
              .toList(),
        );
      }
      return Text(_selectedItemAsString(getSelectedItem),
          style: Theme.of(context).textTheme.titleMedium);
    }

    return selectedItemWidget();
  }

  Widget _formField() {
    return isMultiSelectionMode
        ? _formFieldMultiSelection()
        : _formFieldSingleSelection();
  }

  Widget _formFieldSingleSelection() {
    return FormField<T>(
      enabled: widget.enabled,
      onSaved: widget.onSaved,
      validator: widget.validator,
      autovalidateMode: widget.autoValidateMode,
      initialValue: widget.selectedItem,
      builder: (FormFieldState<T> state) {
        if (state.value != getSelectedItem) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            state.didChange(getSelectedItem);
          });
        }
        return ValueListenableBuilder<bool>(
            valueListenable: _isFocused,
            builder: (context, isFocused, w) {
              return InputDecorator(
                baseStyle: widget.dropdownSearchBaseStyle,
                textAlign: widget.dropdownSearchTextAlign,
                textAlignVertical: widget.dropdownSearchTextAlignVertical,
                isEmpty: getSelectedItem == null &&
                    (widget.dropdownBuilder == null ||
                        widget.dropdownBuilderSupportsNullItem),
                isFocused: isFocused,
                decoration: _manageDropdownDecoration(state),
                child: _defaultSelectedItemWidget(),
              );
            });
      },
    );
  }

  Widget _formFieldMultiSelection() {
    return FormField<List<T>>(
      enabled: widget.enabled,
      onSaved: widget.onSavedMultiSelection,
      validator: widget.validatorMultiSelection,
      autovalidateMode: widget.autoValidateMode,
      initialValue: widget.selectedItems,
      builder: (FormFieldState<List<T>> state) {
        if (state.value != getSelectedItems) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            state.didChange(getSelectedItems);
          });
        }
        return ValueListenableBuilder<bool>(
            valueListenable: _isFocused,
            builder: (context, isFocused, w) {
              return InputDecorator(
                baseStyle: widget.dropdownSearchBaseStyle,
                textAlign: widget.dropdownSearchTextAlign,
                textAlignVertical: widget.dropdownSearchTextAlignVertical,
                isEmpty: getSelectedItems.isEmpty &&
                    (widget.dropdownBuilderMultiSelection == null ||
                        widget.dropdownBuilderSupportsNullItem),
                isFocused: isFocused,
                decoration: _manageDropdownDecoration(state),
                child: _defaultSelectedItemWidget(),
              );
            });
      },
    );
  }

  ///manage dropdownSearch field decoration
  InputDecoration _manageDropdownDecoration(FormFieldState state) {
    return (widget.dropdownSearchDecoration ??
            const InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
              border: OutlineInputBorder(),
            ))
        .applyDefaults(Theme.of(state.context).inputDecorationTheme)
        .copyWith(
          enabled: widget.enabled,
          suffixIcon: _manageSuffixIcons(),
          errorText: state.errorText,
        );
  }

  ///function that return the String value of an object
  String _selectedItemAsString(T? data) {
    if (data == null) {
      return "";
    } else if (widget.itemAsString != null) {
      return widget.itemAsString!(data);
    } else {
      return data.toString();
    }
  }

  ///function that manage Trailing icons(close, dropDown)
  Widget _manageSuffixIcons() {
    clearButtonPressed() => clear();
    dropdownButtonPressed() => _selectSearchMode();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (widget.showClearButton == true && getSelectedItems.isNotEmpty)
          IconButton(
            icon: widget.clearButtonProps?.icon ??
                const Icon(Icons.clear, size: 24),
            onPressed: clearButtonPressed,
            constraints: widget.clearButtonProps?.constraints,
            hoverColor: widget.clearButtonProps?.hoverColor,
            highlightColor: widget.clearButtonProps?.highlightColor,
            splashColor: widget.clearButtonProps?.splashColor,
            color: widget.clearButtonProps?.color,
            focusColor: widget.clearButtonProps?.focusColor,
            iconSize: widget.clearButtonProps?.iconSize ?? 24.0,
            padding:
                widget.clearButtonProps?.padding ?? const EdgeInsets.all(8.0),
            splashRadius: widget.clearButtonProps?.splashRadius,
            alignment: widget.clearButtonProps?.alignment ?? Alignment.center,
            autofocus: widget.clearButtonProps?.autofocus ?? false,
            disabledColor: widget.clearButtonProps?.disabledColor,
            enableFeedback: widget.clearButtonProps?.enableFeedback ?? false,
            focusNode: widget.clearButtonProps?.focusNode,
            mouseCursor: widget.clearButtonProps?.mouseCursor ??
                SystemMouseCursors.click,
            tooltip: widget.clearButtonProps?.tooltip,
            visualDensity: widget.clearButtonProps?.visualDensity,
          ),
        IconButton(
          icon: widget.dropdownButtonProps?.icon ??
              const Icon(Icons.arrow_drop_down_rounded, size: 24),
          onPressed: dropdownButtonPressed,
          constraints: widget.dropdownButtonProps?.constraints,
          hoverColor: widget.dropdownButtonProps?.hoverColor,
          highlightColor: widget.dropdownButtonProps?.highlightColor,
          splashColor: widget.dropdownButtonProps?.splashColor,
          color: widget.dropdownButtonProps?.color,
          focusColor: widget.dropdownButtonProps?.focusColor,
          iconSize: widget.dropdownButtonProps?.iconSize ?? 24.0,
          padding:
              widget.dropdownButtonProps?.padding ?? const EdgeInsets.all(8.0),
          splashRadius: widget.dropdownButtonProps?.splashRadius,
          alignment: widget.dropdownButtonProps?.alignment ?? Alignment.center,
          autofocus: widget.dropdownButtonProps?.autofocus ?? false,
          disabledColor: widget.dropdownButtonProps?.disabledColor,
          enableFeedback: widget.dropdownButtonProps?.enableFeedback ?? false,
          focusNode: widget.dropdownButtonProps?.focusNode,
          mouseCursor: widget.dropdownButtonProps?.mouseCursor ??
              SystemMouseCursors.click,
          tooltip: widget.dropdownButtonProps?.tooltip,
          visualDensity: widget.dropdownButtonProps?.visualDensity,
        ),
      ],
    );
  }

  ///open dialog
  Future _openSelectDialog() {
    return showGeneralDialog(
      barrierDismissible: widget.popupBarrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 400),
      barrierColor: widget.popupBarrierColor ?? const Color(0x80000000),
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          top: widget.popupSafeArea.top,
          bottom: widget.popupSafeArea.bottom,
          left: widget.popupSafeArea.left,
          right: widget.popupSafeArea.right,
          child: AlertDialog(
            elevation: widget.popupElevation,
            contentPadding: const EdgeInsets.all(0),
            shape: widget.popupShape,
            backgroundColor: widget.popupBackgroundColor,
            content: _selectDialogInstance(),
          ),
        );
      },
    );
  }

  ///open BottomSheet (Dialog mode)
  Future _openBottomSheet() {
    return showModalBottomSheetCustom<T>(
        barrierColor: widget.popupBarrierColor,
        backgroundColor: Colors.transparent,
        isDismissible: widget.popupBarrierDismissible,
        isScrollControlled: true,
        context: context,
        builder: (ctx) {
          final MediaQueryData mediaQueryData = MediaQuery.of(ctx);
          EdgeInsets padding = mediaQueryData.padding;
          if (mediaQueryData.padding.bottom == 0.0 &&
              mediaQueryData.viewInsets.bottom != 0.0) {
            padding =
                padding.copyWith(bottom: mediaQueryData.viewPadding.bottom);
          }

          return AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    top: widget.popupSafeArea.top ? padding.top : 0,
                  ),
                  child: Material(
                    color: widget.popupBackgroundColor ??
                        Theme.of(ctx).canvasColor,
                    shape: widget.popupShape,
                    clipBehavior: Clip.antiAlias,
                    elevation: widget.popupElevation,
                    child: SafeArea(
                      top: false,
                      bottom: widget.popupSafeArea.bottom,
                      left: widget.popupSafeArea.left,
                      right: widget.popupSafeArea.right,
                      child: _selectDialogInstance(defaultHeight: 350),
                    ),
                  ),
                ),
                // this part makes top padding tappable to be able to
                // close the popup
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.translucent,
                  child: SizedBox(
                    height: widget.popupSafeArea.top ? padding.top : 0,
                    width: double.infinity,
                  ),
                )
              ],
            ),
          );
        });
  }

  RelativeRect _position(RenderBox popupButtonObject, RenderBox overlay) {
    // Calculate the show-up area for the dropdown using button's size & position based on the `overlay` used as the coordinate space.
    return RelativeRect.fromSize(
      Rect.fromPoints(
        popupButtonObject.localToGlobal(
            popupButtonObject.size.topLeft(const Offset(0, -5)),
            ancestor: overlay),
        popupButtonObject.localToGlobal(
            popupButtonObject.size.topRight(const Offset(0, 0)),
            ancestor: overlay),
      ),
      Size(overlay.size.width, overlay.size.height),
      //Size(0, 0),
    );
  }

  ///openMenu
  Future _openMenu() {
    // Here we get the render object of our physical button, later to get its size & position
    final popupButtonObject = context.findRenderObject() as RenderBox;
    // Get the render object of the overlay used in `Navigator` / `MaterialApp`, i.e. screen size reference
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    return customShowMenu<T>(
        popupSafeArea: widget.popupSafeArea,
        barrierColor: widget.popupBarrierColor,
        shape: widget.popupShape,
        color: widget.popupBackgroundColor,
        context: context,
        position:
            (widget.positionCallback ?? _position)(popupButtonObject, overlay),
        elevation: widget.popupElevation,
        barrierDismissible: widget.popupBarrierDismissible,
        items: [
          CustomPopupMenuItem(
            child: SizedBox(
              width: popupButtonObject.size.width,
              child: _selectDialogInstance(defaultHeight: 224),
            ),
          ),
        ]);
  }

  Widget _selectDialogInstance({double? defaultHeight}) {
    return SelectionWidget<T>(
      key: _popupStateKey,
      popupTitle: widget.popupTitle,
      maxHeight: widget.maxHeight ?? defaultHeight,
      isFilteredOnline: widget.isFilteredOnline,
      itemAsString: widget.itemAsString,
      filterFn: widget.filterFn,
      items: widget.items,
      onFind: widget.onFind,
      showSearchBox: widget.showSearchBox,
      itemBuilder: widget.popupItemBuilder,
      selectedValues: List.from(getSelectedItems),
      onChanged: _handleOnChangeSelectedItems,
      showSelectedItems: widget.showSelectedItems,
      compareFn: widget.compareFn,
      emptyBuilder: widget.emptyBuilder,
      loadingBuilder: widget.loadingBuilder,
      errorBuilder: widget.errorBuilder,
      dialogMaxWidth: widget.dialogMaxWidth,
      itemDisabled: widget.popupItemDisabled,
      searchDelay: widget.searchDelay,
      showFavoriteItems: widget.showFavoriteItems,
      favoriteItems: widget.favoriteItems,
      favoriteItemBuilder: widget.favoriteItemBuilder,
      favoriteItemsAlignment: widget.favoriteItemsAlignment,
      searchFieldProps: widget.searchFieldProps,
      scrollbarProps: widget.scrollbarProps,
      onBeforeChangeMultiSelection: widget.onBeforeChangeMultiSelection,
      popupOnItemAdded: widget.popupOnItemAdded,
      popupOnItemRemoved: widget.popupOnItemRemoved,
      popupSelectionWidget: widget.popupSelectionWidget,
      popupValidationMultiSelectionWidget:
          widget.popupValidationMultiSelectionWidget,
      popupCustomMultiSelectionWidget: widget.popupCustomMultiSelectionWidget,
      isMultiSelectionMode: isMultiSelectionMode,
      selectionListViewProps: widget.selectionListViewProps,
      focusNode: widget.focusNode ?? FocusNode(),
    );
  }

  ///Function that manage focus listener
  ///set true only if the widget already not focused to prevent unnecessary build
  ///same thing for clear focus,
  void _handleFocus(bool isFocused) {
    if (isFocused && !_isFocused.value) {
      FocusScope.of(context).unfocus();
      _isFocused.value = true;
    } else if (!isFocused && _isFocused.value) _isFocused.value = false;
  }

  ///handle on change value , if the validation is active , we validate the new selected item
  void _handleOnChangeSelectedItems(List<T> selectedItems) {
    changeItem() {
      _selectedItemsNotifier.value = List.from(selectedItems);
      if (widget.onChanged != null) {
        widget.onChanged!(getSelectedItem);
      } else if (widget.onChangedMultiSelection != null)
        widget.onChangedMultiSelection!(selectedItems);
    }

    if (widget.onBeforeChange != null) {
      widget.onBeforeChange!(getSelectedItem,
              selectedItems.isEmpty ? null : selectedItems.first)
          .then((value) {
        if (value == true) {
          changeItem();
        }
      });
    } else if (widget.onBeforeChangeMultiSelection != null) {
      widget.onBeforeChangeMultiSelection!(getSelectedItems, selectedItems)
          .then((value) {
        if (value == true) {
          changeItem();
        }
      });
    } else {
      changeItem();
    }

    _handleFocus(false);
  }

  ///compared two items base on user params
  bool _isEqual(T i1, T i2) {
    if (widget.compareFn != null) {
      return widget.compareFn!(i1, i2);
    } else {
      return i1 == i2;
    }
  }

  ///Function that return then UI based on searchMode
  ///[data] selected item to be passed to the UI
  ///If we close the popup , or maybe we just selected
  ///another widget we should clear the focus
  Future _selectSearchMode() async {
    _handleFocus(true);
    if (widget.mode == Mode.MENU) {
      await _openMenu();
    } else if (widget.mode == Mode.BOTTOM_SHEET) {
      await _openBottomSheet();
    } else {
      await _openSelectDialog();
    }
    _handleFocus(false);
    widget.onPopupDismissed?.call();
  }

  ///Change selected Value; this function is public USED to change the selected
  ///value PROGRAMMATICALLY, Otherwise you can use [_handleOnChangeSelectedItems]
  ///for multiSelection mode you can use [changeSelectedItems]
  void changeSelectedItem(T? selectedItem) =>
      _handleOnChangeSelectedItems(_itemToList(selectedItem));

  ///Change selected Value; this function is public USED to change the selected
  ///value PROGRAMMATICALLY, Otherwise you can use [_handleOnChangeSelectedItems]
  ///for SingleSelection mode you can use [changeSelectedItem]
  void changeSelectedItems(List<T> selectedItems) =>
      _handleOnChangeSelectedItems(selectedItems);

  ///function to remove an item from the list
  ///Useful i multiSelection mode to delete an item
  void removeItem(T itemToRemove) => _handleOnChangeSelectedItems(
      getSelectedItems..removeWhere((i) => _isEqual(itemToRemove, i)));

  ///Change selected Value; this function is public USED to clear selected
  ///value PROGRAMMATICALLY, Otherwise you can use [_handleOnChangeSelectedItems]
  void clear() => _handleOnChangeSelectedItems([]);

  ///get selected value programmatically USED for SINGLE_SELECTION mode
  T? get getSelectedItem =>
      getSelectedItems.isEmpty ? null : getSelectedItems.first;

  ///get selected values programmatically
  List<T> get getSelectedItems => _selectedItemsNotifier.value;

  ///check if the dropdownSearch is focused
  bool get isFocused => _isFocused.value;

  ///return true if we are in multiSelection mode , false otherwise
  bool get isMultiSelectionMode => widget.isMultiSelectionMode;

  ///Deselect items programmatically on the popup of selection
  void popupDeselectItems(List<T> itemsToDeselect) {
    _popupStateKey.currentState?.deselectItems(itemsToDeselect);
  }

  ///Deselect ALL items programmatically on the popup of selection
  void popupDeselectAllItems() {
    _popupStateKey.currentState?.deselectAllItems();
  }

  ///select ALL items programmatically on the popup of selection
  void popupSelectAllItems() {
    _popupStateKey.currentState?.selectAllItems();
  }

  ///select items programmatically on the popup of selection
  void popupSelectItems(List<T> itemsToSelect) {
    _popupStateKey.currentState?.deselectItems(itemsToSelect);
  }

  ///validate selected items programmatically on the popup of selection
  void popupOnValidate() {
    _popupStateKey.currentState?.onValidate();
  }

  ///Public Function that return then UI based on searchMode
  ///[data] selected item to be passed to the UI
  ///If we close the popup , or maybe we just selected
  ///another widget we should clear the focus
  ///THIS USED FOR OPEN DROPDOWN_SEARCH PROGRAMMATICALLY,
  ///otherwise you can you [_selectSearchMode]
  void openDropDownSearch() => _selectSearchMode();

  ///close dropdownSearch popup if it's open
  void closeDropDownSearch() => _popupStateKey.currentState?.closePopup();
}
