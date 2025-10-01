import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

class AiPage extends StatefulWidget {
  final String result;
  const AiPage({super.key, required this.result});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  @override
  Widget build(BuildContext context) {
    String r;
    return Scaffold(
      appBar: AppBar(title: Text('智能分析')),
      body: ListView(
        children: [
          for (r in widget.result.split('\n'))
            if (r.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Card(
                  color: r.contains('.')
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onLongPress: () {
                      FlutterClipboard.copy(r).then((value) {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        r,
                        style: TextStyle(
                          color: r.contains('.')
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.primary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: () {
                  FlutterClipboard.copy(widget.result).then((value) {});
                },
                child: Text(
                  '复制全部',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
