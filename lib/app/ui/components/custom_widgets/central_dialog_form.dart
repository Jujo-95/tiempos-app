import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/button_rounded.dart';

class CentralDialogForm extends StatelessWidget {
  final Widget child;
  final String headerEdit;
  final String headerAdd;
  final bool edit;
  final VoidCallback? executeEditRecord;
  final VoidCallback? executeAddRecord;
  final BuildContext context;

  const CentralDialogForm(
      {super.key,
      required this.child,
      this.headerEdit = '',
      this.headerAdd = '',
      required this.edit,
      required this.executeEditRecord,
      required this.executeAddRecord,
      required this.context});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SizedBox(
            width: 450,
            child: Column(
              children: [
                centralFormHeaderBuilder(),
                Container(
                  color: Colors.black12,
                  height: 1,
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 8,
                  width: double.infinity,
                ),
                Expanded(child: SingleChildScrollView(child: child)),
                Container()
              ],
            )));
  }

  static void openEditForm(BuildContext context, Widget formObject) async {
    await showDialog(
        context: context, builder: (BuildContext context) => formObject);
  }

  static manageDeleteAlert(
      BuildContext context, Function() deleteObjectFunction, objectToDeleteName,
      {int popCount = 2}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Está seguro que desea borrar: $objectToDeleteName'),
            actions: [
              ButtonRounded(
                  backgroundColor: Colors.grey.shade100,
                  child: const Text(
                    'Si, Borrar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => {
                        deleteObjectFunction(),
                        for (int i = 0; i < popCount; i++)
                          {Navigator.pop(context)}
                        // Navigator.pop(context),
                        // Navigator.pop(context)
                      }),
              ButtonRounded(
                backgroundColor: Colors.grey.shade100,
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.blueAccent),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  static manageDeleteAlertPop(BuildContext context,
      Function() deleteObjectFunction, objectToDeleteName) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Está seguro que desea borrar: $objectToDeleteName'),
            actions: [
              ButtonRounded(
                  backgroundColor: Colors.grey.shade100,
                  child: const Text(
                    'Si, Borrar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => {
                        deleteObjectFunction(),
                        Navigator.pop(context),
                        Navigator.pop(context)
                      }),
              ButtonRounded(
                backgroundColor: Colors.grey.shade100,
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.blueAccent),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Widget centralFormHeaderBuilder() => Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                  iconSize: 30,
                  splashRadius: 0.1,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.clear)),
            ),
            const SizedBox(
              height: 60,
              width: 1,
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    edit ? headerEdit : headerAdd,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.start,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                  iconSize: 30,
                  splashRadius: 0.1,
                  onPressed: edit ? executeEditRecord : executeAddRecord,
                  icon: const Icon(Icons.check)),
            )
          ],
        ),
      ]);
}
