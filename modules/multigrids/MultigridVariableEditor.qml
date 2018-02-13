import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import 'qrc:///common' as Common

Item {
    signal titleChanged(int variable, string title)
    signal descChanged(int variable, string desc)
    signal variableCreated(string title, string desc, bool isKey)
    signal isKeyChanged(int variable, bool value)
    signal variableValuesChanged()
    signal variableValueAdded()

    signal variableRemoved(int variable)
    signal close()

    property int multigrid: -1
    property int variable: -1

    Common.UseUnits {
        id: units
    }

    MultigridVariablesModel {
        id: variablesModel
    }

    MultigridFixedValuesModel {
        id: valuesModel

        function update() {
            filters = ['variable=?'];
            bindValues = [variable];
            select();
        }

        function newValue(title, desc) {
            var res = -1;
            if (variable > -1) {
                console.log('insertiing');
                res = insertObject({variable: variable, title: title, desc: desc});
                update();
            }
            return res;
        }

        function updateTitle(valueId, title) {
            updateObject(valueId, {title: title});
            update();
            variableValuesChanged();
        }

        function updateDesc(valueId, desc) {
            updateObject(valueId, {desc: desc});
            update();
            variableValuesChanged();
        }

        function removeValue(valueId) {
            removeObject(valueId);
            update();
        }

        Component.onCompleted: update()
    }

    GridLayout {
        id: mainLayout

        anchors.fill: parent

        columns: 2
        rows: 4

        Text {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            text: qsTr("Títol")
        }

        Common.EditableText {
            id: titleEditor

            Layout.preferredHeight: titleEditor.requiredHeight
            Layout.fillWidth: true

            onTextChangeAccepted: {
                if (variable > -1) {
                    variablesModel.updateObject(variable, {title: text});
                    titleChanged(variable, text);
                } else {
                    var newVar = variablesModel.insertObject({multigrid: multigrid, title: text});
                    if (newVar > -1) {
                        variable = newVar;
                        variableCreated(text, '', false);
                    }
                }
            }
        }

        Text {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            text: qsTr("Descripció")
        }

        Common.EditableText {
            id: descEditor

            Layout.preferredHeight: descEditor.requiredHeight
            Layout.fillWidth: true

            onTextChangeAccepted: {
                if (variable > -1) {
                    variablesModel.updateObject(variable, {desc: text});
                    descChanged(variable, text);
                } else {
                    var newVar = variablesModel.insertObject({multigrid: multigrid, desc: text});
                    if (newVar > -1) {
                        variable = newVar;
                        variableCreated(text, '', false);
                    }
                }
            }
        }

        Text {
            Layout.fillHeight: true
            Layout.fillWidth: true

            text: qsTr("Variable principal")
        }

        CheckBox {
            id: checkKeyEditor

            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true

            text: qsTr('Activar com a variable principal')

            onClicked: {
                if (variable>-1) {
                    variablesModel.updateObject(variable, {isKey: (checked)?1:0});
                    isKeyChanged(variable, checked);
                }
            }
        }

        Text {
            Layout.fillHeight: true
            Layout.fillWidth: true

            text: qsTr("Valors definits")
        }

        Common.GeneralListView {
            id: valuesListView

            Layout.preferredHeight: requiredHeight
            Layout.fillWidth: true

            interactive: false
            model: valuesModel

            toolBarHeight: 0
            headingBar: Rectangle {
                width: valuesListView.width
                height: units.fingerUnit * 2

                color: Qt.lighter('gray')

                RowLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit

                    Text {
                        Layout.preferredWidth: parent.width / 2
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr('Valor')
                    }
                    Text {
                        Layout.preferredWidth: parent.width / 2
                        Layout.fillHeight: true

                        font.pixelSize: units.readUnit
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr('Descripció')
                    }
                }
            }

            delegate: Rectangle {
                id: oneValueRect

                width: valuesListView.width
                height: Math.max(titleText.height, descText.height)

                property int valueId: model.id

                MouseArea {
                    anchors.fill: parent
                    onPressAndHold: valuesModel.removeValue(oneValueRect.valueId)
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit

                    Common.EditableText {
                        id: titleText

                        Layout.preferredHeight: requiredHeight
                        Layout.preferredWidth: parent.width / 2

                        text: model.title

                        onTextChangeAccepted: valuesModel.updateTitle(oneValueRect.valueId, text)
                    }
                    Common.EditableText {
                        id: descText

                        Layout.preferredHeight: requiredHeight
                        Layout.preferredWidth: parent.width / 2

                        text: model.desc

                        onTextChangeAccepted: valuesModel.updateDesc(oneValueRect.valueId, text)
                    }
                }

            }

            Common.SuperposedButton {
                id: addValueButton

                anchors {
                    right: valuesListView.right
                    bottom: valuesListView.bottom
                }

                size: units.fingerUnit
                imageSource: 'plus-24844'

                onClicked: {
                    if (valuesModel.newValue(qsTr('Valor ') + (valuesModel.count+1).toString(), '') > -1)
                        variableValueAdded();
                }
            }
        }

        Common.TextButton {
            id: actionButton

            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            color: 'red'

            text: qsTr("Elimina")

            onClicked: {
                if (variable > -1) {
                    variablesModel.removeObject(variable);
                    variableRemoved(variable);
                }
            }
        }

        Common.TextButton {
            Layout.fillHeight: true
            Layout.fillWidth: true

            text: qsTr("Tanca")

            onClicked: close()
        }
    }

    Component.onCompleted: {
        if (variable > -1) {
            console.log('key....', variable);
            var obj = variablesModel.getObject(variable);
            titleEditor.text = obj['title'];
            descEditor.text = obj['desc'];
            checkKeyEditor.checked = (obj['isKey'] == 1);
        }
    }
}
