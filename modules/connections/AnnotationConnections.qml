import QtQuick 2.7
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/annotations2' as Annotations

ListView {
    id: annotationConnectionsItem

    property int annotationId
    property int requiredHeight: contentItem.height
    property alias connectionsModelRef: connectionsModel

    signal annotationSelected(int annotation)

    interactive: false

    Common.UseUnits {
        id: units
    }

    Models.AnnotationsConnections {
        id: connectionsModel

        filters: ['annotationFrom=?']

        sort: 'connectionType ASC'

        function selectFrom() {
            bindValues = [annotationId];
            select();
        }
    }

    model: connectionsModel

    spacing: units.nailUnit
    bottomMargin: units.fingerUnit * 2

    section.property: 'connectionType'
    section.delegate: Rectangle {
        color: 'gray'
        width: annotationConnectionsItem.width
        height: units.fingerUnit * 1.5

        Text {
            anchors.fill: parent

            padding: units.nailUnit
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: units.readUnit
            font.bold: true
            color: 'white'
            elide: Text.ElideRight
            text: section
        }
    }

    delegate: Loader {
        id: annotationLoader

        width: annotationConnectionsItem.width
        height: units.fingerUnit * 3

        asynchronous: true

        property int connectionId: model.id
        property string connectionType: model.connectionType
        property string connectionLocation: model.location

        sourceComponent: Rectangle {
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Common.ImageButton {
                    id: connectionTypeButton

                    Layout.preferredWidth: units.fingerUnit
                    size: units.fingerUnit
                    Layout.fillHeight: true
                    image: 'hierarchy-35795'

                    onClicked: changeConnectionTypeDialog.openConnectionEditor(annotationLoader.connectionId, annotationLoader.connectionType)
                }

                Text {
                    id: annotationTitle

                    Layout.preferredWidth: parent.width / 3
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    id: annotationDesc

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    id: annotationLocation

                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 3

                    verticalAlignment: Text.AlignVCenter

                    font.pixelSize: units.readUnit * 0.6
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight

                    text: annotationLoader.connectionLocation

                    MouseArea {
                        anchors.fill: parent
                        onClicked: editLocationDialog.openLocationEditor(annotationLoader.connectionId)
                    }
                }
            }

            Models.DocumentAnnotations {
                id: annotationsModel
            }

            function getAnnotationDetails(identifier) {
                var annotationToObject = annotationsModel.getObject(identifier);

                annotationTitle.text = annotationToObject['title'];
                annotationDesc.text = annotationToObject['desc'];
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: annotationConnectionsItem.annotationSelected(model.annotationTo)
        }

        onLoaded: item.getAnnotationDetails(model.annotationTo)
    }

    Common.ImageButton {
        anchors {
            bottom: parent.bottom
            right: parent.right
        }
        padding: units.nailUnit

        image: 'plus-24844'

        onClicked: newAnnotationConnection.openNewConnection()
    }

    Common.SuperposedWidget {
        id: newAnnotationConnection

        function openNewConnection() {
            load(qsTr('Nova connexió'), 'annotations2/AnnotationsList', {interactive: true});
        }

        Connections {
            target: newAnnotationConnection.mainItem

            onAnnotationSelected: {
                newAnnotationConnection.close();
                connectionsModel.insertObject({annotationFrom: annotationId, annotationTo: annotation, connectionType: '', created: (new Date()).toISOString()});
                connectionsModel.selectFrom();
            }
        }
    }

    Common.SuperposedMenu {
        id: changeConnectionTypeDialog

        title: qsTr('Canvia el tipus de connexió')

        parentWidth: annotationConnectionsItem.width
        parentHeight: units.fingerUnit * 12

        property int connectionId

        standardButtons: StandardButton.Save | StandardButton.Cancel

        Editors.TextAreaEditor3 {
            id: connectionTypeEditor

            width: changeConnectionTypeDialog.parentWidth
            height: units.fingerUnit * 10
        }

        function openConnectionEditor(connectionId, connectionType) {
            changeConnectionTypeDialog.connectionId = connectionId;
            connectionTypeEditor.content = connectionType;
            open();
        }

        onAccepted: {
            connectionsModel.updateObject(changeConnectionTypeDialog.connectionId, {connectionType: connectionTypeEditor.content.trim()});
            connectionsModel.selectFrom();
            changeConnectionTypeDialog.close();
        }
    }

    Common.SuperposedWidget {
        id: editLocationDialog

        title: qsTr('Canvia la localització')

        property int connectionId

        function openLocationEditor(connection) {
            editLocationDialog.connectionId = connection;
            load(qsTr('Canvia la localització'), 'connections/EditConnectionLocation', {annotation: annotationId});
        }

        Connections {
            target: editLocationDialog.mainItem

            onLocationChanged: {
                connectionsModel.updateObject(editLocationDialog.connectionId, {location: location});
                editLocationDialog.close();
                connectionsModel.selectFrom();
            }
        }
    }

    Component.onCompleted: connectionsModel.selectFrom()
}
