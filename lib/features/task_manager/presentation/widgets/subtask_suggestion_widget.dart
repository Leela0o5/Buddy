import 'package:flutter/material.dart';
import '../../../../core/services/task_suggestion_service.dart';
import '../../../../core/models/task.dart';

// Widget showing AI-suggested subtasks with toggle selection
class SubtaskSuggestionWidget extends StatefulWidget {
  final String taskTitle;
  final List<Subtask> selectedSubtasks;
  final ValueChanged<List<Subtask>> onSubtasksChanged;

  const SubtaskSuggestionWidget({
    Key? key,
    required this.taskTitle,
    required this.selectedSubtasks,
    required this.onSubtasksChanged,
  }) : super(key: key);

  @override
  State<SubtaskSuggestionWidget> createState() =>
      _SubtaskSuggestionWidgetState();
}

class _SubtaskSuggestionWidgetState extends State<SubtaskSuggestionWidget> {
  late List<String> _suggestions;
  late Set<String> _selectedSuggestions;

  @override
  void initState() {
    super.initState();
    _updateSuggestions();
  }

  @override
  void didUpdateWidget(SubtaskSuggestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskTitle != widget.taskTitle) {
      _updateSuggestions();
    }
  }

  void _updateSuggestions() {
    _suggestions = TaskSuggestionService.getSuggestions(widget.taskTitle);
    _selectedSuggestions =
        widget.selectedSubtasks.map((s) => s.title).toSet();
  }

  void _toggleSuggestion(String suggestion) {
    setState(() {
      if (_selectedSuggestions.contains(suggestion)) {
        _selectedSuggestions.remove(suggestion);
      } else {
        _selectedSuggestions.add(suggestion);
      }
      _updateSubtasks();
    });
  }

  void _updateSubtasks() {
    final updated = _selectedSuggestions
        .map((title) => Subtask(title: title))
        .toList();
    widget.onSubtasksChanged(updated);
  }

  void _selectAll() {
    setState(() {
      _selectedSuggestions = _suggestions.toSet();
      _updateSubtasks();
    });
  }

  void _clearAll() {
    setState(() {
      _selectedSuggestions.clear();
      _updateSubtasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSuggestions =
        TaskSuggestionService.hasSuggestions(widget.taskTitle);

    if (!hasSuggestions) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Add custom subtasks below',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Suggested Subtasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${_selectedSuggestions.length}/${_suggestions.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Suggestions list
        Column(
          children: _suggestions.map((suggestion) {
            final isSelected = _selectedSuggestions.contains(suggestion);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: isSelected,
              onChanged: (_) => _toggleSuggestion(suggestion),
              title: Text(suggestion),
              subtitle: isSelected
                  ? null
                  : Text(
                      'Tap to add',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Quick actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _selectAll,
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Select All'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
