import 'package:flutter/material.dart';
import '../../../../core/models/energy_log.dart';

// Widget for selecting post-session energy level with emoji
class EnergyLevelPickerWidget extends StatefulWidget {
  final EnergyLevel? initialLevel;
  final ValueChanged<EnergyLevel> onLevelSelected;

  const EnergyLevelPickerWidget({
    Key? key,
    this.initialLevel,
    required this.onLevelSelected,
  }) : super(key: key);

  @override
  State<EnergyLevelPickerWidget> createState() =>
      _EnergyLevelPickerWidgetState();
}

class _EnergyLevelPickerWidgetState extends State<EnergyLevelPickerWidget>
    with SingleTickerProviderStateMixin {
  late EnergyLevel? _selectedLevel;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectLevel(EnergyLevel level) {
    setState(() {
      _selectedLevel = level;
    });
    _animationController.forward(from: 0);
    widget.onLevelSelected(level);
  }

  String _getEmojiForLevel(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return '😴';
      case EnergyLevel.medium:
        return '😐';
      case EnergyLevel.high:
        return '🔥';
    }
  }

  String _getLabelForLevel(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return 'Low';
      case EnergyLevel.medium:
        return 'Medium';
      case EnergyLevel.high:
        return 'High';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How\'s your energy level?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: EnergyLevel.values.map((level) {
            final isSelected = _selectedLevel == level;
            return ScaleTransition(
              scale: isSelected
                  ? Tween<double>(begin: 1, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.elasticOut,
                      ),
                    )
                  : const AlwaysStoppedAnimation(1.0),
              child: GestureDetector(
                onTap: () => _selectLevel(level),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outlineVariant,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _getEmojiForLevel(level),
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getLabelForLevel(level),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
