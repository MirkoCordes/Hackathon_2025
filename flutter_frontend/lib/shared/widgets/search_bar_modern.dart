import 'package:flutter/material.dart';

class SearchBarModern extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;

  const SearchBarModern({
    super.key,
    this.hintText = 'Suchen...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
  });

  @override
  State<SearchBarModern> createState() => _SearchBarModernState();
}

class _SearchBarModernState extends State<SearchBarModern> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.outline,
            size: 20,
          ),
          suffixIcon:
              _controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.outline,
                      size: 20,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}
