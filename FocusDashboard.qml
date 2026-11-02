import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "components/polish" as Polish
import "cards"
import "services"

Polish.RefinedKeyboardPanel {
  id: root

  property var focusService: null
  property int activeTabIndex: 0 // 0: Focus, 1: Websites, 2: Apps, 3: Ambience, 4: Stats
  property bool anchorHovered: false
  onActiveTabIndexChanged: {
    var bounded = Math.max(0, Math.min(4, activeTabIndex))
    if (activeTabIndex !== bounded) activeTabIndex = bounded
  }

  contentWidth: Style.space(560)
  contentHeight: Style.space(438)
  borderSpec: Border.none()
  focusTarget: mainCanvas

  function show() { root.open = true }
  function hide() { root.close() }
  function toggle() { root.open ? root.close() : (root.open = true) }

  // High-Precision Trackpad & Mouse Wheel Navigator across 5 tabs
  property real wheelAccumulator: 0
  property real lastWheelEventTime: 0
  property real lastTriggerTime: 0
  readonly property real wheelThreshold: 20

  function handleWheel(wheelOrDelta) {
    var now = Date.now()
    var dy = 0
    var dx = 0

    if (typeof wheelOrDelta === "number") {
      dy = wheelOrDelta
    } else if (wheelOrDelta && typeof wheelOrDelta === "object") {
      if (wheelOrDelta.angleDelta) {
        dy = wheelOrDelta.angleDelta.y || 0
        dx = wheelOrDelta.angleDelta.x || 0
      }
      if (dy === 0 && dx === 0 && wheelOrDelta.pixelDelta) {
        dy = (wheelOrDelta.pixelDelta.y || 0) * 4
        dx = (wheelOrDelta.pixelDelta.x || 0) * 4
      }
    }

    if (dy === 0 && dx === 0) return

    // Reset accumulator on finger lift / pause (> 220ms)
    if (now - lastWheelEventTime > 220) {
      wheelAccumulator = 0
    }
    lastWheelEventTime = now

    // Cooldown prevents momentum fling from skipping multiple tabs
    if (now - lastTriggerTime < 240) {
      return
    }

    var dominant = Math.abs(dx) > Math.abs(dy) ? dx : dy
    wheelAccumulator += dominant

    if (wheelAccumulator >= wheelThreshold) {
      wheelAccumulator = 0
      lastTriggerTime = now
      root.activeTabIndex = (root.activeTabIndex - 1 + 5) % 5
    } else if (wheelAccumulator <= -wheelThreshold) {
      wheelAccumulator = 0
      lastTriggerTime = now
      root.activeTabIndex = (root.activeTabIndex + 1) % 5
    }
  }

  // MouseArea at root of panel for frictionless scroll detection
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    onWheel: function(wheel) {
      root.handleWheel(wheel)
    }
  }

  // Main UI Canvas
  Item {
    id: mainCanvas
    anchors.fill: parent
    focus: true

    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Escape) root.close()
      else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5) root.activeTabIndex = event.key - Qt.Key_1
      else if (event.key === Qt.Key_Tab) root.activeTabIndex = (root.activeTabIndex + (event.modifiers & Qt.ShiftModifier ? 4 : 1)) % 5
      else return
      event.accepted = true
    }

    // Top Segmented Tab Switcher with Gliding Pill Indicator (Borderless)
    Polish.DashboardTabs {
      id: tabSwitcher
      anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
      height: implicitHeight
      title: "Focus Hub"
      currentIndex: root.activeTabIndex
      motionEnabled: root.open
      tabs: [
        { icon: "󰑴", label: "Focus", index: 0 },
        { icon: "🌐", label: "Websites", index: 1 },
        { icon: "📱", label: "Apps", index: 2 },
        { icon: "󰠵", label: "Ambience", index: 3 },
        { icon: "󰄬", label: "Stats", index: 4 }
      ]
      onSelectionRequested: function(index) { root.activeTabIndex = index }
    }

    // Horizontal Sliding Carousel Stack with Depth Perspective
    Item {
      id: carouselStack
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: tabSwitcher.bottom
      anchors.bottom: parent.bottom
      anchors.topMargin: Style.space(8)
      clip: true

      // Card 0: Focus
      Polish.DashboardPage {
        width: carouselStack.width
        height: carouselStack.height
        pageIndex: 0; selectedIndex: root.activeTabIndex
        motionEnabled: root.open && !Polish.MotionAdapter.reducedMotion
        enabled: selected && root.open

        FocusCard {
          anchors.fill: parent
          focusService: root.focusService
        }
      }

      // Card 1: Websites
      Polish.DashboardPage {
        width: carouselStack.width
        height: carouselStack.height
        pageIndex: 1; selectedIndex: root.activeTabIndex
        motionEnabled: root.open && !Polish.MotionAdapter.reducedMotion
        enabled: selected && root.open

        WebsitesCard {
          anchors.fill: parent
          focusService: root.focusService
        }
      }

      // Card 2: Apps
      Polish.DashboardPage {
        width: carouselStack.width
        height: carouselStack.height
        pageIndex: 2; selectedIndex: root.activeTabIndex
        motionEnabled: root.open && !Polish.MotionAdapter.reducedMotion
        enabled: selected && root.open

        AppsCard {
          anchors.fill: parent
          focusService: root.focusService
        }
      }

      // Card 3: Ambience
      Polish.DashboardPage {
        width: carouselStack.width
        height: carouselStack.height
        pageIndex: 3; selectedIndex: root.activeTabIndex
        motionEnabled: root.open && !Polish.MotionAdapter.reducedMotion
        enabled: selected && root.open

        AmbienceCard {
          anchors.fill: parent
          focusService: root.focusService
        }
      }

      // Card 4: Stats
      Polish.DashboardPage {
        width: carouselStack.width
        height: carouselStack.height
        pageIndex: 4; selectedIndex: root.activeTabIndex
        motionEnabled: root.open && !Polish.MotionAdapter.reducedMotion
        enabled: selected && root.open

        StatsCard {
          anchors.fill: parent
          focusService: root.focusService
        }
      }
    }

    // Celebration Reward Animation Overlay
    RewardCelebration {
      id: rewardOverlay
      anchors.fill: parent
      focusService: root.focusService
      z: 9999
    }
  }
}
