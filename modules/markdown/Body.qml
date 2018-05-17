import QtQuick 2.7
import PersonalTypes 1.0

Generic {
    property int requiredHeight: mainList.contentItem.height
    property string text

    onRequiredHeightChanged: updatedHeight(requiredHeight)

    color: 'gray'

    ListView {
        id: mainList

        anchors.fill: parent

        model: MarkDownItemModel {
            id: mdModel
        }

        header: Rectangle {
            color: 'black'
            width: mainList.width
            height: 20
        }

        spacing: units.nailUnit

        delegate: Paragraph {
            width: mainList.width
            height: requiredHeight

            parameters: model.parameters
        }

        Component.onCompleted: parseMarkDown()
    }

    function parseMarkDown() {
        mdModel.parseMarkDown(text.toString());
    }

    onTextChanged: parseMarkDown()

    Component.onCompleted: updatedHeight(requiredHeight)
}

