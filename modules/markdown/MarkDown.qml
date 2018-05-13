import QtQuick 2.7
import PersonalTypes 1.0

ListView {
    id: mainList

    property int requiredHeight: contentItem.height

    model: MarkDownItemModel {
        id: mdModel

        onDataChanged: {
            console.log('Data changed', rowCount());
        }
    }

    header: Rectangle {
        color: 'black'
        width: mainList.width
        height: 20
    }

    delegate: Rectangle {
        width: mainList.width
        height: Math.max(childrenRect.height, 10)
        color: 'red'

        Text {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: contentHeight

            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            text: model.type + "PAR:" + (model.parameters.join("-"))
        }
    }

    function parseMarkDown(text) {
        mdModel.parseMarkDown(text);
        for (var i=0; i<mdModel.rowCount(); i++) {
            console.log(i, mainList.contentItem.children.length);
        }

        console.log('cccc', mdModel.rowCount())
    }
}
