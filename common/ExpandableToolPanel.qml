import QtQuick 2.5
import 'qrc:///common' as Common

Item {
    Common.UseUnits {
        id: units
    }

    states: [
        State {
            name: 'toolbar'

            PropertyChanges {
                target: toolBarList
                orientation: ListView.Horizontal
            }
        },
        State {
            name: 'sidepanel'

            PropertyChanges {
                target: toolBarList
                orientation: ListView.Vertical
            }
        }
    ]

    property int toolBarHeight: units.fingerUnit * 1.5
    property int sidePanelWidth: Math.max(parent.width / 3, parent.width - units.fingerUnit)

    ListView {
        id: toolBarList

        anchors.fill: parent

        spacing: units.fingerUnit
    }

}
