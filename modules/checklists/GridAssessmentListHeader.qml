import QtQuick 2.7
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    property string caption: ''
    property string field: ''
    property var selectedValues: []

    property int requiredHeight: Math.max(units.fingerUnit, childrenRect.height)

    signal sectioningSelected(string field)

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: units.nailUnit
        }

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight

            font.pixelSize: units.readUnit
            font.bold: true

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            text: caption
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: contentItem.height
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log('hhhh', field);
            sectioningSelected(field);
        }
    }

}
