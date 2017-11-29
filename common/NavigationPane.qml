import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common


Rectangle {
    signal closePane()

    default property Component innerItem

    property int lateralMargins: units.fingerUnit

    onInnerItemChanged: innerItemLocation.sourceComponent = innerItem;

    Common.UseUnits {
        id: units
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        spacing: units.nailUnit

        Item {
            Layout.preferredWidth: lateralMargins
            Layout.fillHeight: true
        }

        Loader {
            id: innerItemLocation

            Layout.fillWidth: true
            Layout.fillHeight: true

            sourceComponent: innerItem
        }

        ImageButton {
            Layout.preferredWidth: lateralMargins
            Layout.preferredHeight: lateralMargins
            Layout.alignment: Qt.AlignTop

            image: 'road-sign-147409'

            onClicked: closePane()
        }
    }
}
