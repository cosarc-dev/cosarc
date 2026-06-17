import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

class WorkoutService {
  /// Logs a workout to Supabase and updates daily contract + streak.
  ///
  /// Requires `public.workout_logs` table in Supabase — see deliverables
  /// for the exact SQL if the table is missing.
  Future<void> logWorkout({
    required String memberId,
    required List<String> targetMuscles,
    required String exercises,
    required int durationMinutes,
    required int intensity,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    await supabase.from('workout_logs').insert({
      'member_id': memberId,
      'workout_date': today,
      'target_muscles': targetMuscles,
      'exercises': exercises,
      'duration_minutes': durationMinutes,
      'intensity': intensity,
    });

    await supabase
        .from('daily_contracts')
        .update({'workout_completed': true})
        .eq('member_id', memberId)
        .eq('contract_date', today);

    await supabase.rpc('calculate_streak', params: {'p_member_id': memberId});
  }

  static String humanizeError(Object error) {
    final message = error.toString();

    if (message.contains('workout_logs') &&
        (message.contains('not found') ||
            message.contains('PGRST205') ||
            message.contains('42P01'))) {
      return 'Workout logging is not configured yet. '
          'The workout_logs table needs to be created in Supabase. '
          'Contact your administrator.';
    }

    if (message.contains('daily_contracts')) {
      return 'Could not update your daily progress. Please try again.';
    }

    if (message.contains('calculate_streak')) {
      return 'Workout saved, but streak calculation failed. '
          'Your workout was recorded.';
    }

    if (message.contains('JWT') || message.contains('401')) {
      return 'Your session expired. Please sign in again.';
    }

    if (message.contains('permission') || message.contains('RLS')) {
      return 'You do not have permission to log workouts. '
          'Please contact support.';
    }

    return 'Could not save your workout. Please check your connection and try again.';
  }
}
