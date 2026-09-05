/**
 * TrainWake Web Portal - Live Railway Simulation Controller
 * Provides real-time physics, speedometer HUD, track rendering, and fault injection
 */

class WebSimulationEngine {
  constructor() {
    this.currentRouteKey = 'cairo_alex';
    this.route = SIM_ROUTES[this.currentRouteKey];
    this.speedMultiplier = 5; // default 5x for smooth web preview
    this.isRunning = false;
    this.isPaused = false;
    this.gpsLost = false;
    
    // Physics state
    this.currentKm = 0;
    this.targetKm = this.route.distanceKm;
    this.currentSpeedKmH = 0;
    this.targetSpeedKmH = this.route.typicalSpeedKmH;
    this.alarmTriggered = false;
    
    // Animation loop handle
    this.timerId = null;
    this.lastTickTimestamp = null;
  }

  setRoute(key) {
    if (!SIM_ROUTES[key]) return;
    this.currentRouteKey = key;
    this.route = SIM_ROUTES[key];
    this.reset();
  }

  setMultiplier(mult) {
    this.speedMultiplier = mult;
  }

  start() {
    if (this.isRunning && !this.isPaused) return;
    this.isRunning = true;
    this.isPaused = false;
    this.lastTickTimestamp = performance.now();

    if (this.timerId) clearInterval(this.timerId);
    this.timerId = setInterval(() => this._tick(), 100);
    this._emitStateChange();
  }

  pause() {
    if (!this.isRunning) return;
    this.isPaused = true;
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
    this._emitStateChange();
  }

  reset() {
    this.isRunning = false;
    this.isPaused = false;
    this.gpsLost = false;
    this.currentKm = 0;
    this.targetKm = this.route.distanceKm;
    this.currentSpeedKmH = 0;
    this.targetSpeedKmH = this.route.typicalSpeedKmH;
    this.alarmTriggered = false;

    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
    alarmPlayer.stop();
    this._emitStateChange();
  }

  _tick() {
    const now = performance.now();
    const dtSeconds = (now - (this.lastTickTimestamp || now)) / 1000;
    this.lastTickTimestamp = now;

    if (!this.isRunning || this.isPaused) return;

    // Smooth speed acceleration towards target speed
    if (this.currentSpeedKmH < this.targetSpeedKmH) {
      this.currentSpeedKmH = Math.min(this.targetSpeedKmH, this.currentSpeedKmH + 25 * dtSeconds * (this.speedMultiplier / 2));
    }

    // Distance increment: km/h -> km/s * dt * multiplier
    const speedKmS = this.currentSpeedKmH / 3600;
    const distanceDelta = speedKmS * dtSeconds * this.speedMultiplier;
    this.currentKm = Math.min(this.targetKm, this.currentKm + distanceDelta);

    const remainingKm = Math.max(0, this.targetKm - this.currentKm);
    const remainingHours = this.currentSpeedKmH > 0 ? remainingKm / this.currentSpeedKmH : 0;
    const etaMinutes = Math.round(remainingHours * 60);

    // Buffer zone trigger (when within 15 km or remaining ETA <= 8 min)
    if (remainingKm <= 15 && !this.alarmTriggered) {
      this.alarmTriggered = true;
      alarmPlayer.play();
      this._notifyAlarm('WAKE_UP_TRIGGERED');
    }

    // Trip completed
    if (this.currentKm >= this.targetKm) {
      this.currentSpeedKmH = 0;
      this.pause();
      this._notifyArrival();
    }

    this._emitStateChange();
  }

  // ---------------------------------------------------------------------------
  // Fault Injection APIs
  // ---------------------------------------------------------------------------
  forceGpsLoss() {
    this.gpsLost = true;
    this._emitStateChange();
  }

  forceGpsRecovery() {
    this.gpsLost = false;
    this._emitStateChange();
  }

  forceStationStop() {
    this.targetSpeedKmH = 0;
    this.currentSpeedKmH = 0;
    this._emitStateChange();
  }

  resumeCruise() {
    this.targetSpeedKmH = this.route.typicalSpeedKmH;
    this._emitStateChange();
  }

  forceTriggerAlarm() {
    this.alarmTriggered = true;
    alarmPlayer.play();
    this._notifyAlarm('MANUAL_TEST');
    this._emitStateChange();
  }

  _notifyAlarm(reason) {
    window.dispatchEvent(new CustomEvent('trainwake:alarm', { detail: { reason } }));
  }

  _notifyArrival() {
    window.dispatchEvent(new CustomEvent('trainwake:arrival', { detail: { destination: this.route.nameAr } }));
  }

  _emitStateChange() {
    const remainingKm = Math.max(0, this.targetKm - this.currentKm);
    const etaMinutes = this.currentSpeedKmH > 0 ? Math.round((remainingKm / this.currentSpeedKmH) * 60) : null;
    const progressPercent = Math.min(100, (this.currentKm / this.targetKm) * 100);

    window.dispatchEvent(new CustomEvent('trainwake:simulation_update', {
      detail: {
        routeKey: this.currentRouteKey,
        routeNameAr: this.route.nameAr,
        routeNameEn: this.route.nameEn,
        isRunning: this.isRunning,
        isPaused: this.isPaused,
        gpsLost: this.gpsLost,
        speedMultiplier: this.speedMultiplier,
        currentKm: this.currentKm.toFixed(1),
        totalKm: this.targetKm,
        remainingKm: remainingKm.toFixed(1),
        speedKmH: Math.round(this.currentSpeedKmH),
        speedMps: (this.currentSpeedKmH / 3.6).toFixed(1),
        etaMinutes: etaMinutes,
        progressPercent: progressPercent.toFixed(1),
        alarmTriggered: this.alarmTriggered,
        stations: this.route.stations
      }
    }));
  }
}

const simEngine = new WebSimulationEngine();
