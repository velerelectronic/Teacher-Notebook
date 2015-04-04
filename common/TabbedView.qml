import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import 'qrc:///common' as Common

Item {
    id: tabbedView

    property int tabsHeight: units.fingerUnit + units.nailUnit
    property int tabsWidth: units.fingerUnit * 3
    property int tabsSpacing: units.nailUnit
    property alias widgets: widgetsModel // «title» and «component»

    Common.UseUnits {
        id: units
    }

    ListModel {
        id: widgetsModel
    }

    ColumnLayout {
        anchors.fill: parent
        ListView {
            id: titlesList
            Layout.preferredHeight: tabsHeight
            Layout.fillWidth: true
            orientation: ListView.Horizontal
            model: widgetsModel
            delegate: Item {
                width: tabsWidth
                height: tabsHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.bottomMargin: units.nailUnit
                    color: '#90ff90'

                    Text {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        font.pixelSize: units.readUnit
                        fontSizeMode: Text.Fit
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: model.title
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: titlesList.currentIndex = model.index
                    }
                }
            }
            highlight: Item {
                width: tabsWidth
                height: titlesList.height
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: units.nailUnit
                    color: 'green'
                }
            }

            spacing: tabsSpacing
            onCurrentIndexChanged: widgetList.currentIndex = currentIndex
        }
        ListView {
            id: widgetList
            Layout.fillHeight: true
            Layout.fillWidth: true
            orientation: ListView.Horizontal
            interactive: false
            spacing: units.nailUnit
            model: widgetsModel
            highlightMoveDuration: width / 2
            delegate: Loader {
                width: widgetList.width
                height: widgetList.height
                sourceComponent: model.component
            }
        }
    }
}
