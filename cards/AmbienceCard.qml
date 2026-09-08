import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property var focusService: null

  // Ambient sound generator via mpv lavfi
  property bool ambiencePlaying: false
  property string currentAmbience: "rain" // "rain", "whitenoise", "binaural"

  function toggleAmbience(track) {
    if (ambiencePlaying && currentAmbience === track) {
      ambiencePlaying = false
      stopAmbienceProc.running = true
    } else {
      currentAmbience = track
      ambiencePlaying = true
      startAmbienceProc.running = true
    }
  }

  Process {
    id: startAmbienceProc
    command: [
      "bash", "-c",
      "pkill -f 'omarchy-ambient-sound' 2>/dev/null || true; " +
      "case '" + root.currentAmbience + "' in " +
      "  rain) mpv --no-video --title='omarchy-ambient-sound' --loop av://lavfi:anoisesrc=c=pink:a=0.06 2>/dev/null & ;; " +
      "  whitenoise) mpv --no-video --title='omarchy-ambient-sound' --loop av://lavfi:anoisesrc=c=brown:a=0.06 2>/dev/null & ;; " +
      "  binaural) mpv --no-video --title='omarchy-ambient-sound' --loop av://lavfi:anoisesrc=c=white:a=0.03 2>/dev/null & ;; " +
      "esac"
    ]
  }

  Process {
    id: stopAmbienceProc
    command: ["bash", "-c", "pkill -f 'omarchy-ambient-sound' 2>/dev/null || true"]
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(12)

    // Ambient Sound Generator Card (Borderless)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(110)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(12)
        spacing: Style.space(8)

        RowLayout {
          Layout.fillWidth: true
          Row {
            spacing: Style.space(8)
            Text {
              text: "󰝚"
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "Focus Ambient Background Sound"
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }
          Item { Layout.fillWidth: true }
          Text {
            text: root.ambiencePlaying ? "PLAYING" : "OFF"
            color: root.ambiencePlaying ? Color.accent : Qt.darker(Color.foreground, 1.6)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(8)

          Repeater {
            model: [
              { id: "rain", label: "🌧️ Deep Rain", icon: "🌧️" },
              { id: "whitenoise", label: "🌊 Brown Noise", icon: "🌊" },
              { id: "binaural", label: "🧘 Alpha Waves", icon: "🧘" }
            ]

            Rectangle {
              Layout.fillWidth: true
              height: Style.space(38)
              radius: Style.cornerRadius - 2
              readonly property bool isSelected: root.ambiencePlaying && root.currentAmbience === modelData.id
              color: isSelected
                ? Style.selectedFillFor(Color.foreground, Color.accent)
                : (cardMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.normalFillFor(Color.foreground, Color.accent))

              Row {
                anchors.centerIn: parent
                spacing: Style.space(6)
                Text {
                  text: modelData.label
                  color: isSelected ? Color.accent : Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: isSelected
                }
              }

              MouseArea {
                id: cardMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleAmbience(modelData.id)
              }
            }
          }
        }
      }
    }

    // Toggle Toggles Grid (Borderless)
    GridLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      columns: 2
      rowSpacing: Style.space(10)
      columnSpacing: Style.space(10)

      // Sound Chimes Alert Toggle (Borderless)
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Style.cornerRadius
        color: Style.normalFillFor(Color.foreground, Color.accent)

        RowLayout {
          anchors.fill: parent
          anchors.margins: Style.space(14)

          Column {
            Layout.fillWidth: true
            spacing: Style.space(4)
            Text {
              text: "🔔 Sound Chimes"
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
            }
            Text {
              text: "Play audio alert when session starts or blocked site is opened"
              color: Qt.darker(Color.foreground, 1.5)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              wrapMode: Text.WordWrap
              width: Style.space(170)
            }
          }

          Rectangle {
            width: Style.space(52)
            height: Style.space(26)
            radius: Style.cornerRadius - 2
            color: (root.focusService && root.focusService.soundAlerts) ? Color.accent : Style.selectedFillFor(Color.foreground, Color.accent)

            Text {
              anchors.centerIn: parent
              text: (root.focusService && root.focusService.soundAlerts) ? "ON" : "OFF"
              color: (root.focusService && root.focusService.soundAlerts) ? Color.background : Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.focusService) root.focusService.toggleSoundAlerts()
              }
            }
          }
        }
      }

      // Do Not Disturb (DND) Toggle (Borderless)
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Style.cornerRadius
        color: Style.normalFillFor(Color.foreground, Color.accent)

        RowLayout {
          anchors.fill: parent
          anchors.margins: Style.space(14)

          Column {
            Layout.fillWidth: true
            spacing: Style.space(4)
            Text {
              text: "🔕 Focus Mode Shield"
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
            }
            Text {
              text: "Non-permitted apps & websites automatically restricted"
              color: Qt.darker(Color.foreground, 1.5)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              wrapMode: Text.WordWrap
              width: Style.space(170)
            }
          }

          Rectangle {
            width: Style.space(52)
            height: Style.space(26)
            radius: Style.cornerRadius - 2
            color: Style.selectedFillFor(Color.foreground, Color.accent)

            Text {
              anchors.centerIn: parent
              text: (root.focusService && root.focusService.active) ? "ACTIVE" : "AUTO"
              color: (root.focusService && root.focusService.active) ? Color.accent : Qt.darker(Color.foreground, 1.4)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
            }
          }
        }
      }
    }
  }
}
