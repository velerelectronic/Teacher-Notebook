import QtQuick 2.5
import QtQml.Models 2.2

ListView {
    id: optionsList

    signal currentOptionChanged(int index)

    orientation: ListView.Horizontal
    interactive: false

    property int cellWidth: Math.floor(model.count>0?((optionsList.width - model.count * optionsList.spacing) / model.count):0)
    property int underlineWidth: 0
    property string underlineColor: ''
    property ListView connectedList: null

    model: ListModel {
        id: optionsModel
    }

    property ObjectModel sectionsModel

    onSectionsModelChanged: {
        optionsModel.clear();
        for (var i=0; i<sectionsModel.count; i++) {
            var obj = sectionsModel.get(i);
            if (obj['objectName'] == 'BasicSection') {
                optionsModel.append({title: obj['caption']});
            }
        }
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
                if (connectedList !== null)
                    connectedList.currentIndex = optionsList.currentIndex;

                console.log('option', currentIndex);
            }
        }
    }

    highlightMoveDuration: 200

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
