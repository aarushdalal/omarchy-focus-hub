import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property var focusService: null
  property bool active: false
  property int rewardMinutes: 25
  property string rewardLabel: "Pomodoro Sprint"
  property int confettiCount: 42

  visible: opacity > 0.001
  opacity: active ? 1.0 : 0.0

  Behavior on opacity {
    NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
  }

  Process {
    id: soundProc
  }

  function playRewardSound() {
    var soundPath = Quickshell.env("HOME") + "/.config/omarchy/plugins/daemon0.focus-hub/sounds/reward.wav"
    soundProc.command = ["pw-play", soundPath]
    soundProc.running = true
  }

  function triggerReward(mins, label) {
    rewardMinutes = mins || (focusService ? Math.max(1, Math.round(focusService.totalSeconds / 60)) : 25)
    rewardLabel = label || "Focus Session"
    active = true
    playRewardSound()
    confettiTimer.restart()
    autoDismissTimer.restart()
  }

  function dismiss() {
    active = false
  }

  Connections {
    target: root.focusService
    function onSessionCompleted(rewardData) {
      if (rewardData) {
        root.triggerReward(rewardData.minutes, rewardData.label)
      } else {
        root.triggerReward(25, "Focus Session")
      }
    }
  }

  Timer {
    id: autoDismissTimer
    interval: 9000
    repeat: false
    onTriggered: root.dismiss()
  }

  Timer {
    id: confettiTimer
    interval: 16
    running: root.active
    repeat: true
    onTriggered: {
      for (var i = 0; i < confettiRepeater.count; i++) {
        var item = confettiRepeater.itemAt(i)
        if (item) item.updatePhysics()
      }
    }
  }

  // Darkened Glass Backdrop
  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0.04, 0.04, 0.08, 0.88)
    radius: Style.cornerRadius

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }
  }

  // Confetti Particle System
  Item {
    id: confettiCanvas
    anchors.fill: parent
    clip: true

    Repeater {
      id: confettiRepeater
      model: root.confettiCount

      Item {
        id: particle
        property real posX: Math.random() * confettiCanvas.width
        property real posY: Math.random() * -100
        property real velX: (Math.random() - 0.5) * 8.0
        property real velY: Math.random() * 4.0 + 3.0
        property real rot: Math.random() * 360
        property real rotSpeed: (Math.random() - 0.5) * 16.0
        property real pScale: Math.random() * 0.5 + 0.75
        property string pType: ["square", "ribbon", "star", "circle"][Math.floor(Math.random() * 4)]
        property color pColor: [
          "#FFD700", "#FFC107", "#FF9100", "#00E5FF", "#00E676",
          "#FF1744", "#D500F9", "#E040FB", "#76FF03", "#FFFFFF"
        ][Math.floor(Math.random() * 10)]

        x: posX
        y: posY
        rotation: rot
        scale: pScale
        opacity: Math.min(1.0, Math.max(0.0, (confettiCanvas.height - posY) / 100.0))

        function reset() {
          posX = confettiCanvas.width / 2 + (Math.random() - 0.5) * 120
          posY = confettiCanvas.height / 2 + (Math.random() - 0.5) * 40
          var angle = (Math.random() * Math.PI * 2)
          var speed = Math.random() * 9.0 + 4.0
          velX = Math.cos(angle) * speed
          velY = Math.sin(angle) * speed - 5.0
          rot = Math.random() * 360
        }

        function updatePhysics() {
          posX += velX
          posY += velY
          velY += 0.22 // gravity
          velX *= 0.98 // air drag
          rot += rotSpeed

          // Wrap or flutter
          if (posY > confettiCanvas.height + 20) {
            posY = -20
            posX = Math.random() * confettiCanvas.width
            velY = Math.random() * 3.5 + 2.0
          }
        }

        onVisibleChanged: {
          if (visible) reset()
        }

        // Particle Shape
        Rectangle {
          width: particle.pType === "ribbon" ? 14 : 9
          height: particle.pType === "ribbon" ? 4 : 9
          radius: particle.pType === "circle" ? 4.5 : (particle.pType === "star" ? 2 : 1)
          color: particle.pColor
          visible: particle.pType !== "star"
        }

        Text {
          text: "★"
          color: particle.pColor
          font.pixelSize: 13
          visible: particle.pType === "star"
          anchors.centerIn: parent
        }
      }
    }
  }

  // Glowing Trophy Card Modal
  Rectangle {
    id: trophyCard
    anchors.centerIn: parent
    width: Style.space(380)
    height: Style.space(270)
    radius: Style.cornerRadius + 4
    color: Qt.rgba(0.10, 0.10, 0.16, 0.98)
    border.width: 0
    scale: root.active ? 1.0 : 0.7
    opacity: root.active ? 1.0 : 0.0

    Behavior on scale {
      NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 1.3 }
    }
    Behavior on opacity {
      NumberAnimation { duration: 240; easing.type: Easing.OutQuad }
    }

    // Outer Golden Glow
    Rectangle {
      anchors.centerIn: parent
      width: parent.width + Style.space(16)
      height: parent.height + Style.space(16)
      radius: parent.radius + 6
      color: "transparent"
      border.width: 2
      border.color: Qt.rgba(1.0, 0.84, 0.0, 0.35)
      z: -1

      SequentialAnimation on opacity {
        running: root.active
        loops: Animation.Infinite
        NumberAnimation { from: 0.3; to: 0.8; duration: 900; easing.type: Easing.InOutQuad }
        NumberAnimation { from: 0.8; to: 0.3; duration: 900; easing.type: Easing.InOutQuad }
      }
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.space(18)
      spacing: Style.space(10)

      // Giant Sparkling Trophy Icon with Pulsing Halo
      Item {
        Layout.alignment: Qt.AlignHCenter
        width: Style.space(64)
        height: Style.space(64)

        Rectangle {
          anchors.centerIn: parent
          width: Style.space(56)
          height: Style.space(56)
          radius: Style.space(28)
          color: Qt.rgba(1.0, 0.84, 0.0, 0.18)

          SequentialAnimation on scale {
            running: root.active
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 1.15; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.15; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
          }
        }

        Text {
          anchors.centerIn: parent
          text: "🏆"
          font.pixelSize: Style.space(38)
        }
      }

      // Title & Subtitle
      Column {
        Layout.alignment: Qt.AlignHCenter
        spacing: Style.space(3)

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: "🎉 SPRINT COMPLETED!"
          color: "#FFD700"
          font.family: Style.font.family
          font.pixelSize: Style.font.title
          font.bold: true
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: "+" + root.rewardMinutes + " Minutes of Deep Work Logged"
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          font.bold: true
        }
      }

      // Stats Ribbon
      Rectangle {
        Layout.fillWidth: true
        height: Style.space(36)
        radius: Style.cornerRadius - 2
        color: Style.selectedFillFor(Color.foreground, Color.accent)

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: Style.space(12)
          anchors.rightMargin: Style.space(12)

          Text {
            text: "🎯 " + root.rewardLabel
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
          }

          Text {
            text: "📈 Today: " + (root.focusService ? root.focusService.todayMinutes : 0) + "m"
            color: Qt.darker(Color.foreground, 1.3)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }
      }

      // Claim Reward & Continue Button
      Rectangle {
        Layout.fillWidth: true
        height: Style.space(38)
        radius: Style.cornerRadius - 2
        color: claimBtnMouse.containsMouse ? Qt.lighter(Color.accent, 1.15) : Color.accent
        scale: claimBtnMouse.pressed ? 0.97 : 1.0

        Behavior on scale { NumberAnimation { duration: 120 } }
        Behavior on color { ColorAnimation { duration: 150 } }

        Row {
          anchors.centerIn: parent
          spacing: Style.space(6)

          Text {
            text: "󰄬"
            color: Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: "Claim Reward & Continue"
            color: Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        MouseArea {
          id: claimBtnMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.dismiss()
        }
      }
    }
  }
}
