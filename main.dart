import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => DockState<T>();
}

class DockState<T extends Object> extends State<Dock<T>> {
  late List<T> items = widget.items.toList();
  T? draggedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return LongPressDraggable<T>(
            data: item,
            onDragStarted: () {
              setState(() {
                draggedItem = item;
              });
            },
            onDragCompleted: () {
              setState(() {
                items.remove(item);
              });
            },
            onDraggableCanceled: (_, __) {
              setState(() {
                draggedItem = null;
              });
            },
            feedback: Opacity(
              opacity: 0.7,
              child: widget.builder(item),
            ),
            childWhenDragging: const SizedBox.shrink(),
            child: DragTarget<T>(
              onAcceptWithDetails: (details) {
                setState(() {
                  final receivedItem = details.data;
                  items.remove(receivedItem);
                  final newIndex = items.indexOf(item);
                  items.insert(newIndex, receivedItem);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: widget.builder(item),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
