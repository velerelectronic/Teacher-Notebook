import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Common.AbstractEditor {
    id: annotationStateEditor

    property var annotationContent
    property string content

    signal stateValueChanged(string value)

    onContentChanged: {
        annotationContent = {};
        annotationContent['state'] = content;
    }

    ListView {
        id: stateButtonsList
        anchors.fill: parent
        orientation: ListView.Horizontal

        model: statesModel
        spacing: units.fingerUnit

        highlight: Rectangle {
            height: units.fingerUnit * 2
            width: height
            color: 'yellow'
        }

        delegate: Common.ImageButton {
            size: units.fingerUnit * 2
            image: model.image
            onClicked: {
                annotationStateEditor.content = model.stateValue;
                stateButtonsList.currentIndex = model.index;
                annotationStateEditor.setChanges(true);
                stateValueChanged(model.stateValue);
            }
            Connections {
                target: annotationStateEditor
                onContentChanged: {
                    if (annotationStateEditor.content == model.stateValue)
                        stateButtonsList.currentIndex = model.index;
                }
            }
            Component.onCompleted: {
                if (annotationStateEditor.content == model.stateValue)
                    stateButtonsList.currentIndex = model.index;
            }
        }
    }
    ListModel {
        id: statesModel
        ListElement {
            image: 'input-25064'
            stateValue: '0'
        }
        ListElement {
            image: 'pin-23620'
            stateValue: '1'
        }
        ListElement {
            image: 'hourglass-23654'
            stateValue: '2'
        }
        ListElement {
            image: 'check-mark-304890'
            stateValue: '3'
        }
        ListElement {
            image: 'can-294071'
            stateValue: '-1'
        }
    }
}
