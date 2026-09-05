import 'package:hive_flutter/hive_flutter.dart';

enum TripOutcome { arrived, missed, cancelled }

class TripHistoryEntry {
  final String destinationName;
  final DateTime date;
  final TripOutcome outcome;
  final double wakeOffsetMinutes;

  TripHistoryEntry({
    required this.destinationName,
    required this.date,
    required this.outcome,
    required this.wakeOffsetMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'destinationName': destinationName,
      'date': date.toIso8601String(),
      'outcome': outcome.name,
      'wakeOffsetMinutes': wakeOffsetMinutes,
    };
  }

  factory TripHistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    return TripHistoryEntry(
      destinationName: map['destinationName'] as String,
      date: DateTime.parse(map['date'] as String),
      outcome: TripOutcome.values.firstWhere((e) => e.name == map['outcome']),
      wakeOffsetMinutes: (map['wakeOffsetMinutes'] as num).toDouble(),
    );
  }
}

class HistoryRepository {
  static const String _boxName = 'history_box';

  Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  Future<void> addEntry(TripHistoryEntry entry) async {
    try {
      final box = Hive.isBoxOpen(_boxName)
          ? Hive.box(_boxName)
          : await Hive.openBox(_boxName);
      final List<dynamic> current = box.get('entries', defaultValue: []);
      current.add(entry.toMap());
      await box.put('entries', current);
    } catch (_) {}
  }

  List<TripHistoryEntry> getHistory() {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return [];
      }
      final box = Hive.box(_boxName);
      final List<dynamic> data = box.get('entries', defaultValue: []);
      return data.map((e) => TripHistoryEntry.fromMap(e as Map)).toList().reversed.toList();
    } catch (_) {
      return [];
    }
  }
}
