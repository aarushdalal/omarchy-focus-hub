import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property bool active: false
  property string sessionType: "none"
  property string sessionLabel: "Idle"
  property int remainingSeconds: 0
  property string remainingFormatted: "00:00"
  property real progress: 0.0
  property int totalSeconds: 0

  property string activeWindowClass: ""
  property string activeWindowTitle: ""

  property var allowedDomains: []
  property var blockedDomains: []
  property var allowedApps: []
  property bool strictWhitelist: false
  property bool soundAlerts: true
  property var installedApps: []
  property var pausedStudy: null
  property real lastCompletionTimestamp: 0

  signal sessionCompleted(var rewardData)

  property int todayMinutes: 0
  property int todaySessions: 0

  property bool dashboardOpen: false

  function refresh() {
    if (!collectorProc.running) {
      collectorProc.running = true
    }
  }

  onDashboardOpenChanged: {
    if (dashboardOpen) {
      refresh()
      pollTimer.interval = 1000
    } else {
      pollTimer.interval = root.active ? 1000 : 3000
    }
  }

  onActiveChanged: {
    pollTimer.interval = (root.active || root.dashboardOpen) ? 1000 : 3000
  }

  Timer {
    id: pollTimer
    interval: (root.active || root.dashboardOpen) ? 1000 : 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Process {
    id: collectorProc
    command: [Quickshell.env("HOME") + "/.config/omarchy/plugins/daemon0.focus-hub/services/focus-helper.sh"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (!text || text.trim() === "") return
        try {
          var data = JSON.parse(text.trim())
          root.active = data.active === true
          root.sessionType = data.type || "none"
          root.sessionLabel = data.label || "Idle"
          root.remainingSeconds = data.remaining_seconds || 0
          root.remainingFormatted = data.remaining_formatted || "00:00"
          root.progress = data.progress || 0.0
          root.totalSeconds = data.total_seconds || 0

          if (data.active_window) {
            root.activeWindowClass = data.active_window.class || ""
            root.activeWindowTitle = data.active_window.title || ""
          }

          root.allowedDomains = data.allowed_domains || []
          root.blockedDomains = data.blocked_domains || []
          root.allowedApps = data.allowed_apps || []
          root.strictWhitelist = data.strict_website_whitelist === true
          root.soundAlerts = data.sound_alerts !== false
          root.installedApps = data.installed_apps || []
          root.pausedStudy = data.paused_study || null

          if (data.stats) {
            root.todayMinutes = data.stats.today_minutes || 0
            root.todaySessions = data.stats.today_sessions || 0
          }

          // Reward Celebration Detection
          if (data.completion && data.completion.timestamp) {
            var cTime = data.completion.timestamp
            if (root.lastCompletionTimestamp > 0 && cTime > root.lastCompletionTimestamp) {
              root.lastCompletionTimestamp = cTime
              root.sessionCompleted(data.completion)
            } else if (root.lastCompletionTimestamp === 0) {
              // Initial load - record timestamp without re-triggering old events unless very recent (< 10s)
              var nowSecs = Date.now() / 1000
              if (nowSecs - cTime < 10) {
                root.sessionCompleted(data.completion)
              }
              root.lastCompletionTimestamp = cTime
            }
          }
        } catch (e) {
          console.warn("Error parsing focus-helper data:", e)
        }
      }
    }
  }

  // Reliable, permanent command execution engine
  Process {
    id: execProc
    onExited: function(code) {
      root.refresh()
    }
  }

  function runCmd(args) {
    if (execProc.running) {
      execProc.running = false
    }
    execProc.command = args
    execProc.running = true
    Qt.callLater(function() {
      root.refresh()
    })
  }

  function startSession(minutes, label) {
    var lbl = label || "Study Focus"
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "start", String(minutes), lbl])
  }

  function startBreak(minutes) {
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "break", String(minutes)])
  }

  function resumeSession() {
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "resume"])
  }

  function triggerRewardTest() {
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "trigger-reward"])
  }

  function stopSession() {
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "stop"])
  }

  function extendSession(minutes) {
    var mins = minutes || 10
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "extend", String(mins)])
  }

  function allowActiveWindow() {
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "allow-current"])
  }

  function addAllowedDomain(domain) {
    if (!domain || domain.trim() === "") return
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "allow-site", domain.trim()])
  }

  function removeAllowedDomain(domain) {
    if (!domain || domain.trim() === "") return
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "disallow-site", domain.trim()])
  }

  function addBlockedDomain(domain) {
    if (!domain || domain.trim() === "") return
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "block-domain", domain.trim()])
  }

  function removeBlockedDomain(domain) {
    if (!domain || domain.trim() === "") return
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "unblock-domain", domain.trim()])
  }

  function addAllowedApp(app) {
    if (!app || app.trim() === "") return
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "allow", app.trim()])
  }

  function removeAllowedApp(app) {
    if (!app || app.trim() === "") return
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "disallow", app.trim()])
  }

  function toggleStrictWhitelist() {
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "toggle-strict"])
  }

  function toggleSoundAlerts() {
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "toggle-sound"])
  }

  function resetStats() {
    runCmd(["Quickshell.env("HOME") + "/.local/bin/omarchy-focus-hub"", "reset-stats"])
  }
}
