import QtQuick 2.3
import QtQuick.Controls 1.2
import 'qrc:///common' as Common

CollectionInspectorItem {
    id: editState

    Common.UseUnits { id: units }

    clip: true

    signal addRow()

    ListModel {
        id: emptyModel
    }


    visorComponent: Text {
        id: textVisor
        property int requiredHeight: Math.max(contentHeight, units.fingerUnit)
        property var shownContent: {reference: -1; nameAttribute: ''; model: emptyModel}

        // reference: the specific code of the selected item in the model. The code refers to the column 'id'
        // valued: if true, the shown title for the item is the same as the reference
        // nameAttribute: the column identificator that contains the title of each item in the model
        // model: the collection of items with the data

        text: ''
        font.pixelSize: units.readUnit
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        onShownContentChanged: {
            var s = textVisor.shownContent;
            if (typeof s !== 'undefined') {
                if (s.valued) {
                    textVisor.text = s.reference;
                } else {
                    console.log("s.reference " + s.reference);
                    if (typeof s.reference === 'undefined')
                        textVisor.text = qsTr('No definit');
                    else {
                        var obj = s.model.getObject('id',s.reference);
                        textVisor.text = (typeof obj[s.nameAttribute] !== 'undefined')?obj[s.nameAttribute]:qsTr("No s'ha trobat el codi");
                    }
                }
            }
        }
    }

    editorComponent: ListView {
        id: listEditor
        property int requiredHeight: contentItem.height
        property var editedContent: {reference: -1; valued: false; nameAttribute: ''; model: emptyModel }
        property int preselectedIndex: -1

        interactive: false
        highlightFollowsCurrentItem: true
        highlight: Rectangle {
            color: 'yellow'
            width: listEditor.width
            height: units.fingerUnit * 2
        }

        model: editedContent.model

        delegate: Rectangle {
            width: listEditor.width
            height: units.fingerUnit * 2
            border.color: '#CCCCCC'
            color: 'transparent'
            Text {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: model[editedContent.nameAttribute]
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listEditor.currentIndex = model.index;
                    if (editedContent.valued) {
                        editedContent.reference = model[editedContent.nameAttribute];
                    } else {
                        editedContent.reference = model['id'];
                    }
                    //changesAccepted();
                }
            }

            Component.onCompleted: {
                if (editedContent.valued) {
                    if (editedContent.reference === model[editedContent.nameAttribute]) {
                        listEditor.preselectedIndex = model.index;
                    }
                } else {
                    if (editedContent.reference === model.id) {
                        listEditor.preselectedIndex = model.index;
                    }
                }
            }
        }

        footer: Common.SuperposedButton {
            id: newButton

            size: units.fingerUnit
            imageSource: 'plus-24844'
            margins: units.nailUnit
            onClicked: editState.addRow()
        }

        onCurrentIndexChanged: {
            if (preselectedIndex !== -1) {
                if (currentIndex !== preselectedIndex) {
                    var a = preselectedIndex;
                    preselectedIndex = -1;
                    currentIndex = a;
                }
            }
        }
    }

}

