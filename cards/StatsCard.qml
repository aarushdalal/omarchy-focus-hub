import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui

Item {
  id: root

  property var focusService: null

  readonly property int todayMins: root.focusService ? root.focusService.todayMinutes : 0
  readonly property int todaySess: root.focusService ? root.focusService.todaySessions : 0
  readonly property int dailyGoalMins: 120

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(12)

    // Top Metric Tiles (Borderless)
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(12)

      // Time Focused Tile (Borderless)
      Rectangle {
        Layout.fillWidth: true
        height: Style.space(100)
        radius: Style.cornerRadius
        color: Style.normalFillFor(Color.foreground, Color.accent)

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: Style.space(14)
          spacing: Style.space(4)

          Row {
            spacing: Style.space(6)
            Text {
              text: "⏱️"
              font.pixelSize: Style.font.bodySmall
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "TODAY'S FOCUS TIME"
              color: Qt.darker(Color.foreground, 1.6)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Text {
            text: (root.todayMins >= 60)
              ? (Math.floor(root.todayMins / 60) + "h " + (root.todayMins % 60) + "m")
              : (root.todayMins + " mins")
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.display
            font.bold: true
          }

          Text {
            text: "Daily Target: " + (root.dailyGoalMins / 60) + " hours"
            color: Qt.darker(Color.foreground, 1.8)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
          }
        }
      }

      // Completed Sprints Tile (Borderless)
      Rectangle {
        Layout.fillWidth: true
        height: Style.space(100)
        radius: Style.cornerRadius
        color: Style.normalFillFor(Color.foreground, Color.accent)

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: Style.space(14)
          spacing: Style.space(4)

          Row {
            spacing: Style.space(6)
            Text {
              text: "🎯"
              font.pixelSize: Style.font.bodySmall
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "COMPLETED SPRINTS"
              color: Qt.darker(Color.foreground, 1.6)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Text {
            text: String(root.todaySess) + " sessions"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.display
            font.bold: true
          }

          Text {
            text: "Consistency is key to mastery"
            color: Qt.darker(Color.foreground, 1.8)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
          }
        }
      }
    }

    // Daily Goal Progress Bar Card (Borderless)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(80)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(14)
        spacing: Style.space(8)

        RowLayout {
          Layout.fillWidth: true
          Text {
            text: "Daily Goal Progress"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
          Item { Layout.fillWidth: true }
          Text {
            text: Math.min(100, Math.round((root.todayMins / root.dailyGoalMins) * 100)) + "%"
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: Style.space(8)
          radius: 4
          color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.1)

          Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.min(1.0, root.todayMins / root.dailyGoalMins)
            radius: 4
            color: Color.accent

            Behavior on width { NumberAnimation { duration: 300 } }
          }
        }
      }
    }

    // Inspiration Quote Card (Borderless)
    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      RowLayout {
        anchors.fill: parent
        anchors.margins: Style.space(16)
        spacing: Style.space(12)

        Text {
          text: "💡"
          font.pixelSize: Style.font.heading
        }

        Column {
          Layout.fillWidth: true
          spacing: Style.space(4)

          Text {
            text: "“Action is the foundational key to all success.”"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            wrapMode: Text.WordWrap
            width: Style.space(420)
          }

          Text {
            text: "Deep work produces higher quality results in less time."
            color: Qt.darker(Color.foreground, 1.6)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }

        Item { Layout.fillWidth: true }

        Row {
          spacing: Style.space(6)

          // Test Reward Animation Button
          Rectangle {
            width: Style.space(94)
            height: Style.space(30)
            radius: Style.cornerRadius - 3
            color: testRewardMouse.containsMouse ? Qt.lighter(Color.accent, 1.15) : Color.accent

            Row {
              anchors.centerIn: parent
              spacing: Style.space(4)
              Text {
                text: "🏆"
                font.pixelSize: Style.font.caption
                anchors.verticalCenter: parent.verticalCenter
              }
              Text {
                text: "Reward"
                color: Color.background
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            MouseArea {
              id: testRewardMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.focusService) root.focusService.triggerRewardTest()
              }
            }
          }

          // Reset Stats Button
          Rectangle {
            width: Style.space(70)
            height: Style.space(30)
            radius: Style.cornerRadius - 3
            color: resetStatsMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.selectedFillFor(Color.foreground, Color.accent)

            Row {
              anchors.centerIn: parent
              spacing: Style.space(4)
              Text {
                text: "🔄"
                font.pixelSize: Style.font.caption
                anchors.verticalCenter: parent.verticalCenter
              }
              Text {
                text: "Reset"
                color: Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            MouseArea {
              id: resetStatsMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.focusService) root.focusService.resetStats()
              }
            }
          }
        }
      }
    }
  }
}
