import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:train_wake/simulation/simulation_controller.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'package:train_wake/trip/alarm_engine.dart';

/// DEVELOPER / SIMULATION MODE — وضع المحاكاة
///
/// This screen is NEVER reachable by normal users.
/// It is a thin UI layer that delegates ALL business logic to [SimulationController].
///
/// DeveloperScreen responsibilities:
///   - Start / pause / resume / reset simulation
///   - Adjust simulation multiplier (1x … 20x)
///   - Adjust GPS speed and noise
///   - Trigger engine-level force actions (via SimulationController)
///   - Display diagnostics read from [SimulationControllerState]
///
/// DeveloperScreen must NOT:
///   - Calculate trip state, ETA, progress, or alarm decisions
///   - Write to tripStateProvider, alarmStateProvider, etaProvider directly
///   - Contain any trip/alarm/ETA business logic
class DeveloperScreen extends ConsumerStatefulWidget {
  const DeveloperScreen({super.key});

  @override
  ConsumerState<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends ConsumerState<DeveloperScreen> {
  // UI-only configuration — passed to SimulationController on start
  double _uiSpeedMps = 20.0;
  double _uiGpsNoise = 0.0;

  @override
  Widget build(BuildContext context) {
    final simState = ref.watch(simulationControllerProvider);
    final frame = simState.lastFrame;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SIMULATION MODE', style: TextStyle(fontSize: 14, letterSpacing: 1.5)),
            Text('وضع المحاكاة', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Live Engine State Readout ──────────────────────────────────
            _section('ENGINE STATE'),
            _row('TripState',
              frame?.tripState.name ?? simState.status.name,
              color: _tripColor(frame?.tripState)),
            _row('AlarmState',
              frame?.alarmState.name ?? 'notArmed',
              color: _alarmColor(frame?.alarmState)),
            _row('ETA',
              frame?.etaSeconds != null
                ? '${(frame!.etaSeconds! / 60).toStringAsFixed(1)} min'
                : 'null'),
            _row('Progress', '${(frame?.progressMeters ?? 0).toStringAsFixed(0)} m'),
            _row('Destination', '${(frame?.destinationMeters ?? 0).toStringAsFixed(0)} m'),
            _row('Remaining', '${(frame?.remainingMeters ?? 0).toStringAsFixed(0)} m'),
            _row('Speed', '${(frame?.speedMps ?? _uiSpeedMps).toStringAsFixed(1)} m/s'),
            _row('GPS Accuracy', '${(frame?.gpsAccuracy ?? 5.0).toStringAsFixed(1)} m'),
            _row('GPS Noise', '${_uiGpsNoise.toStringAsFixed(1)} m'),
            _row('Route Confidence', (frame?.routeConfidence ?? 1.0).toStringAsFixed(2)),
            _row('Direction', frame?.travelingForward == null
                ? 'calculating...'
                : (frame!.travelingForward! ? 'forward ✓' : 'reverse ⚠')),
            _row('Sim Status', simState.status.name),
            _row('Multiplier', '${simState.multiplier.toInt()}x'),

            const Divider(color: Colors.white24),

            // ── Simulation Controls ────────────────────────────────────────
            _section('SIMULATION CONTROLS'),
            _buildPlaybackButtons(simState),
            const SizedBox(height: 8),
            const Text('Simulation Speed', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Wrap(
              spacing: 8,
              children: [1.0, 2.0, 5.0, 10.0, 20.0].map((s) {
                return ChoiceChip(
                  label: Text('${s.toInt()}x'),
                  selected: simState.multiplier == s,
                  onSelected: (_) =>
                    ref.read(simulationControllerProvider.notifier).setMultiplier(s),
                  selectedColor: Colors.red[800],
                  labelStyle: TextStyle(
                    color: simState.multiplier == s ? Colors.white : Colors.grey,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            _sliderRow('Speed (m/s)', _uiSpeedMps, 0, 55, (v) {
              setState(() => _uiSpeedMps = v);
              // Speed change applies on next start/reset
            }),
            _sliderRow('GPS Noise (m)', _uiGpsNoise, 0, 80, (v) {
              setState(() => _uiGpsNoise = v);
            }),

            const Divider(color: Colors.white24),

            // ── Force Actions (routed through SimulationController → engine) ─
            _section('FORCE ACTIONS'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ctrlBtn('Early Warning', () =>
                  ref.read(simulationControllerProvider.notifier).forceEarlyWarning()),
                _ctrlBtn('Force Alarm', () =>
                  ref.read(simulationControllerProvider.notifier).forceAlarm()),
                _ctrlBtn('Force Arrival', () =>
                  ref.read(simulationControllerProvider.notifier).forceArrival()),
                _ctrlBtn('Force Missed', () =>
                  ref.read(simulationControllerProvider.notifier).forceMissed()),
                _ctrlBtn('GPS Loss', () =>
                  ref.read(simulationControllerProvider.notifier).forceGpsLoss()),
                _ctrlBtn('GPS Recovery', () =>
                  ref.read(simulationControllerProvider.notifier).forceGpsRecovery()),
                _ctrlBtn('Station Stop', () =>
                  ref.read(simulationControllerProvider.notifier).forceStationStop()),
              ],
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'DEV ONLY — This screen exercises the production TripEngine, '
                'AlarmEngine, EtaEngine, RailwayMatcher, and DirectionDetector '
                'via SimulationController. No fake business logic exists here.',
                style: TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackButtons(SimulationControllerState simState) {
    final ctrl = ref.read(simulationControllerProvider.notifier);
    return Row(
      children: [
        if (simState.status == SimulationStatus.idle ||
            simState.status == SimulationStatus.terminal)
          _ctrlBtn('START ▶', () => ctrl.start(
            speedMps: _uiSpeedMps,
            noiseMeters: _uiGpsNoise,
          ))
        else if (simState.status == SimulationStatus.running)
          _ctrlBtn('PAUSE ⏸', ctrl.pause)
        else if (simState.status == SimulationStatus.paused)
          _ctrlBtn('RESUME ▶', ctrl.resume),
        const SizedBox(width: 8),
        _ctrlBtn('RESET ↺', ctrl.reset),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(title,
      style: const TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.5)),
  );

  Widget _row(String label, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
            fontSize: 13,
          )),
      ],
    ),
  );

  Widget _sliderRow(
    String label, double value, double min, double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: Colors.red[700],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _ctrlBtn(String label, VoidCallback onPressed) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red[900],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: const TextStyle(fontSize: 12),
    ),
    child: Text(label),
  );

  Color _tripColor(TripState? s) => switch (s) {
    TripState.tracking => Colors.green,
    TripState.approaching => Colors.blue,
    TripState.alarmArmed => Colors.orange,
    TripState.gpsUncertain => Colors.yellow,
    TripState.arrived => Colors.teal,
    TripState.missed => Colors.red,
    _ => Colors.grey,
  };

  Color _alarmColor(AlarmState? s) => switch (s) {
    AlarmState.notArmed => Colors.grey,
    AlarmState.armed => Colors.green,
    AlarmState.earlyWarningTriggered => Colors.blue,
    AlarmState.mainAlarmTriggered || AlarmState.unacknowledged => Colors.red,
    AlarmState.acknowledged => Colors.teal,
    _ => Colors.grey,
  };
}
