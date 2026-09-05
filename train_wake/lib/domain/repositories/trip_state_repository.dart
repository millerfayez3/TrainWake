abstract class TripStateRepository {
  Future<void> saveActiveTrip(String tripId, Map<String, dynamic> tripData);
  Future<Map<String, dynamic>?> getActiveTrip();
  Future<void> clearActiveTrip();
  
  Future<void> saveRecoveryState(Map<String, dynamic> state);
  Future<Map<String, dynamic>?> getRecoveryState();
}
