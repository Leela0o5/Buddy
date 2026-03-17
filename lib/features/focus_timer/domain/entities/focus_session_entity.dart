// Domain entity for focus session (same as model, but in domain layer)
import '../../../../core/models/focus_session.dart';

// Domain uses this, data layer converts to/from storage models
typedef FocusSessionEntity = FocusSession;