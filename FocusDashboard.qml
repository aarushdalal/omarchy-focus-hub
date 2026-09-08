import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "cards"
import "services"

KeyboardPanel {
  id: root

  property var focusService: null
  property int activeTabIndex: 0 // 0: Focus, 1: Websites, 2: Apps, 3: Ambience, 4: Stats
  property bool anchorHovered: false

  contentWidth: Style.space(560)
  contentHeight: Style.space(430)
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

    // Top Segmented Tab Switcher with Gliding Pill Indicator (Borderless)
    Rectangle {
      id: tabSwitcher
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      height: Style.space(40)
      radius: Style.cornerRadius
      color: Style.normalFillFor(root.bar ? root.bar.barForeground : Color.foreground, Color.accent)

      readonly property var tabs: [
        { icon: "󰑴", label: "Focus", index: 0 },
        { icon: "🌐", label: "Websites", index: 1 },
        { icon: "📱", label: "Apps", index: 2 },
        { icon: "󰠵", label: "Ambience", index: 3 },
        { icon: "󰄬", label: "Stats", index: 4 }
      ]

      readonly property real singleTabWidth: (tabSwitcher.width - Style.space(6) - (tabSwitcher.tabs.length - 1) * Style.space(4)) / tabSwitcher.tabs.length

      // Smooth Sliding Active Pill Indicator (Borderless)
      Rectangle {
        id: activePill
        y: Style.space(3)
        height: tabSwitcher.height - Style.space(6)
        width: tabSwitcher.singleTabWidth
        x: Style.space(3) + root.activeTabIndex * (tabSwitcher.singleTabWidth + Style.space(4))
        radius: Style.cornerRadius - 2
        color: Style.selectedFillFor(root.bar ? root.bar.barForeground : Color.foreground, Color.accent)

        Behavior on x {
          NumberAnimation { duration: 280; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
        }
      }

      Row {
        id: tabsRow
        anchors.fill: parent
        anchors.margins: Style.space(3)
        spacing: Style.space(4)

        Repeater {
          model: tabSwitcher.tabs

          Item {
            id: tabItem
            width: tabSwitcher.singleTabWidth
            height: tabsRow.height
            readonly property bool isSelected: root.activeTabIndex === modelData.index

            Rectangle {
              anchors.fill: parent
              radius: Style.cornerRadius - 2
              color: tabMouse.containsMouse && !tabItem.isSelected
                ? Style.hoverFillFor(root.bar ? root.bar.barForeground : Color.foreground, Color.accent)
                : "transparent"

              Behavior on color { ColorAnimation { duration: 150 } }

              Row {
                anchors.centerIn: parent
                spacing: Style.space(6)

                Text {
                  id: iconText
                  text: modelData.icon
                  color: tabItem.isSelected ? Color.accent : Qt.darker(root.bar ? root.bar.barForeground : Color.foreground, 1.5)
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: Style.font.caption + 1
                  anchors.verticalCenter: parent.verticalCenter
                  scale: tabItem.isSelected ? 1.15 : (tabMouse.containsMouse ? 1.06 : 1.0)

                  Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                  Behavior on color { ColorAnimation { duration: 150 } }
                }

                Text {
                  id: labelText
                  text: modelData.label
                  color: tabItem.isSelected ? Color.accent : Qt.darker(root.bar ? root.bar.barForeground : Color.foreground, 1.4)
                  font.family: root.bar ? root.bar.fontFamily : Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  font.bold: tabItem.isSelected
                  anchors.verticalCenter: parent.verticalCenter

                  Behavior on color { ColorAnimation { duration: 150 } }
                }
              }

              MouseArea {
                id: tabMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.activeTabIndex = modelData.index
                onWheel: function(wheel) {
                  root.handleWheel(wheel)
                }
              }
            }
          }
        }
      }
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
      Item {
        width: carouselStack.width
        height: carouselStack.height
        x: (0 - root.activeTabIndex) * carouselStack.width
        scale: root.activeTabIndex === 0 ? 1.0 : 0.94
        opacity: Math.max(0.0, 1.0 - Math.abs(0 - root.activeTabIndex) * 0.8)
        visible: Math.abs(0 - root.activeTabIndex) <= 1

        Behavior on x { NumberAnimation { duration: Motion.entryDuration; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        FocusCard {
          anchors.fill: parent
          focusService: root.focusService
        }
      }

      // Card 1: Websites
      Item {
        width: carouselStack.width
        height: carouselStack.height
        x: (1 - root.activeTabIndex) * carouselStack.width
        scale: root.activeTabIndex === 1 ? 1.0 : 0.94
        opacity: Math.max(0.0, 1.0 - Math.abs(1 - root.activeTabIndex) * 0.8)
        visible: Math.abs(1 - root.activeTabIndex) <= 1

        Behavior on x { NumberAnimation { duration: Motion.entryDuration; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        WebsitesCard {
          anchors.fill: parent
          focusService: root.focusService
        }
      }

      // Card 2: Apps
      Item {
        width: carouselStack.width
        height: carouselStack.height
        x: (2 - root.activeTabIndex) * carouselStack.width
        scale: root.activeTabIndex === 2 ? 1.0 : 0.94
        opacity: Math.max(0.0, 1.0 - Math.abs(2 - root.activeTabIndex) * 0.8)
        visible: Math.abs(2 - root.activeTabIndex) <= 1

        Behavior on x { NumberAnimation { duration: Motion.entryDuration; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        AppsCard {
          anchors.fill: parent
          focusService: root.focusService
        }
      }

      // Card 3: Ambience
      Item {
        width: carouselStack.width
        height: carouselStack.height
        x: (3 - root.activeTabIndex) * carouselStack.width
        scale: root.activeTabIndex === 3 ? 1.0 : 0.94
        opacity: Math.max(0.0, 1.0 - Math.abs(3 - root.activeTabIndex) * 0.8)
        visible: Math.abs(3 - root.activeTabIndex) <= 1

        Behavior on x { NumberAnimation { duration: Motion.entryDuration; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        AmbienceCard {
          anchors.fill: parent
          focusService: root.focusService
        }
      }

      // Card 4: Stats
      Item {
        width: carouselStack.width
        height: carouselStack.height
        x: (4 - root.activeTabIndex) * carouselStack.width
        scale: root.activeTabIndex === 4 ? 1.0 : 0.94
        opacity: Math.max(0.0, 1.0 - Math.abs(4 - root.activeTabIndex) * 0.8)
        visible: Math.abs(4 - root.activeTabIndex) <= 1

        Behavior on x { NumberAnimation { duration: Motion.entryDuration; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

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
