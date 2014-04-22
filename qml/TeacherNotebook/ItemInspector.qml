import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import 'common' as Common


Common.AbstractEditor {
    id: itemInspector
    property alias pageTitle: titlePage.text
    property alias pageBackground: backgroundImage.source
    property alias model: inspectorGrid.model
    property var editorType: { "TextLine": 1, "TextArea": 2, "Date": 3, "Time": 4, "State": 5 }

    signal saveDataRequested
    signal copyDataRequested
    signal discardDataRequested(bool changes)

    Image {
        id: backgroundImage
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        Text {
            id: titlePage
            Layout.fillWidth: true
            font.pixelSize: units.nailUnit
            font.bold: true
        }
        ListView {
            id: inspectorGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ListModel {
                id: attributesModel
                dynamicRoles: true
            }
            delegate: Rectangle {
                id: variableViewer

                state: 'viewMode'
                states: [
                    State {
                        name: 'editMode'
                        PropertyChanges { target: editorLoader; visible: true }
                        PropertyChanges { target: viewerBox; height: variableBox.height + ((editorLoader.item && editorLoader.item.height !== null)?editorLoader.item.height:0) + viewerBox.spacing }
                    },
                    State {
                        name: 'viewMode'
                        PropertyChanges { target: editorLoader; visible: false }
                        PropertyChanges { target: viewerBox; height: variableBox.height }
                    }

                ]
                transitions: [
                    Transition {
                        PropertyAnimation { properties: 'height'; easing.type: Easing.InOutQuad }
                    }
                ]
                clip: true
                width: parent.width
                height: viewerBox.height + units.nailUnit * 2
                color: model.color
                border.color: 'black'

                ColumnLayout {
                    id: viewerBox
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Item {
                        id: variableBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: height
                        height: Math.max(fieldNameBox.height,contentBox.height)
                        Text {
                            id: fieldNameBox
                            anchors.left: parent.left
                            anchors.right: parent.horizontalCenter
                            anchors.top: parent.top
                            height: units.fingerUnit
                            verticalAlignment: Text.AlignVCenter
                            text: model.fieldName
                        }
                        Text {
                            id: contentBox
                            anchors.left: parent.horizontalCenter
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: contentHeight
                            verticalAlignment: Text.AlignVCenter
                            text: transformContent(model.content)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (variableViewer.state=='viewMode') {
                                    itemInspector.collapseEditors();
                                    variableViewer.state = 'editMode';
                                } else
                                    variableViewer.state = 'viewMode';
                            }
                        }
                    }
                    Loader {
                        id: editorLoader
                        asynchronous: false
//                        Layout.fillWidth: true
//                        Layout.preferredHeight: height
                        Connections {
                            target: editorLoader.item
                            ignoreUnknownSignals: true
                            onNewChanges: {
                                console.log('Canvis!!!!!');
                                editorLoader.item.changes && itemInspector.setChanges(true);
                            }
                        }
                    }
                }
                onStateChanged: {
                    if (variableViewer.state == 'editMode') {
                        var editorPage;
                        switch(model.editorType) {
                        case (itemInspector.editorType.TextLine):
                            editorPage = 'TextLineEditor.qml'
                            break;
                        case (itemInspector.editorType.TextArea):
                            editorPage = 'TextAreaEditor.qml'
                            break;
                        case (itemInspector.editorType.Date):
                            editorPage = 'DateTimeEditor.qml'
                            break;
                        case (itemInspector.editorType.State):
                            editorPage = 'StateEditor.qml'
                            break;
                        default:
                            editorPage = 'GeneralEditor.qml'
                        }
                        var newcontent = model.content;
                        editorLoader.setSource('editors/' + editorPage, {content: newcontent, width: viewerBox.width});
                        editorLoader.focus = true;
                    } else {
                        // Then state is viewMode
                        if (editorLoader.item && editorLoader.item.content) {
                            attributesModel.setProperty(model.index, 'content', editorLoader.item.content);
                        }
                        editorLoader.setSource('editors/NoEditor.qml');
                    }
                }
            }
        }
        RowLayout {
            Layout.preferredHeight: childrenRect.height
            Button {
                enabled: changes
                text: qsTr('Desa')
                Layout.preferredHeight: units.fingerUnit
                onClicked: {
                    collapseEditors();
                    messageSave.open();
                }
            }
            Button {
                enabled: changes
                text: qsTr('Cancela')
                Layout.preferredHeight: units.fingerUnit
                onClicked: {
                    collapseEditors();
                    messageDiscard.open();
                }
            }
            Button {
                visible: (itemInspector.idEvent != -1)
                text: qsTr('Duplica')
                Layout.preferredHeight: units.fingerUnit
                onClicked: {
                    collapseEditors();
                    messageCopy.open();
                }
            }
        }
    }

    MessageDialog {
        id: messageSave
        title: qsTr('Desar canvis');
        text: qsTr('Es desaran els canvis. Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: itemInspector.saveDataRequested()
    }
    MessageDialog {
        id: messageDiscard
        title: qsTr('Descartar canvis');
        text: qsTr('Es descartaran els canvis. N\'estàs segur?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            var changes = itemInspector.changes;
            itemInspector.setChanges(false);
            itemInspector.discardDataRequested(changes);
        }
    }
    MessageDialog {
        id: messageCopy
        title: qsTr('Duplicar');
        text: qsTr('Es duplicaran totes les dades a un nou element. Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: itemInspector.copyDataRequested();
    }

    function addSection(fieldName,content,color,editor) {
        inspectorGrid.model.append({fieldName: fieldName, content: content, color: color, editorType: editor});
        return inspectorGrid.model.count-1;
    }

    function getContent(index) {
        return inspectorGrid.model.get(index).content;
    }

    function collapseEditors() {
        for (var i=0; i<inspectorGrid.contentItem.children.length; i++) {
            var widget = inspectorGrid.contentItem.children[i];
            if (widget.state == 'editMode')
                widget.state = 'viewMode';
        }
    }

    function transformContent(object) {
        var result = '';
        if (typeof object == 'string')
            result = object;
        else {
            if (typeof object != 'undefined') {
                result = qsTr('Dia ') + object['date'];
                if (object['time'])
                    result += '\n' + qsTr('A les ') + object['time'];
            }
        }
        return result;
    }
}
