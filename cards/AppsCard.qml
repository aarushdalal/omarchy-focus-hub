import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Ui

Item {
  id: root

  property var focusService: null
  property bool dropdownOpen: false

  // Dropdown Autocomplete Filter
  readonly property var filteredApps: {
    var query = appInput.text.trim().toLowerCase()
    if (!root.focusService || !root.focusService.installedApps) return []
    var all = root.focusService.installedApps
    if (all.length === 0) return []

    if (query === "") {
      // Show sample of installed apps
      return all.slice(0, 7)
    }

    var res = []
    for (var i = 0; i < all.length; i++) {
      var item = all[i]
      var name = (item.name || "").toLowerCase()
      var cls = (item.class || "").toLowerCase()
      var exec = (item.exec || "").toLowerCase()

      if (name.indexOf(query) !== -1 || cls.indexOf(query) !== -1 || exec.indexOf(query) !== -1) {
        res.push(item)
        if (res.length >= 7) break
      }
    }
    return res
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(10)

    // Focused Window Card with 1-Click Allow Button (Borderless)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(52)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.space(14)
        anchors.rightMargin: Style.space(10)

        Row {
          spacing: Style.space(10)
          Layout.alignment: Qt.AlignVCenter

          Text {
            text: "🪟"
            font.pixelSize: Style.font.title
            anchors.verticalCenter: parent.verticalCenter
          }

          Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
              text: "Currently Focused Window"
              color: Qt.darker(Color.foreground, 1.4)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
            }
            Text {
              text: (root.focusService && root.focusService.activeWindowClass) ? root.focusService.activeWindowClass : "No active window"
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              elide: Text.ElideRight
            }
          }
        }

        Item { Layout.fillWidth: true }

        // Allow Window Button
        Rectangle {
          height: Style.space(32)
          width: btnAllowWinMouse.containsMouse ? Style.space(130) : Style.space(120)
          radius: Style.cornerRadius - 2
          color: btnAllowWinMouse.containsMouse ? Qt.lighter(Color.accent, 1.1) : Color.accent
          scale: btnAllowWinMouse.pressed ? 0.96 : 1.0

          Behavior on width { NumberAnimation { duration: 150 } }
          Behavior on scale { NumberAnimation { duration: 120 } }

          Text {
            anchors.centerIn: parent
            text: "➕ Allow Window"
            color: Color.background
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          MouseArea {
            id: btnAllowWinMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.focusService) root.focusService.allowActiveWindow()
            }
          }
        }
      }
    }

    // Add Custom App Pattern Bar with Autocomplete Dropdown
    Item {
      id: inputWrapper
      Layout.fillWidth: true
      height: Style.space(42)
      z: 100

      Rectangle {
        id: appInputBar
        anchors.fill: parent
        radius: Style.cornerRadius
        color: Style.normalFillFor(Color.foreground, Color.accent)

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: Style.space(10)
          anchors.rightMargin: Style.space(6)
          spacing: Style.space(6)

          Text {
            text: "🔍"
            font.pixelSize: Style.font.caption
            Layout.alignment: Qt.AlignVCenter
          }

          TextField {
            id: appInput
            Layout.fillWidth: true
            placeholderText: "Search app (e.g. vlc, obsidian, discord) or enter pattern..."
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            foreground: Color.foreground
            accent: Color.accent
            Layout.alignment: Qt.AlignVCenter
            focus: true

            onTextChanged: {
              if (appInput.text.trim().length > 0) {
                root.dropdownOpen = true
              }
            }

            onAccepted: {
              if (root.filteredApps.length > 0 && appInput.text.trim() !== "") {
                var first = root.filteredApps[0]
                var pat = first.class ? (first.class + "*") : (first.name.toLowerCase() + "*")
                if (root.focusService) root.focusService.addAllowedApp(pat)
                appInput.text = ""
                root.dropdownOpen = false
              } else if (appInput.text.trim() !== "" && root.focusService) {
                root.focusService.addAllowedApp(appInput.text.trim())
                appInput.text = ""
                root.dropdownOpen = false
              }
            }
          }

          // Toggle Suggestions Dropdown Button
          Rectangle {
            width: Style.space(28)
            height: Style.space(28)
            radius: Style.cornerRadius - 3
            color: toggleDropdownMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : "transparent"
            Layout.alignment: Qt.AlignVCenter

            Text {
              anchors.centerIn: parent
              text: root.dropdownOpen ? "▲" : "▼"
              color: root.dropdownOpen ? Color.accent : Qt.darker(Color.foreground, 1.4)
              font.pixelSize: Style.font.caption - 1
            }

            MouseArea {
              id: toggleDropdownMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.dropdownOpen = !root.dropdownOpen
                if (root.dropdownOpen) appInput.forceActiveFocus()
              }
            }
          }

          // Add Button
          Rectangle {
            width: Style.space(56)
            height: Style.space(30)
            radius: Style.cornerRadius - 3
            color: addAppMouse.containsMouse ? Qt.lighter(Color.accent, 1.1) : Color.accent
            Layout.alignment: Qt.AlignVCenter

            Text {
              anchors.centerIn: parent
              text: "➕ Add"
              color: Color.background
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            MouseArea {
              id: addAppMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.filteredApps.length > 0 && appInput.text.trim() !== "") {
                  var first = root.filteredApps[0]
                  var pat = first.class ? (first.class + "*") : (first.name.toLowerCase() + "*")
                  if (root.focusService) root.focusService.addAllowedApp(pat)
                  appInput.text = ""
                  root.dropdownOpen = false
                } else if (appInput.text.trim() !== "" && root.focusService) {
                  root.focusService.addAllowedApp(appInput.text.trim())
                  appInput.text = ""
                  root.dropdownOpen = false
                }
              }
            }
          }
        }
      }

      // Dropdown Suggestions Menu (Floats over content below)
      Rectangle {
        id: dropdownMenu
        anchors.top: appInputBar.bottom
        anchors.topMargin: Style.space(4)
        anchors.left: appInputBar.left
        anchors.right: appInputBar.right
        height: Math.min(Style.space(210), suggestionsCol.implicitHeight + Style.space(8))
        radius: Style.cornerRadius
        color: Qt.rgba(0.10, 0.10, 0.14, 0.98)
        border.width: 0
        clip: true
        visible: root.dropdownOpen && root.filteredApps.length > 0
        opacity: visible ? 1.0 : 0.0
        z: 999

        Behavior on opacity { NumberAnimation { duration: 150 } }

        Column {
          id: suggestionsCol
          anchors.fill: parent
          anchors.margins: Style.space(4)
          spacing: Style.space(2)

          Repeater {
            model: root.filteredApps

            Rectangle {
              width: suggestionsCol.width
              height: Style.space(32)
              radius: Style.cornerRadius - 3
              color: itemMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : "transparent"

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.space(10)
                anchors.rightMargin: Style.space(10)
                spacing: Style.space(8)

                Text {
                  text: "📦"
                  font.pixelSize: Style.font.caption
                  Layout.alignment: Qt.AlignVCenter
                }

                Text {
                  text: modelData.name
                  color: itemMouse.containsMouse ? Color.accent : Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  Layout.alignment: Qt.AlignVCenter
                }

                Text {
                  text: "(" + (modelData.class || modelData.exec) + "*)"
                  color: Qt.darker(Color.foreground, 1.8)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption - 1
                  Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                Text {
                  text: "➕ Allow"
                  color: Color.accent
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption - 1
                  font.bold: true
                  visible: itemMouse.containsMouse
                  Layout.alignment: Qt.AlignVCenter
                }
              }

              MouseArea {
                id: itemMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  var pat = modelData.class ? (modelData.class + "*") : (modelData.name.toLowerCase() + "*")
                  if (root.focusService) root.focusService.addAllowedApp(pat)
                  appInput.text = ""
                  root.dropdownOpen = false
                }
              }
            }
          }
        }
      }
    }

    // Allowed Apps Flow Card (Borderless)
    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)
      clip: true

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(12)
        spacing: Style.space(8)

        Row {
          spacing: Style.space(6)
          Text {
            text: "📱 Permitted Study Applications"
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
          Text {
            text: "(" + (root.focusService ? root.focusService.allowedApps.length : 0) + ")"
            color: Qt.darker(Color.foreground, 1.5)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }

        Flickable {
          Layout.fillWidth: true
          Layout.fillHeight: true
          contentHeight: appsFlow.implicitHeight
          boundsBehavior: Flickable.StopAtBounds

          Flow {
            id: appsFlow
            width: parent.width
            spacing: Style.space(6)

            Repeater {
              model: root.focusService ? root.focusService.allowedApps : []

              Rectangle {
                height: Style.space(28)
                width: appRow.implicitWidth + Style.space(14)
                radius: Style.cornerRadius - 3
                color: Style.selectedFillFor(Color.foreground, Color.accent)

                Row {
                  id: appRow
                  anchors.centerIn: parent
                  spacing: Style.space(6)

                  Text {
                    text: modelData
                    color: Color.foreground
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                  }

                  Text {
                    text: "✕"
                    color: remAppMouse.containsMouse ? "#ff4455" : Qt.darker(Color.foreground, 1.6)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption - 1
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                      id: remAppMouse
                      anchors.fill: parent
                      anchors.margins: -4
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        if (root.focusService) root.focusService.removeAllowedApp(modelData)
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
