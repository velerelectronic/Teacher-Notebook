import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Rectangle {
    id: eventCharacteristicsEditor

    property string pageTitle: qsTr("Editor de característiques d'esdeveniments")

    property int event
    property SqlTableModel characteristicsModel
    property SqlTableModel writeModel

    Common.UseUnits { id: units }

    Models.ProjectsModel {
        id: projectsModel
    }

    Models.CharacteristicsModel {
        id: characteristicsModel

        property int project: -1

        filters: ["ref='" + project + "'"]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            font.pixelSize: units.readUnit
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr('Selecciona un projecte per mostrar només les seves característiques')
        }

        ListView {
            id: projectsList

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            orientation: ListView.Horizontal
            model: projectsModel

            delegate: Common.BoxedText {
                height: projectsList.height
                width: units.fingerUnit * 4
                color: 'transparent'
                margins: units.nailUnit
                fontSize: units.readUnit
                text: model.name
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        projectsList.currentIndex = model.index;
                        characteristicsModel.project = model.id;
                        characteristicsModel.select();
                    }
                }
            }

            highlightFollowsCurrentItem: true

            highlightMoveDuration: 0

            highlight: Rectangle {
                height: projectsList.height
                width: units.fingerUnit * 4
                color: 'yellow'
                border.color: 'black'
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            font.pixelSize: units.readUnit
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("Selecciona les característiques que s'assignen a l'esdeveniment")
        }

        ListView {
            id: characteristicsList

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: characteristicsModel

            header: Common.BoxedText {
                width: characteristicsList.width
                height: (characteristicsModel.count === 0)?units.fingerUnit * 2:0
                visible: height > 0
                color: 'transparent'
                fontSize: units.readUnit
                margins: units.nailUnit
                text: qsTr('No hi ha característiques definides en aquest projecte.')
            }

            delegate: Rectangle {
                id: characteristicRow

                property int assignmentId: -1
                property string comment: ''
                property int characteristic: model.id

                width: characteristicsList.width
                height: units.fingerUnit * 2

                color: (eventCharacteristicsModel.count > 0)?'green':'white'

                Models.EventCharacteristicsModel {
                    id: eventCharacteristicsModel
                    filters: [
                        "characteristic='" + characteristicRow.characteristic + "'",
                        "event='" + eventCharacteristicsEditor.event + "'"
                    ]
                    Component.onCompleted: select()

                    onCountChanged: characteristicRow.getAssignmentData()
                }

                function getAssignmentData() {
                    if (eventCharacteristicsModel.count>0) {
                        var obj = eventCharacteristicsModel.getObjectInRow(0);
                        var comment = obj['comment'];
                        characteristicRow.comment = comment;
                        characteristicRow.assignmentId = obj['id'];
                    } else {
                        characteristicRow.comment = '';
                        characteristicRow.assignmentId = -1;
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height

                        image: 'outline-27146'

                        onClicked: {
                            if (eventCharacteristicsModel.count == 0) {
                                characteristicRow.insertAssigment('');
                            } else {
                                if (characteristicRow.comment == '') {
                                    eventCharacteristicsModel.removeObjectInRow(0);
                                } else {
                                    console.log("El comentari s'ha d'esborrar abans.");
                                }
                            }
                            eventCharacteristicsModel.select();
                        }
                    }

                    Common.BoxedText {
                        Layout.preferredWidth: parent.width / 3
                        Layout.fillHeight: true
                        color: 'transparent'
                        fontSize: units.readUnit
                        margins: units.nailUnit
                        text: model.title
                    }
                    Common.BoxedText {
                        Layout.preferredWidth: parent.width / 3
                        Layout.fillHeight: true
                        color: 'transparent'
                        fontSize: units.readUnit
                        margins: units.nailUnit
                        text: model.desc
                    }
                    Common.BoxedText {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: 'transparent'
                        fontSize: units.readUnit
                        margins: units.nailUnit
                        text: characteristicRow.comment

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                //messageDialog.open();
                                connectDialog.target = commentEditor2;
                                commentEditor2.showDialog(characteristicRow.comment);

                                //commentEditor.comment = characteristicRow.comment;
                                //commentEditor.open();
                            }

                            /*
                            function saveComment() {
                                return true;
                            }
                            */
                        }
                        Connections {
                            id: connectDialog

                            target: null

                            onAcceptingDialog: {
                                console.log('Closing');
                                console.log(content);
                                connectDialog.target = null;

                                console.log('Desant ' + model.id + "-" + content)
                                characteristicRow.insertAssigment(content);
                            }
                        }
                    }
                }
                /*
                MessageDialog {
                    id: messageDialog
                    title: 'hola'

                    Rectangle {
                        anchors.fill: parent
                        color: 'yellow'
                        border.color: 'blue'
                    }
                }
                */

                Dialog {
                    id: commentEditor

                    property alias comment: commentEditorText3.text

                    visible: false
                    title: qsTr('Comentari')

                    width: eventCharacteristicsEditor.width * 0.8

                    Editors.TextAreaEditor2 {
                        id: commentEditorText3

                        width: parent.width
                        height: eventCharacteristicsEditor.height * 0.5
                    }

                    standardButtons: StandardButton.Ok | StandardButton.Cancel

                    onAccepted: {
                        console.log('Desant ' + model.id + "-" + commentEditor.comment)
                        characteristicRow.insertAssigment(commentEditor.comment);
                    }
                }

                function insertAssigment(newComment) {
                    if (characteristicRow.assignmentId > -1) {
                        eventCharacteristicsModel.updateObject({id: characteristicRow.assignmentId, comment: newComment});
                        eventCharacteristicsModel.select();
                    } else {
                        eventCharacteristicsModel.insertObject({event: eventCharacteristicsEditor.event, characteristic: characteristicRow.characteristic, comment: newComment });
                    }
                }
            }
        }
    }

    Component.onCompleted: projectsModel.select();

    Common.CustomDialog {
        id: commentEditor2
        anchors.fill: parent

        customItem: Rectangle {
            id: innerEditor
            property alias content: commentEditorText.text
            color: 'white'

            ColumnLayout {
                anchors.fill: parent

                Editors.TextAreaEditor2 {
                    id: commentEditorText
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    RowLayout {
                        anchors.fill: parent
                        Button {
                            text: qsTr('Accepta')
                            onClicked: commentEditor2.closeDialog(innerEditor.content)
                        }
                    }
                }

            }

        }

    }

    Component {
        id: newDialog
        Rectangle {
            id: commentEditorText2
            color: 'yellow'
            border.color: 'pink'
            property string text: ''

            width: units.fingerUnit * 4
            height: units.fingerUnit * 4

            Text {
                anchors.fill: parent
                text: 'Holaa'
                font.pixelSize: units.glanceUnit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Keys.onBackPressed: console.log('BACK')
        }

    }
}

