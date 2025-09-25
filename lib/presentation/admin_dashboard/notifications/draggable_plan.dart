import 'package:flutter/material.dart';

class DraggablePlan extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isTemplate;
  final VoidCallback? onDelete;
  final VoidCallback? onColor;
  final VoidCallback? onMore;
  final Widget child;
  final Widget? childWhenDragging;
  final void Function()? onDragStarted;
  final void Function()? onDraggableCanceled;

  const DraggablePlan({
    super.key,
    required this.plan,
    required this.isTemplate,
    this.onDelete,
    this.onColor,
    this.onMore,
    required this.child,
    this.childWhenDragging,
    this.onDragStarted,
    this.onDraggableCanceled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        if (!isTemplate) {
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          showMenu(
            context: context,
            position: RelativeRect.fromRect(
              details.globalPosition & const Size(48, 48),
              Offset.zero & overlay.size,
            ),
            items: [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Cambiar color'),
                  contentPadding: EdgeInsets.zero,
                  onTap: onColor,
                ),
              ),
              if (!isTemplate)
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Eliminar plan'),
                    contentPadding: EdgeInsets.zero,
                    onTap: onDelete,
                  ),
                ),
            ],
          );
        }
      },
      child: Draggable<Map<String, dynamic>>(
        data: {...plan, 'isTemplate': isTemplate},
        feedback: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: child,
        ),
        childWhenDragging:
            childWhenDragging ?? Opacity(opacity: 0.5, child: child),
        onDragStarted: onDragStarted,
        onDraggableCanceled: (_, __) => onDraggableCanceled?.call(),
        child: child,
      ),
    );
  }
}
