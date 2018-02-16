import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Common.GeneralListView {
    id: gridsList

    anchors.fill: parent

    Common.UseUnits {
        id: units
    }

    signal openCard(string page, var pageProperties, var cardProperties)

    property int selectedMultigrid: -1

    MultigridsModel {
        id: gridsModel

        function newGrid(title, desc) {
            insertObject({title: title, desc: desc, config: ''});
            select();
        }

        function updateGrid(id, obj) {
            updateObject(id, obj);
            update();
        }

        Component.onCompleted: select()
    }

    model: gridsModel

    toolBarHeight: 0
    headingBar: Rectangle {
        color: 'red'

        RowLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            spacing: units.nailUnit

            Text {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width / 3

                verticalAlignment: Text.AlignVCenter
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                text: qsTr('Títol')
            }

            Text {
                Layout.fillHeight: true
                Layout.fillWidth: true

                verticalAlignment: Text.AlignVCenter
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                text: qsTr('Descripció')
            }
        }
    }

    delegate: Rectangle {
        width: gridsList.width
        height: Math.max(titleEditor.requiredHeight, descEditor.requiredHeight)

        color: (model.id == selectedMultigrid)?'yellow':((selectGridMouseArea.enabled)?'white':'gray')

        RowLayout {
            anchors.fill: parent
            anchors.margins: units.nailUnit
            spacing: units.nailUnit

            Common.EditableText {
                id: titleEditor

                Layout.fillHeight: true
                Layout.preferredWidth: parent.width / 3

                text: model.title

                onTextChangeAccepted: {
                    gridsModel.updateGrid(selectedMultigrid, {title: text});
                }

                onEditorClosed: selectGridMouseArea.enabled = true;
            }

            Common.EditableText {
                id: descEditor

                Layout.fillHeight: true
                Layout.fillWidth: true

                text: model.desc

                onTextChangeAccepted: {
                    gridsModel.updateGrid(selectedMultigrid, {desc: text});
                }

                onEditorClosed: selectGridMouseArea.enabled = true;
            }
        }
        MouseArea {
            id: selectGridMouseArea

            anchors.fill: parent
            onClicked: {
                selectedMultigrid = model.id;
                openCard('multigrids/ShowMultigrid', {multigrid: selectedMultigrid}, {headingText: qsTr("Graella"), backgroundColor: '#888888'});
            }
            onPressAndHold: {
                enabled = false;
            }
        }

        Connections {
            id: oneGridViewConnections
        }
    }

    Common.SuperposedButton {
        anchors {
            bottom: parent.bottom
            right: parent.right
        }

        size: units.fingerUnit * 1.5
        imageSource: 'plus-24844'

        onClicked: {
            var date = new Date();
            gridsModel.newGrid(qsTr('Graella') + date.toLocaleDateString(), 'Nova graella');
        }
    }
}

