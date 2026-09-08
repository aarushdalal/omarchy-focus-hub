import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "services"

BarWidget {
  id: root
  moduleName: "daemon0.focus-hub"

  FocusService {
    id: focusService
    dashboardOpen: root.opened
  }

  IpcHandler {
    target: "daemon0.focus-hub"
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
  }

  // Popup open/close shape contract for shell/bar
  readonly property bool opened: dashboard.open
  function open() { dashboard.open = true }
  function close() { dashboard.open = false }
  function toggle() { dashboard.open = !dashboard.open }

  implicitWidth: islandSurface.implicitWidth
  implicitHeight: root.barSize

  // The Taskbar Island Pill (Borderless, matching omni-center styling)
  BorderSurface {
    id: islandSurface
    anchors.centerIn: parent
    implicitWidth: rowLayout.implicitWidth + Style.space(18)
    height: Math.max(14, root.barSize - Style.space(2))
    radius: Style.cornerRadius
    color: islandMouse.containsMouse
      ? Style.hoverFillFor(root.bar ? root.bar.barForeground : Color.bar.text, Color.accent)
      : (root.opened || focusService.active
          ? Style.selectedFillFor(root.bar ? root.bar.barForeground : Color.bar.text, Color.accent)
          : Style.normalFillFor(root.bar ? root.bar.barForeground : Color.bar.text, Color.accent))
    borderSpec: Border.none()
    border.width: 0
    scale: islandMouse.pressed ? Motion.pressScale : (islandMouse.containsMouse ? (1.0 + 0.04 * Motion.springOvershoot) : 1.0)

    Behavior on scale { NumberAnimation { duration: Motion.micro; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
    Behavior on color { ColorAnimation { duration: Motion.micro; easing.type: Motion.easeStandard } }

    Row {
      id: rowLayout
      anchors.centerIn: parent
      spacing: Style.space(6)

      // Pulsing Active Dot or Icon
      Item {
        width: Style.bar.iconCanvas
        height: Style.bar.iconCanvas
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: focusService.active ? (focusService.sessionType === "break" ? "☕" : "󰑴") : "󰑴"
          color: focusService.active ? Color.accent : Qt.darker(root.bar ? root.bar.barForeground : Color.bar.text, 1.4)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.bar.iconFont
          anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
          anchors.right: parent.right
          anchors.top: parent.top
          width: 5
          height: 5
          radius: 2.5
          color: Color.accent
          visible: focusService.active

          SequentialAnimation on opacity {
            running: focusService.active
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.2; duration: 600 }
            NumberAnimation { from: 0.2; to: 1.0; duration: 600 }
          }
        }
      }

      // Live Time or FOCUS Label
      Text {
        text: focusService.active ? focusService.remainingFormatted : "FOCUS"
        color: focusService.active ? Color.accent : (root.bar ? root.bar.barForeground : Color.bar.text)
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.bodySmall
        font.bold: focusService.active
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color { ColorAnimation { duration: 150 } }
      }
    }

    MouseArea {
      id: islandMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: function(mouse) {
        if (mouse.button === Qt.LeftButton) {
          root.toggle()
        } else if (mouse.button === Qt.RightButton) {
          if (focusService.active) {
            focusService.stopSession()
          } else {
            focusService.startSession(25, "Pomodoro Sprint")
          }
        }
      }

      onWheel: function(wheel) {
        if (!root.opened) {
          root.open()
        }
        dashboard.handleWheel(wheel)
      }
    }
  }

  FocusDashboard {
    id: dashboard
    anchorItem: islandSurface
    owner: root
    bar: root.bar
    focusService: focusService
    anchorHovered: islandMouse.containsMouse
  }
}
