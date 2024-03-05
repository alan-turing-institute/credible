import 'package:credible/app/shared/ui/ui.dart';
import 'package:flutter/material.dart';

class AnimatedMenuItem extends StatefulWidget {
  final AnimatedIconData icon;
  final String title;
  final VoidCallback onTap;

  const AnimatedMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<AnimatedMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..forward()
      ..repeat(reverse: true);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.title,
      child: Material(
        color: Colors.green.shade100,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: UiKit.palette.lightBorder),
              ),
            ),
            child: Row(
              children: [
                // Icon(
                //   widget.icon,
                //   size: 24.0,
                //   color: UiKit.palette.icon,
                // ),
                AnimatedIcon(
                    icon: widget.icon,
                    size: 30,
                    progress: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(controller)),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodyText1!,
                  ),
                ),
                const SizedBox(width: 16.0),
                Icon(
                  Icons.chevron_right,
                  size: 24.0,
                  color: UiKit.palette.icon,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
