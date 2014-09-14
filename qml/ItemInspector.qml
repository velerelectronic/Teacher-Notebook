import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import 'qrc:///common' as Common


Common.AbstractEditor {
    id: itemInspector
    property alias pageTitle: titlePage.text
    property alias pageBackground: backgroundImage.source
    property alias model: inspectorGrid.model
    property var editorType: {
                'TextLine': 1,
                'TextArea': 2,
                'DateTime': 3,
                'State': 4,
                'Image': 5
    }
    property var showComponent: {
                1: showText,
                2: showText,
                3: showDateTime,
                4: showState,
                5: showImage
    }
    property var editComponent: {
                1: 'TextLineEditor',
                2: 'TextAreaEditor',
                3: 'DateTimeEditor',
                4: 'StateEditor',
                5: 'ImageEditor'
    }

    property alias buttons: buttonsModel

    signal saveDataRequested
    signal copyDataRequested
    signal discardDataRequested(bool changes)
    signal closePageRequested()

    ListModel {
        id: buttonsModel
        ListElement {
            image: 'floppy-35952'
            method: 'saveItem'
        }

        ListElement {
            image: 'road-sign-147409'
            method: 'closeItem'
        }

        ListElement {
            image: 'clone-153447'
            method: 'duplicateItem'
        }
    }

    function saveItem() {
        collapseEditors();
        messageSave.open();
    }

    function closeItem() {
        collapseEditors();
        if (itemInspector.changes)
            messageDiscard.open();
        else
            closePageRequested();
    }

    function duplicateItem() {
        collapseEditors();
        messageCopy.open();
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        Text {
            id: titlePage
            Layout.fillWidth: true
            font.pixelSize: units.readUnit
            font.bold: true
        }
        ListView {
            id: inspectorGrid
            Layout.fillWidth: true
            Layout.fillHeight: true

            property int captionsWidth: units.fingerUnit

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
                        height: Math.max(units.fingerUnit * 2,fieldNameBox.height,contentBox.height)
                        Text {
                            id: fieldNameBox
                            anchors.left: parent.left
                            width: inspectorGrid.captionsWidth
                            anchors.top: parent.top
                            height: contentHeight
                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                            text: model.fieldName
                        }
                        Loader {
                            id: contentBox
                            //property string content: model.content
                            anchors.left: fieldNameBox.right
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: (item)?item.requiredHeight:0
                            sourceComponent: showComponent[model.editorType]
                            onLoaded: item.content = model.content
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
                            onNewChanges: editorLoader.item.changes && itemInspector.setChanges(true)
                        }
                    }
                }
                onStateChanged: {
                    if (variableViewer.state == 'editMode') {
                        var newcontent = model.content;
                        editorLoader.setSource('qrc:///editors/' + editComponent[model.editorType] + '.qml', {content: newcontent, width: viewerBox.width});
                        editorLoader.focus = true;
                    } else {
                        // Then state is viewMode
                        if (editorLoader.item && editorLoader.item.content) {
                            attributesModel.setProperty(model.index, 'content', editorLoader.item.content);
                            contentBox.item.content = editorLoader.item.content;
                        }

                        // Release the source inside the loader
                        editorLoader.sourceComponent = undefined;
                        editorLoader.active = false;
                        editorLoader.active = true;
                    }
                }
                ListView.onAdd: {
                    if (fieldNameBox.contentWidth > inspectorGrid.captionsWidth)
                        inspectorGrid.captionsWidth = fieldNameBox.contentWidth + units.fingerUnit;
                }
            }
        }
    }

    Component {
        id: showText

        Text {
            property string content: ''
            property int requiredHeight: contentHeight
            font.pixelSize: units.readUnit
            verticalAlignment: Text.AlignVCenter
            text: content
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }
    Component {
        id: showDateTime
        Text {
            property var content: ''
            property int requiredHeight: contentHeight
            font.pixelSize: units.readUnit
            verticalAlignment: Text.AlignVCenter
            text: transformContent(content)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }
    Component {
        id: showState
        Text {
            property string content: ''

        }
    }
    Component {
        id: showImage
        Image {
            id: imageBox
            property string content: ''
            property int requiredHeight: Math.round(sourceSize.height * (width / sourceSize.width))
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            // height: sourceSize.height
            fillMode: Image.PreserveAspectFit
            source: content
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
