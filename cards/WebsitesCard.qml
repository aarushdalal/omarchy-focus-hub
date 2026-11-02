import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons as OmarchyPalette
import qs.Commons
import qs.Ui

Item {
  id: root

  property var focusService: null

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(10)

    // Strict Mode Switch Bar (Borderless)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(46)
      radius: Style.cornerRadius
      color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.space(14)
        anchors.rightMargin: Style.space(14)

        Row {
          spacing: Style.space(8)
          Layout.alignment: Qt.AlignVCenter

          Text {
            text: (root.focusService && root.focusService.strictWhitelist) ? "🔒" : "🌐"
            font.pixelSize: Style.font.body
            anchors.verticalCenter: parent.verticalCenter
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
              text: "Strict Website Whitelist Mode"
              color: OmarchyPalette.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
            }
            Text {
              text: (root.focusService && root.focusService.strictWhitelist)
                ? "Active: ONLY permitted websites below can be opened"
                : "Standard: Blacklisted distraction sites are blocked"
              color: Qt.darker(OmarchyPalette.Color.foreground, 1.5)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
            }
          }
        }

        Item { Layout.fillWidth: true }

        // Toggle Switch Button (Borderless)
        Rectangle {
          width: Style.space(70)
          height: Style.space(26)
          radius: Style.cornerRadius - 2
          color: (root.focusService && root.focusService.strictWhitelist) ? OmarchyPalette.Color.accent : Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

          Text {
            anchors.centerIn: parent
            text: (root.focusService && root.focusService.strictWhitelist) ? "STRICT" : "STANDARD"
            color: (root.focusService && root.focusService.strictWhitelist) ? OmarchyPalette.Color.background : OmarchyPalette.Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.focusService) root.focusService.toggleStrictWhitelist()
            }
          }
        }
      }
    }

    // Add Website Input Bar (Borderless)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(42)
      radius: Style.cornerRadius
      color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.space(12)
        anchors.rightMargin: Style.space(6)

        TextField {
          id: domainInput
          Layout.fillWidth: true
          placeholderText: "Add permitted study domain (e.g. coursera.org, khanacademy.org)..."
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          foreground: OmarchyPalette.Color.foreground
          accent: OmarchyPalette.Color.accent
          Layout.alignment: Qt.AlignVCenter

          onAccepted: {
            if (domainInput.text.trim() !== "" && root.focusService) {
              root.focusService.addAllowedDomain(domainInput.text.trim())
              domainInput.text = ""
            }
          }
        }

        // Add Button
        Rectangle {
          width: Style.space(56)
          height: Style.space(30)
          radius: Style.cornerRadius - 3
          color: addBtnMouse.containsMouse ? Qt.lighter(OmarchyPalette.Color.accent, 1.1) : OmarchyPalette.Color.accent

          Text {
            anchors.centerIn: parent
            text: "➕ Add"
            color: OmarchyPalette.Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          MouseArea {
            id: addBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (domainInput.text.trim() !== "" && root.focusService) {
                root.focusService.addAllowedDomain(domainInput.text.trim())
                domainInput.text = ""
              }
            }
          }
        }
      }
    }

    // Permitted Domains Scroll View (Borderless)
    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      radius: Style.cornerRadius
      color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
      clip: true

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(12)
        spacing: Style.space(8)

        Row {
          spacing: Style.space(6)
          Text {
            text: "󰄬 Permitted Websites (Always Allowed)"
            color: OmarchyPalette.Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
          Text {
            text: "(" + (root.focusService ? root.focusService.allowedDomains.length : 0) + ")"
            color: Qt.darker(OmarchyPalette.Color.foreground, 1.5)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }

        Flickable {
          Layout.fillWidth: true
          Layout.fillHeight: true
          contentHeight: domainsFlow.implicitHeight
          boundsBehavior: Flickable.StopAtBounds

          Flow {
            id: domainsFlow
            width: parent.width
            spacing: Style.space(6)

            Repeater {
              model: root.focusService ? root.focusService.allowedDomains : []

              Rectangle {
                height: Style.space(28)
                width: chipRow.implicitWidth + Style.space(14)
                radius: Style.cornerRadius - 3
                color: Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

                Row {
                  id: chipRow
                  anchors.centerIn: parent
                  spacing: Style.space(6)

                  Text {
                    text: modelData
                    color: OmarchyPalette.Color.foreground
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                  }

                  Text {
                    text: "✕"
                    color: removeMouse.containsMouse ? "#ff4455" : Qt.darker(OmarchyPalette.Color.foreground, 1.6)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption - 1
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                      id: removeMouse
                      anchors.fill: parent
                      anchors.margins: -4
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        if (root.focusService) root.focusService.removeAllowedDomain(modelData)
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
