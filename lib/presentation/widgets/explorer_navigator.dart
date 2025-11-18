import 'package:flutter/material.dart';

enum ExplorerDisplayMode { textOnly, iconOnly, iconAndText }

class ExplorerNavigator extends StatefulWidget {
  final List<Map<String, dynamic>> structure;
  final Color? backgroundColor;
  final Color? highlightColor;
  final Widget? defaultScreen;
  final ExplorerDisplayMode defaultDisplayMode;
  final bool showBreadcrumb; //  

  const ExplorerNavigator({
    super.key,
    required this.structure,
    this.backgroundColor,
    this.highlightColor,
    this.defaultScreen,
    this.defaultDisplayMode = ExplorerDisplayMode.textOnly,
    this.showBreadcrumb = false,  
  });

  @override
  State<ExplorerNavigator> createState() => _ExplorerNavigatorState();
}

class _ExplorerNavigatorState extends State<ExplorerNavigator> {
  Map<String, dynamic>? _selectedNode;
  List<Map<String, dynamic>> _path = [];
  Map<String, bool> _hoverStates = {};

  @override
  void initState() {
    super.initState();
  }

  void _onNodeSelected(
    Map<String, dynamic> node,
    List<Map<String, dynamic>> path,
  ) {
    setState(() {
      _selectedNode = node;
      _path = path;
      _expandPath(path);
    });
  }

  void _expandPath(List<Map<String, dynamic>> path) {
    // Ensures all parent nodes stay expanded
    for (var node in path) {
      node['expanded'] = true;
    }
  }

  void _navigateToBreadcrumb(int index) {
    // Navigate back to a specific level in the breadcrumb path
    final node = _path[index];
    setState(() {
      _selectedNode = node;
      _path = _path.sublist(0, index + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Breadcrumb Bar
        if (widget.showBreadcrumb && _path.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: List.generate(_path.length, (i) {
                final isLast = i == _path.length - 1;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: isLast ? null : () => _navigateToBreadcrumb(i),
                      child: Text(
                        _path[i]['label'] ?? 'Unnamed',
                        style: TextStyle(
                          fontWeight: isLast
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isLast
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),

        // Main Explorer Body
        Expanded(
          child: Row(
            children: [
              // Left Navigation Panel
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 280,
                decoration: BoxDecoration(color: widget.backgroundColor),
                child: ListView(
                  //padding: const EdgeInsets.symmetric(vertical: 8),
                  children: widget.structure
                      .map(
                        (node) => _buildNode(
                          node,
                          0,
                          widget.defaultDisplayMode,
                          colorScheme,
                          [node],
                        ),
                      )
                      .toList(),
                ),
              ),

              // Right Content Area
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Container(
                    key: ValueKey(_selectedNode),
                    color: colorScheme.surface,
                    child:
                        _selectedNode?['screen'] ??
                        widget.defaultScreen ??
                        const Center(
                          child: Text(
                            'Select an item from the explorer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNode(
    Map<String, dynamic> node,
    int depth,
    ExplorerDisplayMode parentMode,
    ColorScheme colorScheme,
    List<Map<String, dynamic>> path,
  ) {
    final hasChildren =
        node['children'] != null && (node['children'] as List).isNotEmpty;
    node['expanded'] ??= false;
    final mode = node['mode'] ?? parentMode;
    final isSelected = _selectedNode == node;
    final isHovered = _hoverStates[node['label']] ?? false;

    final bool isAncestor = _path.contains(node);

    Color baseColor = isAncestor
        ? colorScheme.primary.withOpacity(0.9)
        : colorScheme.onSurfaceVariant;
    Color hoverColor = colorScheme.primary.withOpacity(0.05);
    Color selectedColor =
        widget.highlightColor ?? colorScheme.primary.withOpacity(0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hoverStates[node['label']] = true),
          onExit: (_) => setState(() => _hoverStates[node['label']] = false),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: hasChildren
                ? () => setState(() => node['expanded'] = !node['expanded'])
                : () => _onNodeSelected(node, path),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                left: 8.0 + (depth * 12.0),
                right: 8.0,
               
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor
                    : isHovered
                    ? hoverColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (hasChildren)
                    Icon(
                      node['expanded']
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 20,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    )
                  else
                    const SizedBox(width: 20),
                  if (mode != ExplorerDisplayMode.textOnly)
                    Icon(
                      node['icon'] ?? Icons.insert_drive_file,
                      size: 18,
                      color: isSelected
                          ? colorScheme.primary
                          : baseColor.withOpacity(0.8),
                    ),
                  if (mode == ExplorerDisplayMode.iconAndText)
                    const SizedBox(width: 8),
                  if (mode != ExplorerDisplayMode.iconOnly)
                    Expanded(
                      child: Text(
                        node['label'] ?? 'Unnamed',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? colorScheme.primary : baseColor,
                          fontWeight: isAncestor
                              ? FontWeight.w600
                              : isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasChildren && node['expanded'])
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Column(
              children: (node['children'] as List)
                  .map(
                    (child) => _buildNode(child, depth + 1, mode, colorScheme, [
                      ...path,
                      child,
                    ]),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
