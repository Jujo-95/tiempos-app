import 'package:flutter/material.dart';

class GenericDropdownMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;
  final List<Widget> actions;
  final GlobalKey<_GenericDropdownMenuState> key;

  const GenericDropdownMenu({
    required this.key,
    required this.child,
    required this.menuItems,
    required this.actions,
  }) : super(key: key);

  @override
  State<GenericDropdownMenu> createState() => _GenericDropdownMenuState();
}

class _GenericDropdownMenuState extends State<GenericDropdownMenu> {
  final layerLink = LayerLink();
  OverlayEntry? entry;

  void showMenuOptions() {
    final overlay = Overlay.of(context);

    entry = OverlayEntry(builder: (context) => buildOverlay());

    overlay.insert(entry!);
  }

  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  Widget buildOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: GestureDetector(
            onTap: hideOverlay,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            showWhenUnlinked: false,
            link: layerLink,
            offset: Offset(0, size.height + 8),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(3, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: widget.menuItems,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.grey.shade300),
        ),
        constraints: const BoxConstraints(
          minHeight: 40.0,
          minWidth: 80.0,
        ),
        child: Row(
          children: [
            Expanded(
              child: widget.child,
            ),
            Container(
              color: Colors.grey.shade300,
              width: 1,
              height: 25,
            ),
            Row(children: widget.actions),
          ],
        ),
      ),
    );
  }
}
