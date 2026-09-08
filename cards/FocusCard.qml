import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui

Item {
  id: root

  property var focusService: null
  property date currentDate: new Date()
  property int customMinutes: 30
  property string selectedTag: "Deep Study"

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.currentDate = new Date()
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(10)

    // Top Clock & Date Strip (Borderless)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(44)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.space(14)
        anchors.rightMargin: Style.space(14)

        Row {
          spacing: Style.space(8)
          Layout.alignment: Qt.AlignVCenter

          Text {
            text: "󰥔"
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: Qt.formatDateTime(root.currentDate, "hh:mm AP")
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: "•"
            color: Qt.darker(Color.foreground, 2.0)
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: Qt.formatDateTime(root.currentDate, "dddd, d MMMM").toUpperCase()
            color: Qt.darker(Color.foreground, 1.4)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        Item { Layout.fillWidth: true }

        // Live Status Badge
        Rectangle {
          radius: Style.cornerRadius - 2
          height: Style.space(26)
          width: statusRow.implicitWidth + Style.space(16)
          color: (root.focusService && root.focusService.active)
            ? (root.focusService.sessionType === "break" ? Qt.rgba(0.2, 0.8, 0.4, 0.2) : Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.25))
            : Style.selectedFillFor(Color.foreground, Color.accent)

          Row {
            id: statusRow
            anchors.centerIn: parent
            spacing: Style.space(6)

            Rectangle {
              width: 8
              height: 8
              radius: 4
              color: (root.focusService && root.focusService.active) ? (root.focusService.sessionType === "break" ? "#44cc77" : Color.accent) : "#888888"
              anchors.verticalCenter: parent.verticalCenter

              SequentialAnimation on opacity {
                running: root.focusService && root.focusService.active
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.3; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
              }
            }

            Text {
              text: (root.focusService && root.focusService.active)
                ? (root.focusService.sessionType === "break" ? "ON BREAK" : "STUDY ACTIVE")
                : "READY TO STUDY"
              color: (root.focusService && root.focusService.active) ? Color.foreground : Qt.darker(Color.foreground, 1.4)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }
      }
    }

    // Center Timer Hero Card (Borderless)
    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.space(6)

        // Session Icon and Title
        Row {
          Layout.alignment: Qt.AlignHCenter
          spacing: Style.space(8)

          Text {
            text: (root.focusService && root.focusService.active)
              ? (root.focusService.sessionType === "break" ? "☕" : "󰑴")
              : "🎯"
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.heading
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: (root.focusService && root.focusService.active) ? root.focusService.sessionLabel : root.selectedTag
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.heading
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        // Huge Countdown Digits
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: (root.focusService && root.focusService.active)
            ? root.focusService.remainingFormatted
            : (root.customMinutes < 10 ? "0" + root.customMinutes + ":00" : root.customMinutes + ":00")
          color: (root.focusService && root.focusService.active) ? Color.accent : Color.foreground
          font.family: Style.font.family
          font.pixelSize: Math.round(Style.font.displayLarge * 1.5)
          font.bold: true

          Behavior on color { ColorAnimation { duration: 200 } }
        }

        // Progress Bar
        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          width: Style.space(320)
          height: Style.space(7)
          radius: 3.5
          color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.1)

          Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * ((root.focusService && root.focusService.active) ? (1.0 - root.focusService.progress) : 1.0)
            radius: 3.5
            color: (root.focusService && root.focusService.sessionType === "break") ? "#44cc77" : Color.accent

            Behavior on width {
              NumberAnimation { duration: 400; easing.type: Easing.OutQuad }
            }
          }
        }

        Text {
          Layout.alignment: Qt.AlignHCenter
          text: {
            if (root.focusService && root.focusService.active) {
              if (root.focusService.sessionType === "break") {
                if (root.focusService.pausedStudy) {
                  return "☕ Break Active • Resuming '" + root.focusService.pausedStudy.label + "' when timer finishes"
                } else {
                  return "☕ Break Time • Relax & Recharge"
                }
              } else {
                return (Math.round((1.0 - root.focusService.progress) * 100)) + "% focus time left"
              }
            } else {
              return "Adjust duration below and start focus session"
            }
          }
          color: (root.focusService && root.focusService.sessionType === "break") ? "#44cc77" : Qt.darker(Color.foreground, 1.5)
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: root.focusService && root.focusService.sessionType === "break"
        }
      }
    }

    // Custom Time Stepper & Quick Tag Bar (When Idle)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(44)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)
      visible: !(root.focusService && root.focusService.active)

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.space(12)
        anchors.rightMargin: Style.space(12)
        spacing: Style.space(8)

        Text {
          text: "⏱️ Custom Time:"
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          font.bold: true
          Layout.alignment: Qt.AlignVCenter
        }

        // -5m Button
        Rectangle {
          width: Style.space(32)
          height: Style.space(28)
          radius: Style.cornerRadius - 3
          color: Style.selectedFillFor(Color.foreground, Color.accent)
          Layout.alignment: Qt.AlignVCenter

          Text {
            anchors.centerIn: parent
            text: "-5"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.customMinutes = Math.max(5, root.customMinutes - 5)
            }
          }
        }

        // Editable Minutes Display Box
        Rectangle {
          width: Style.space(72)
          height: Style.space(30)
          radius: Style.cornerRadius - 3
          color: Style.hoverFillFor(Color.foreground, Color.accent)
          Layout.alignment: Qt.AlignVCenter

          Row {
            anchors.centerIn: parent
            spacing: 2

            TextInput {
              id: customMinsInput
              text: String(root.customMinutes)
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
              inputMethodHints: Qt.ImhDigitsOnly
              selectByMouse: true
              verticalAlignment: TextInput.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              onTextEdited: {
                var val = parseInt(customMinsInput.text)
                if (!isNaN(val) && val > 0) {
                  root.customMinutes = Math.min(300, val)
                }
              }
            }

            Text {
              text: "m"
              color: Qt.darker(Color.accent, 1.3)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }

        // +5m Button
        Rectangle {
          width: Style.space(32)
          height: Style.space(28)
          radius: Style.cornerRadius - 3
          color: Style.selectedFillFor(Color.foreground, Color.accent)
          Layout.alignment: Qt.AlignVCenter

          Text {
            anchors.centerIn: parent
            text: "+5"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.customMinutes = Math.min(300, root.customMinutes + 5)
            }
          }
        }

        // +15m Button
        Rectangle {
          width: Style.space(36)
          height: Style.space(28)
          radius: Style.cornerRadius - 3
          color: Style.selectedFillFor(Color.foreground, Color.accent)
          Layout.alignment: Qt.AlignVCenter

          Text {
            anchors.centerIn: parent
            text: "+15"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.customMinutes = Math.min(300, root.customMinutes + 15)
            }
          }
        }

        Item { Layout.fillWidth: true }

        // Start Custom Session Button
        Rectangle {
          width: Style.space(120)
          height: Style.space(32)
          radius: Style.cornerRadius - 3
          color: startCustMouse.containsMouse ? Qt.lighter(Color.accent, 1.12) : Color.accent
          scale: startCustMouse.pressed ? 0.96 : 1.0
          Layout.alignment: Qt.AlignVCenter

          Row {
            anchors.centerIn: parent
            spacing: Style.space(6)
            Text {
              text: "󰐊"
              color: Color.background
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "Start (" + root.customMinutes + "m)"
              color: Color.background
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            id: startCustMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.focusService) {
                root.focusService.startSession(root.customMinutes, root.selectedTag + " (" + root.customMinutes + "m)")
              }
            }
          }
        }
      }
    }

    // Quick Sprint Preset Chips (Borderless)
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)

      Repeater {
        model: [
          { label: "25m Pomodoro", mins: 25, type: "study" },
          { label: "45m Deep Study", mins: 45, type: "study" },
          { label: "60m Marathon", mins: 60, type: "study" },
          { label: "5m Break", mins: 5, type: "break" },
          { label: "15m Break", mins: 15, type: "break" }
        ]

        Rectangle {
          Layout.fillWidth: true
          height: Style.space(32)
          radius: Style.cornerRadius - 2
          color: chipMouse.containsMouse
            ? Style.hoverFillFor(Color.foreground, Color.accent)
            : Style.normalFillFor(Color.foreground, Color.accent)
          scale: chipMouse.pressed ? 0.96 : (chipMouse.containsMouse ? 1.02 : 1.0)

          Behavior on scale { NumberAnimation { duration: 120 } }
          Behavior on color { ColorAnimation { duration: 120 } }

          Text {
            anchors.centerIn: parent
            text: modelData.label
            color: chipMouse.containsMouse ? Color.accent : Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          MouseArea {
            id: chipMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.focusService) {
                if (modelData.type === "break") {
                  root.focusService.startBreak(modelData.mins)
                } else {
                  root.focusService.startSession(modelData.mins, modelData.label)
                }
              }
            }
          }
        }
      }
    }

    // Main Bottom Action Buttons (Borderless)
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)

      // Break Active State: Resume Focus (Primary Accent)
      Rectangle {
        Layout.fillWidth: true
        height: Style.space(42)
        radius: Style.cornerRadius
        visible: root.focusService && root.focusService.active && root.focusService.sessionType === "break"
        color: btnResumeMouse.containsMouse ? Qt.lighter(Color.accent, 1.15) : Color.accent
        scale: btnResumeMouse.pressed ? 0.97 : 1.0

        Behavior on scale { NumberAnimation { duration: 120 } }
        Behavior on color { ColorAnimation { duration: 150 } }

        Row {
          anchors.centerIn: parent
          spacing: Style.space(8)

          Text {
            text: "▶️"
            color: Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: "Resume Focus Now"
            color: Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          id: btnResumeMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.focusService) root.focusService.resumeSession()
          }
        }
      }

      // Study Active State: End Session (Red) / Idle: Start 25m Sprint
      Rectangle {
        Layout.fillWidth: true
        height: Style.space(42)
        radius: Style.cornerRadius
        visible: !(root.focusService && root.focusService.active && root.focusService.sessionType === "break")
        color: (root.focusService && root.focusService.active)
          ? (btnStopMouse.containsMouse ? "#ff3344" : "#dd2233")
          : (btnStartMouse.containsMouse ? Qt.lighter(Color.accent, 1.15) : Color.accent)
        scale: (btnStartMouse.pressed || btnStopMouse.pressed) ? 0.97 : 1.0

        Behavior on scale { NumberAnimation { duration: 120 } }
        Behavior on color { ColorAnimation { duration: 150 } }

        Row {
          anchors.centerIn: parent
          spacing: Style.space(8)

          Text {
            text: (root.focusService && root.focusService.active) ? "󰓛" : "󰐊"
            color: (root.focusService && root.focusService.active) ? "#ffffff" : Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: (root.focusService && root.focusService.active)
              ? "End Study Session"
              : "Start 25-Min Sprint"
            color: (root.focusService && root.focusService.active) ? "#ffffff" : Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          id: btnStartMouse
          anchors.fill: parent
          visible: !(root.focusService && root.focusService.active)
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.focusService) root.focusService.startSession(25, "Pomodoro Sprint")
          }
        }

        MouseArea {
          id: btnStopMouse
          anchors.fill: parent
          visible: (root.focusService && root.focusService.active && root.focusService.sessionType !== "break")
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.focusService) root.focusService.stopSession()
          }
        }
      }

      // Extend +10 Mins Button (Visible when active in study mode)
      Rectangle {
        Layout.preferredWidth: Style.space(110)
        height: Style.space(42)
        radius: Style.cornerRadius
        visible: root.focusService && root.focusService.active && root.focusService.sessionType === "study"
        color: btnExtMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.normalFillFor(Color.foreground, Color.accent)
        scale: btnExtMouse.pressed ? 0.97 : 1.0

        Behavior on scale { NumberAnimation { duration: 120 } }

        Row {
          anchors.centerIn: parent
          spacing: Style.space(6)

          Text {
            text: "󱓞"
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: "+10m"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          id: btnExtMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.focusService) root.focusService.extendSession(10)
          }
        }
      }

      // Switch to Quick 5m Break Button (Visible when active in study mode)
      Rectangle {
        Layout.preferredWidth: Style.space(110)
        height: Style.space(42)
        radius: Style.cornerRadius
        visible: root.focusService && root.focusService.active && root.focusService.sessionType === "study"
        color: btnBreakMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.normalFillFor(Color.foreground, Color.accent)
        scale: btnBreakMouse.pressed ? 0.97 : 1.0

        Behavior on scale { NumberAnimation { duration: 120 } }

        Row {
          anchors.centerIn: parent
          spacing: Style.space(6)

          Text {
            text: "☕"
            font.pixelSize: Style.font.bodySmall
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: "5m Break"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          id: btnBreakMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.focusService) root.focusService.startBreak(5)
          }
        }
      }

      // During Break: +5m Break & End Session buttons
      Rectangle {
        Layout.preferredWidth: Style.space(100)
        height: Style.space(42)
        radius: Style.cornerRadius
        visible: root.focusService && root.focusService.active && root.focusService.sessionType === "break"
        color: btnExtBreakMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.normalFillFor(Color.foreground, Color.accent)
        scale: btnExtBreakMouse.pressed ? 0.97 : 1.0

        Row {
          anchors.centerIn: parent
          spacing: Style.space(6)
          Text {
            text: "☕"
            font.pixelSize: Style.font.bodySmall
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            text: "+5m Break"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          id: btnExtBreakMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.focusService) root.focusService.extendSession(5)
          }
        }
      }

      Rectangle {
        Layout.preferredWidth: Style.space(80)
        height: Style.space(42)
        radius: Style.cornerRadius
        visible: root.focusService && root.focusService.active && root.focusService.sessionType === "break"
        color: btnStopBreakMouse.containsMouse ? "#ff3344" : "#dd2233"
        scale: btnStopBreakMouse.pressed ? 0.97 : 1.0

        Row {
          anchors.centerIn: parent
          spacing: Style.space(4)
          Text {
            text: "󰓛"
            color: "#ffffff"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            text: "Stop"
            color: "#ffffff"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          id: btnStopBreakMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.focusService) root.focusService.stopSession()
          }
        }
      }
    }
  }
}
