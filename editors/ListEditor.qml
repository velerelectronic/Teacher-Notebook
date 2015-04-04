import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import 'qrc:///common' as Common

Common.AbstractEditor {
    id: editor
    property var content: {reference: -1; valued: false; nameAttribute: ''; model: undefined}

    signal changesAccepted
    signal changesCanceled
    property bool edit: true

    Common.UseUnits { id: units }

    height: units.fingerUnit * 3 + units.nailUnit * 2

    ListView {
        id: list
        anchors.fill: parent
        anchors.margins: units.nailUnit
        orientation: ListView.Horizontal
        spacing: units.nailUnit

        model: content.model
        delegate: Rectangle {
            width: units.fingerUnit * 5
            height: list.height
            color: 'yellow'
            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: model[content.nameAttribute]
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    list.currentIndex = model.index;
                    if (content.valued) {
                        content.reference = model[content.nameAttribute];
                    } else {
                        content.reference = model['id'];
                    }
                    changesAccepted();
                }
            }
        }
        highlight: Rectangle {
            color: 'yellow'
            width: units.fingerUnit
            height: list.height
        }
    }
}
