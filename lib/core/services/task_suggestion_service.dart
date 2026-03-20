
// Service to suggest subtasks based on task title keywords
class TaskSuggestionService {
  // Default suggestions by category
  static final Map<String, List<String>> _suggestionMap = {
    'write': [
      'Open document',
      'Create outline',
      'Write introduction',
      'Write body',
      'Write conclusion',
      'Proofread',
      'Format',
    ],
    'report': [
      'Gather data',
      'Create charts',
      'Write summary',
      'Add visuals',
      'Review findings',
      'Final review',
    ],
    'email': [
      'Draft message',
      'Add recipient',
      'Proofread',
      'Attach files',
      'Send',
    ],
    'meeting': [
      'Schedule time',
      'Send invites',
      'Prepare materials',
      'Set up room/video',
      'Join meeting',
      'Follow up',
    ],
    'call': [
      'Prepare talking points',
      'Test audio/video',
      'Join call',
      'Take notes',
      'Follow up',
    ],
    'code': [
      'Create branch',
      'Understand requirements',
      'Write code',
      'Run tests',
      'Create PR',
      'Code review',
    ],
    'design': [
      'Gather inspiration',
      'Create wireframes',
      'Design mockups',
      'Get feedback',
      'Iterate',
      'Finalize',
    ],
    'presentation': [
      'Outline topics',
      'Create slides',
      'Add visuals',
      'Practice delivery',
      'Get feedback',
      'Final review',
    ],
    'research': [
      'Define topic',
      'Find sources',
      'Read sources',
      'Take notes',
      'Synthesize findings',
      'Write summary',
    ],
    'project': [
      'Define scope',
      'Create timeline',
      'Assign tasks',
      'Track progress',
      'Manage risks',
      'Review completion',
    ],
    'cleaning': [
      'Gather supplies',
      'Declutter',
      'Dust surfaces',
      'Vacuum/sweep',
      'Mop/clean',
      'Organize',
    ],
    'exercise': [
      'Warm up',
      'Do cardio',
      'Strength training',
      'Stretching',
      'Cool down',
    ],
    'learning': [
      'Find resource',
      'Set up environment',
      'Work through lesson',
      'Practice',
      'Review',
      'Test understanding',
    ],
    'shopping': [
      'Make list',
      'Check inventory',
      'Add budget',
      'Go shopping',
      'Organize items',
    ],
  };

  // Get suggestions for a task title
  static List<String> getSuggestions(String taskTitle) {
    final titleLower = taskTitle.toLowerCase().trim();

    if (titleLower.isEmpty) {
      return _getGenericSuggestions();
    }

    // Find matching category
    for (final keyword in _suggestionMap.keys) {
      if (titleLower.contains(keyword)) {
        return _suggestionMap[keyword] ?? _getGenericSuggestions();
      }
    }

    // No match found, return generic suggestions
    return _getGenericSuggestions();
  }

  // Generic fallback suggestions
  static List<String> _getGenericSuggestions() {
    return [
      'Start',
      'Work on it',
      'Review progress',
      'Refine',
      'Complete',
      'Verify',
    ];
  }

  // Check if we have specific suggestions for the title
  static bool hasSuggestions(String taskTitle) {
    final suggestions = getSuggestions(taskTitle);
    return suggestions != _getGenericSuggestions();
  }
}
