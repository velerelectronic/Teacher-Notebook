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

    property bool reversedConnections: false

    signal annotationSelected(int annotation)

    interactive: false

    Common.UseUnits {
        id: units
    }

    Models.AnnotationsConnections {
        id: connectionsModel

        sort: 'connectionType ASC'

        function selectFrom() {
            filters = ['annotationFrom=?'];
            bindValues = [annotationId];
            select();
        }

        function selectTo() {
            filters = ['annotationTo=?'];
            bindValues = [annotationId];
            select();
        }

        function update() {
            if (reversedConnections) {
                selectTo();
            } else {
                selectFrom();
            }
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

        RowLayout {
            anchors.fill: parent

            Text {
                Layout.fillHeight: true
                Layout.fillWidth: true

                padding: units.nailUnit
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: units.readUnit
                font.bold: true
                color: 'white'
                elide: Text.ElideRight
                text: section
            }

            Common.ImageButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                size: units.fingerUnit

                image: 'plus-24844'

                onClicked: newAnnotationConnection.openNewConnection(section)
            }
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
        property string annotationTitle: ''

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
                    id: annotationTitleAndDesc

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                }
                Text {
                    id: annotationStartDate

                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 5

                    verticalAlignment: Text.AlignVCenter

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'green'
                    elide: Text.ElideRight
                }
                Text {
                    id: annotationEndDate

                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 5

                    verticalAlignment: Text.AlignVCenter

                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: 'red'
                    elide: Text.ElideRight
                }
                Text {
                    id: annotationLocation

                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 5

                    verticalAlignment: Text.AlignVCenter

                    font.pixelSize: units.readUnit * 0.6
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight

                    text: annotationLoader.connectionLocation

                    MouseArea {
                        anchors.fill: parent
                        enabled: !reversedConnections
                        onClicked: editLocationDialog.openLocationEditor(annotationLoader.connectionId)
                    }
                }
                Annotations.StateDisplay {
                    id: annotationState

                    Layout.preferredHeight: requiredHeight
                    Layout.preferredWidth: requiredHeight
                }
            }

            Models.DocumentAnnotations {
                id: annotationsModel
            }

            function getAnnotationDetails(identifier) {
                var annotationToObject = annotationsModel.getObject(identifier);

                annotationTitleAndDesc.text = '<b>' + annotationToObject['title'] + '</b> &nbsp;'+ annotationToObject['desc'];
                annotationLoader.annotationTitle = annotationToObject['title'];
                annotationStartDate.text = annotationToObject['start'];
                annotationEndDate.text = annotationToObject['end'];
                annotationState.stateValue = annotationToObject['state'];
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (reversedConnections)
                    annotationConnectionsItem.annotationSelected(model.annotationFrom);
                else
                    annotationConnectionsItem.annotationSelected(model.annotationTo);
            }
            onPressAndHold:  {
                removeConnectionDialog.openConfirmDeletion(annotationLoader.connectionId, annotationLoader.connectionType, annotationLoader.annotationTitle);
            }
        }

        onLoaded: {
            if (reversedConnections) {
                item.getAnnotationDetails(model.annotationFrom);
            } else {
                item.getAnnotationDetails(model.annotationTo);
            }
        }
    }

    Common.ImageButton {
        anchors {
            bottom: parent.bottom
            right: parent.right
        }
        padding: units.nailUnit

        image: 'plus-24844'

        onClicked: newAnnotationConnection.openNewConnection('')
    }

    Common.SuperposedWidget {
        id: newAnnotationConnection

        property string connectionType: ''

        function openNewConnection(newConnectionType) {
            var date = new Date();
            newAnnotationConnection.connectionType = newConnectionType;
            load(qsTr('Nova connexió cap enrere'), 'annotations2/AnnotationsList', {interactive: true, selectedDate: date.toYYYYMMDDFormat(), filterPeriod: true});
        }

        Connections {
            target: newAnnotationConnection.mainItem

            onAnnotationSelected: {
                newAnnotationConnection.close();
                if (reversedConnections) {
                    connectionsModel.insertObject({annotationFrom: annotation, annotationTo: annotationId, connectionType: newAnnotationConnection.connectionType, created: (new Date()).toISOString()});
                    connectionsModel.selectTo();
                } else {
                    connectionsModel.insertObject({annotationFrom: annotationId, annotationTo: annotation, connectionType: newAnnotationConnection.connectionType, created: (new Date()).toISOString()});
                    connectionsModel.selectFrom();
                }
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
            connectionsModel.update();
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

    MessageDialog {
        id: removeConnectionDialog

        title: qsTr("Eliminació de connexió")

        property int connectionId
        property string connectionType
        property string connectionAnnotation

        text: qsTr("S'eliminarà la connexió de tipus «" + connectionType + "» amb l'anotació «" + connectionAnnotation + "». Vols continuar?")

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        function openConfirmDeletion(connectionId, connectionType, connectionAnnotation) {
            removeConnectionDialog.connectionId = connectionId;
            removeConnectionDialog.connectionType = connectionType;
            removeConnectionDialog.connectionAnnotation = connectionAnnotation;
            open();
        }

        onAccepted: {
            connectionsModel.removeObject(connectionId);
            connectionsModel.update();
        }
    }

    Component.onCompleted: connectionsModel.update()
}
