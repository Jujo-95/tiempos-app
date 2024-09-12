import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiempos_app/app/ui/components/forms/dashboard_form/dashboard_form_operations_provider.dart';
import 'package:tiempos_app/app/ui/components/forms/dashboard_form/dashboard_form_activities_provider.dart';
import 'package:tiempos_app/models/activity_model.dart';

class DropdownActivities extends StatefulWidget {
  final List<ActivityModel> items;
  final ActivityModel activitySelected;
  final void Function(ActivityModel) onChangedActivity;

  DropdownActivities({
    Key? key,
    required this.items,
    required this.activitySelected,
    required this.onChangedActivity,
  }) : super(key: key);

  @override
  State<DropdownActivities> createState() => _DropdownActivitiesState();
}

class _DropdownActivitiesState extends State<DropdownActivities> {
  late ActivityModel _selectedActivity;
  final layerLink = LayerLink();
  final focusNode = FocusNode();
  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();

    _selectedActivity = widget.activitySelected; // Set initial activity
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showOverlay,
    );
  }

  void showOverlay() {
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

    void setTextActivity(ActivityModel value) {
      setState(() {
        _selectedActivity = value;
      });
    }

    Widget itemsBuilder = Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  hideOverlay();
                  setTextActivity(widget.items[index]);
                  widget.onChangedActivity(widget.items[index]);
                },
                title: Text(
                    '${widget.items[index].activity_name} ${widget.items[index].notes}'),
              );
            },
          ),
        ),
        Container()
      ],
    );

    Widget dropDownMenu = Positioned(
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
                child: SingleChildScrollView(
                    child: SizedBox(
                  height: 100,
                  child: itemsBuilder,
                ))),
          ),
        ));

    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: GestureDetector(
          onTap: hideOverlay,
          child: Container(
            color: Colors.transparent,
          ),
        )),
        dropDownMenu,
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
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
                border: Border.all(color: Colors.transparent)),
            constraints: const BoxConstraints(
              minHeight: 50.0,
              minWidth: 80.0,
            ),
            child: GestureDetector(
              onTap: showOverlay,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        '${_selectedActivity.activity_name} ${_selectedActivity.notes}',
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: showOverlay,
                    splashRadius: 0.1,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade800,
                    ),
                  )
                ],
              ),
            )));
  }
}
