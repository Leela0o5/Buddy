import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/energy_log.dart';
import '../../../../core/models/focus_session.dart';
import '../../../../config/constants.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../widgets/energy_level_picker_widget.dart';
import '../state/reflection_provider.dart';

// Post-session reflection screen for energy tracking and notes
class ReflectionScreen extends ConsumerStatefulWidget {
  final FocusSession completedSession;

  const ReflectionScreen({
    Key? key,
    required this.completedSession,
  }) : super(key: key);

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  late EnergyLevel? _selectedEnergyLevel;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedEnergyLevel = null;
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveReflection() async {
    if (_selectedEnergyLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your energy level')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final energyLog = EnergyLog(
      sessionId: widget.completedSession.id,
      energyLevel: _selectedEnergyLevel!,
      reflectionNotes: _notesController.text.isEmpty
          ? null
          : _notesController.text,
    );

    try {
      await ref.read(saveEnergyLogProvider(energyLog).future);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved! 🎉')),
      );

      // Return to home screen after 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Reflection',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '✨ Great work! ✨',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You completed ${widget.completedSession.durationMinutes} minutes of focused work',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (widget.completedSession.distractionsCount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Distractions detected: ${widget.completedSession.distractionsCount}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Energy level picker
            EnergyLevelPickerWidget(
              initialLevel: _selectedEnergyLevel,
              onLevelSelected: (level) {
                setState(() => _selectedEnergyLevel = level);
              },
            ),
            const SizedBox(height: 32),

            // Reflection notes
            Text(
              'What helped you focus?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'E.g., Put phone in another room, used white noise...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: AppConstants.largeButtonHeight,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _saveReflection,
                icon: const Icon(Icons.check),
                label: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save Reflection'),
              ),
            ),
            const SizedBox(height: 16),

            // Skip button
            SizedBox(
              width: double.infinity,
              height: AppConstants.largeButtonHeight,
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );
                      },
                child: const Text('Skip for now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
