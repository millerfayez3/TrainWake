/**
 * TrainWake Web Portal - Main Application Orchestrator
 */

document.addEventListener('DOMContentLoaded', () => {
  initSimulationUI();
  initStationExplorer();
  initThemeToggle();
  initSoundAlertButton();
});

// -----------------------------------------------------------------------------
// 1. Simulation UI Bindings
// -----------------------------------------------------------------------------
function initSimulationUI() {
  const routeSelect = document.getElementById('sim-route-select');
  const btnPlay = document.getElementById('btn-sim-play');
  const btnPause = document.getElementById('btn-sim-pause');
  const btnReset = document.getElementById('btn-sim-reset');
  const speedChips = document.querySelectorAll('.speed-chip');

  // Route selector
  if (routeSelect) {
    routeSelect.addEventListener('change', (e) => {
      simEngine.setRoute(e.target.value);
      renderTrackStations(simEngine.route.stations);
    });
  }

  // Play / Pause / Reset
  btnPlay?.addEventListener('click', () => {
    simEngine.start();
    document.getElementById('train-marker-el')?.classList.add('train-running');
  });

  btnPause?.addEventListener('click', () => {
    simEngine.pause();
    document.getElementById('train-marker-el')?.classList.remove('train-running');
  });

  btnReset?.addEventListener('click', () => {
    simEngine.reset();
    document.getElementById('train-marker-el')?.classList.remove('train-running');
    document.getElementById('sim-deck-container')?.classList.remove('alarm-active');
  });

  // Speed Multipliers
  speedChips.forEach(chip => {
    chip.addEventListener('click', () => {
      speedChips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      const mult = parseInt(chip.dataset.multiplier, 10);
      simEngine.setMultiplier(mult);
    });
  });

  // Fault Injection Buttons
  document.getElementById('fault-tunnel')?.addEventListener('click', () => {
    simEngine.forceGpsLoss();
    showToast('⚠️ تم محاكاة دخول نفق وفقدان إشارة GPS');
  });

  document.getElementById('fault-gps-restore')?.addEventListener('click', () => {
    simEngine.forceGpsRecovery();
    showToast('✅ تم استعادة إشارة الـ GPS بنجاح');
  });

  document.getElementById('fault-stop')?.addEventListener('click', () => {
    simEngine.forceStationStop();
    showToast('🛑 توقف القطار بالمحطة (السرعة 0 كم/س)');
  });

  document.getElementById('fault-alarm')?.addEventListener('click', () => {
    simEngine.forceTriggerAlarm();
    showToast('🚨 تم إطلاق صفارة إنذار الاستيقاظ القصوى!');
  });

  // Listen to simulation state updates
  window.addEventListener('trainwake:simulation_update', (e) => {
    const s = e.detail;

    // HUD values
    const speedEl = document.getElementById('hud-speed-val');
    const speedMpsEl = document.getElementById('hud-speed-mps');
    const distEl = document.getElementById('hud-dist-val');
    const etaEl = document.getElementById('hud-eta-val');
    const statusEl = document.getElementById('hud-status-badge');

    if (speedEl) speedEl.textContent = s.speedKmH;
    if (speedMpsEl) speedMpsEl.textContent = s.speedMps;
    if (distEl) distEl.textContent = s.remainingKm;
    if (etaEl) etaEl.textContent = s.etaMinutes !== null ? s.etaMinutes : '—';

    // Status Pill
    if (statusEl) {
      if (s.gpsLost) {
        statusEl.textContent = 'نفق (GPS غير مؤكد)';
        statusEl.style.color = '#F59E0B';
      } else if (s.alarmTriggered) {
        statusEl.textContent = '🚨 استيقاظ! اقتربت من المحطة';
        statusEl.style.color = '#F43F5E';
      } else if (s.isRunning && !s.isPaused) {
        statusEl.textContent = '📡 تتبع حي نشط';
        statusEl.style.color = '#10B981';
      } else if (s.isPaused) {
        statusEl.textContent = '⏸️ متوقف مؤقتاً';
        statusEl.style.color = '#EAB308';
      } else {
        statusEl.textContent = 'جاهز للانطلاق';
        statusEl.style.color = '#94A3B8';
      }
    }

    // Update Linear Track Progress
    const fillEl = document.getElementById('track-fill-line');
    const markerEl = document.getElementById('train-marker-el');
    if (fillEl) fillEl.style.width = `${s.progressPercent}%`;
    if (markerEl) markerEl.style.right = `${s.progressPercent}%`;

    // Highlight Station Nodes
    updateStationNodesHighlight(s.currentKm, s.stations);
  });

  // Alarm Trigger Event
  window.addEventListener('trainwake:alarm', () => {
    document.getElementById('sim-deck-container')?.classList.add('alarm-active');
  });

  // Initial stations render
  renderTrackStations(simEngine.route.stations);
}

function renderTrackStations(stations) {
  const container = document.getElementById('track-stations-list');
  if (!container) return;
  container.innerHTML = '';

  stations.forEach((st, idx) => {
    const node = document.createElement('div');
    node.className = 'track-station-node';
    node.id = `station-node-${st.id}`;
    node.innerHTML = `
      <div class="station-pin-dot"></div>
      <span>${st.nameAr}</span>
    `;
    container.appendChild(node);
  });
}

function updateStationNodesHighlight(currentKm, stations) {
  stations.forEach(st => {
    const el = document.getElementById(`station-node-${st.id}`);
    if (!el) return;
    if (currentKm >= st.km) {
      el.classList.add('passed');
    } else {
      el.classList.remove('passed');
    }
  });
}

// -----------------------------------------------------------------------------
// 2. Station Explorer (92 Stations Filter & Search)
// -----------------------------------------------------------------------------
function initStationExplorer() {
  const grid = document.getElementById('stations-grid-container');
  const searchInput = document.getElementById('station-search-input');
  const filterBtns = document.querySelectorAll('.region-filter');
  const countBadge = document.getElementById('stations-count-badge');

  let activeRegion = 'all';
  let searchQuery = '';

  function renderGrid() {
    if (!grid) return;
    grid.innerHTML = '';

    const filtered = ENR_STATIONS.filter(st => {
      const matchRegion = activeRegion === 'all' || st.region === activeRegion;
      const q = searchQuery.toLowerCase().trim();
      const matchQuery = !q || st.nameAr.includes(q) || st.nameEn.toLowerCase().includes(q);
      return matchRegion && matchQuery;
    });

    if (countBadge) countBadge.textContent = `${filtered.length} محطة`;

    if (filtered.length === 0) {
      grid.innerHTML = '<div style="grid-column: 1/-1; text-align: center; color: #64748B; padding: 2rem;">لا توجد محطات مطابقة للبحث</div>';
      return;
    }

    filtered.forEach(st => {
      const card = document.createElement('div');
      card.className = 'station-card';
      card.innerHTML = `
        <div class="station-icon">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2c-4 0-8 .5-8 4v9.5C4 17.43 5.57 19 7.5 19L6 20.5v.5h12v-.5L16.5 19c1.93 0 3.5-1.57 3.5-3.5V6c0-3.5-4-4-8-4zM7.5 17c-.83 0-1.5-.67-1.5-1.5S6.67 14 7.5 14s1.5.67 1.5 1.5S8.33 17 7.5 17zm9 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zm1.5-6H6V6h12v5z"/>
          </svg>
        </div>
        <div class="station-details">
          <h4>${st.nameAr}</h4>
          <p>${st.nameEn} • ${st.latitude.toFixed(2)}, ${st.longitude.toFixed(2)}</p>
        </div>
      `;
      grid.appendChild(card);
    });
  }

  searchInput?.addEventListener('input', (e) => {
    searchQuery = e.target.value;
    renderGrid();
  });

  filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      activeRegion = btn.dataset.region;
      renderGrid();
    });
  });

  renderGrid();
}

// -----------------------------------------------------------------------------
// 3. Theme Toggle
// -----------------------------------------------------------------------------
function initThemeToggle() {
  const btn = document.getElementById('theme-toggle-btn');
  btn?.addEventListener('click', () => {
    document.body.classList.toggle('light-theme');
  });
}

// -----------------------------------------------------------------------------
// 4. Sound Alert Test Button
// -----------------------------------------------------------------------------
function initSoundAlertButton() {
  const btn = document.getElementById('test-audio-btn');
  if (!btn) return;
  btn.addEventListener('click', () => {
    alarmPlayer.toggle();
    if (alarmPlayer.isPlaying) {
      btn.textContent = '🔊 إيقاف التنبيه';
      btn.style.background = '#F43F5E';
      btn.style.color = '#FFFFFF';
    } else {
      btn.textContent = '🔔 تجربة منبه الاستيقاظ';
      btn.style.background = '';
      btn.style.color = '';
    }
  });
}

// Simple Toast Notification
function showToast(msg) {
  let toast = document.getElementById('web-toast');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'web-toast';
    toast.style.cssText = `
      position: fixed;
      bottom: 24px;
      left: 50%;
      transform: translateX(-50%);
      background: #1E293B;
      color: #FFFFFF;
      padding: 10px 20px;
      border-radius: 9999px;
      border: 1px solid #F59E0B;
      box-shadow: 0 10px 25px rgba(0,0,0,0.5);
      font-weight: 700;
      font-size: 0.88rem;
      z-index: 9999;
      transition: opacity 0.3s;
    `;
    document.body.appendChild(toast);
  }
  toast.textContent = msg;
  toast.style.opacity = '1';
  setTimeout(() => { toast.style.opacity = '0'; }, 3000);
}
