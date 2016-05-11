import QtQuick 2.0

ListView {
    id: optionsList

    signal currentOptionChanged(int index)

    orientation: ListView.Horizontal
    interactive: false

    property int cellWidth: Math.floor(model.count>0?((optionsList.width - model.count * optionsList.spacing) / model.count):0)
    property int underlineWidth: 0
    property string underlineColor: ''

    model: ListModel {
        id: optionsModel
    }

    delegate: Item {
        width: optionsList.cellWidth
        height: optionsList.height
        Text {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: model.title
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                optionsList.currentIndex = model.index;
                optionsList.currentOptionChanged(optionsList.currentIndex);
                console.log('option', currentIndex);
            }
        }
    }

    highlight: Item {
        width: optionsList.cellWidth
        height: optionsList.height
        Rectangle {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: underlineWidth
            color: underlineColor
        }
    }


    function appendOption(item) {
        optionsModel.append(item);
    }
}
