import 'package:flutter/material.dart';
import 'package:jiyi/widgets/drawer/drawer_widget.dart';
import 'package:jiyi/widgets/item/item_list_widget.dart';
import 'package:jiyi/widgets/btm_appbar_widget.dart';
import 'package:jiyi/widgets/fab_widget.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('记易'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ItemListWidget(),
      ),
      bottomNavigationBar: BtmAppbarWidget(),
      floatingActionButton: Fab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      drawer: DrawerWidget(),
    );
  }
}
