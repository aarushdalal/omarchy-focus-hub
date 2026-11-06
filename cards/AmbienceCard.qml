import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Commons as OmarchyPalette
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
      color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

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
              color: OmarchyPalette.Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "Focus Ambient Background Sound"
              color: OmarchyPalette.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }
          Item { Layout.fillWidth: true }
          Text {
            text: root.ambiencePlaying ? "PLAYING" : "OFF"
            color: root.ambiencePlaying ? OmarchyPalette.Color.accent : Qt.darker(OmarchyPalette.Color.foreground, 1.6)
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
              { id: "rain", label: "󰖗 Deep Rain", icon: "󰖗" },
              { id: "whitenoise", label: "󰝚 Brown Noise", icon: "󰝚" },
              { id: "binaural", label: "󰠵 Alpha Waves", icon: "󰠵" }
            ]

            Rectangle {
              Layout.fillWidth: true
              height: Style.space(38)
              radius: Style.cornerRadius - 2
              readonly property bool isSelected: root.ambiencePlaying && root.currentAmbience === modelData.id
              color: isSelected
                ? Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
                : (cardMouse.containsMouse ? Style.hoverFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent) : Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent))

              Row {
                anchors.centerIn: parent
                spacing: Style.space(6)
                Text {
                  text: modelData.label
                  color: isSelected ? OmarchyPalette.Color.accent : OmarchyPalette.Color.foreground
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
        color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

        RowLayout {
          anchors.fill: parent
          anchors.margins: Style.space(14)

          ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            spacing: Style.space(4)
            Text {
              Layout.fillWidth: true
              text: "󰂚 Sound Chimes"
              color: OmarchyPalette.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              elide: Text.ElideRight
            }
            Text {
              Layout.fillWidth: true
              text: "Play audio alert when session starts or blocked site is opened"
              color: Qt.darker(OmarchyPalette.Color.foreground, 1.5)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              wrapMode: Text.WordWrap
              elide: Text.ElideRight
              maximumLineCount: 2
            }
          }

          Rectangle {
            width: Style.space(52)
            height: Style.space(26)
            radius: Style.cornerRadius - 2
            color: (root.focusService && root.focusService.soundAlerts) ? OmarchyPalette.Color.accent : Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

            Text {
              anchors.centerIn: parent
              text: (root.focusService && root.focusService.soundAlerts) ? "ON" : "OFF"
              color: (root.focusService && root.focusService.soundAlerts) ? OmarchyPalette.Color.background : OmarchyPalette.Color.foreground
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
        color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

        RowLayout {
          anchors.fill: parent
          anchors.margins: Style.space(14)

          ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            spacing: Style.space(4)
            Text {
              Layout.fillWidth: true
              text: "󰄲 Focus Mode Shield"
              color: OmarchyPalette.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              elide: Text.ElideRight
            }
            Text {
              Layout.fillWidth: true
              text: "Non-permitted apps & websites automatically restricted"
              color: Qt.darker(OmarchyPalette.Color.foreground, 1.5)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              wrapMode: Text.WordWrap
              elide: Text.ElideRight
              maximumLineCount: 2
            }
          }

          Rectangle {
            width: Style.space(52)
            height: Style.space(26)
            radius: Style.cornerRadius - 2
            color: Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

            Text {
              anchors.centerIn: parent
              text: (root.focusService && root.focusService.active) ? "ACTIVE" : "AUTO"
              color: (root.focusService && root.focusService.active) ? OmarchyPalette.Color.accent : Qt.darker(OmarchyPalette.Color.foreground, 1.4)
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
