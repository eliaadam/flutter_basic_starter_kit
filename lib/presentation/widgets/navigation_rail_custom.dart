import 'package:flutter/material.dart';
import 'package:flutter_basic_starter_kit/core/utils/logout_util.dart';
// Make sure this path is correct

enum NavigationDisplayMode { iconsAndLabels, iconsOnly, labelsOnly }

class NavigationRailCustom extends StatefulWidget {
  final List<IconData> icons;
  final List<String> labels;
  final List<Widget> screens;
  final int initialIndex;
  final NavigationDisplayMode displayMode;
  final Widget? header;
  final Widget? footer;
  final bool enableLogout;

  const NavigationRailCustom({
    super.key,
    required this.icons,
    required this.labels,
    required this.screens,
    this.initialIndex = 0,
    this.displayMode = NavigationDisplayMode.iconsAndLabels,
    this.header,
    this.footer,
    this.enableLogout = false, // 👈 NEW: control logout button
  }) : assert(
         icons.length == labels.length && labels.length == screens.length,
         "Icons, labels, and screens lists must have the same length.",
       );

  @override
  _NavigationRailCustomState createState() => _NavigationRailCustomState();
}

class _NavigationRailCustomState extends State<NavigationRailCustom> {
  late int selectedIndex;
  late List<bool> isHovered;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    isHovered = List.filled(widget.icons.length, false);
  }

  double getNavRailWidth() {
    double longestLabelWidth =
        widget.labels.fold(0.0, (double maxWidth, label) {
          final width = label.length * 8.0;
          return width > maxWidth ? width : maxWidth;
        }) +
        40;

    switch (widget.displayMode) {
      case NavigationDisplayMode.iconsAndLabels:
        return longestLabelWidth + 50;
      case NavigationDisplayMode.labelsOnly:
        return longestLabelWidth;
      case NavigationDisplayMode.iconsOnly:
        return 70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: Colors.transparent,
          width: getNavRailWidth(),
          child: Column(
            children: [
              if (widget.header != null) widget.header!,
              Expanded(
                child: Column(
                  children: [
                    for (int i = 0; i < widget.icons.length; i++)
                      MouseRegion(
                        onEnter: (_) => setState(() => isHovered[i] = true),
                        onExit: (_) => setState(() => isHovered[i] = false),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedIndex = i),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 100),
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 1,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isHovered[i]
                                  ? Colors.grey.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (widget.displayMode !=
                                    NavigationDisplayMode.labelsOnly)
                                  Icon(
                                    widget.icons[i],
                                    color: selectedIndex == i
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.5),
                                    size: 24,
                                  ),
                                if (widget.displayMode ==
                                    NavigationDisplayMode.iconsAndLabels)
                                  SizedBox(width: 15),
                                if (widget.displayMode !=
                                    NavigationDisplayMode.iconsOnly)
                                  Text(
                                    widget.labels[i],
                                    style: TextStyle(
                                      color: selectedIndex == i
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : const Color.fromARGB(
                                              255,
                                              32,
                                              32,
                                              32,
                                            ),
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Spacer(),
                  ],
                ),
              ),
              if (widget.footer != null) widget.footer!,
              if (widget.enableLogout)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => logout(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.logout,
                            size: 22,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          if (widget.displayMode !=
                              NavigationDisplayMode.iconsOnly)
                            SizedBox(width: 10),
                          if (widget.displayMode !=
                              NavigationDisplayMode.iconsOnly)
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
            ),
            child: widget.screens[selectedIndex],
          ),
        ),
      ],
    );
  }
}
