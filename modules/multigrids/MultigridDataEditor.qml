import QtQuick 2.7
import QtQml.Models 2.3
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Flickable {
    id: multigridDataEditorBaseItem

    property int keyVariable
    property int keyValue
    property int secondVariable
    property int secondValue

    property string keyVariableTitle
    property string keyVariableDesc
    property string keyValueTitle
    property string keyValueDesc

    property string secondVariableTitle
    property string secondVariableDesc
    property string secondValueTitle
    property string secondValueDesc

    property int assignmentId: -1

    signal valueChanged()

    Common.UseUnits {
        id: units
    }

    MultigridVariablesModel {
        id: variablesModel
    }

    MultigridFixedValuesModel {
        id: variableAndFixedValuesModel
    }

    MultigridFixedValuesModel {
        id: secondValuesModel

        filters: ['variable=?']

        function update() {
            bindValues = [secondVariable];
            select();
        }
    }

    MultigridDataModel {
        id: dataModel
    }

    Item {
        width: multigridDataEditorBaseItem.width
        height: childrenRect.height

        GridLayout {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height
            columns: 2
            columnSpacing: units.nailUnit
            rowSpacing: units.nailUnit

            Text {
                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: units.fingerUnit
                Layout.alignment: Qt.AlignTop
                font.bold: true
                text: qsTr('Clau')
            }
            Text {
                id: keyVarText

                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.alignment: Qt.AlignTop

                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                text: '<p><b>' + keyVariableTitle + '</b></p><p>' + keyVariableDesc + '</p>'
            }
            Item {
                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: units.fingerUnit
                Layout.alignment: Qt.AlignTop
            }
            Text {
                id: keyValueText

                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                Layout.alignment: Qt.AlignTop

                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                text: '<p><b>' + keyValueTitle + '</b></p><p>' + keyValueDesc + '</p>'
            }
            Text {
                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: units.fingerUnit
                Layout.alignment: Qt.AlignTop

                font.bold: true
                text: qsTr('Variable')
            }
            Text {
                id: secondVarText

                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: contentHeight
                Layout.alignment: Qt.AlignTop

                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                text: '<p><b>' + secondVariableTitle + '</b></p><p>' + secondVariableDesc + '</p>'
            }
            Text {
                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: units.fingerUnit
                Layout.alignment: Qt.AlignTop

                font.bold: true
                text: qsTr('Valor actual')
            }
            Text {
                id: secondValueText

                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: contentHeight
                Layout.alignment: Qt.AlignTop

                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                text: '<p><b>' + secondValueTitle + '</b></p><p>' + secondValueDesc + '</p>'
            }
            Text {
                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: units.fingerUnit
                Layout.alignment: Qt.AlignTop

                font.bold: true
                text: qsTr('Modifica valor')
            }
            ListView {
                id: secondValueList

                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: contentItem.height
                Layout.alignment: Qt.AlignTop

                model: secondValuesModel

                spacing: units.nailUnit

                interactive: false

                delegate: Rectangle {
                    width: secondValueList.width
                    height: units.fingerUnit * 2

                    radius: units.nailUnit

                    color: (ListView.isCurrentItem)?'yellow':'#AAAAAA'

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit

                        Text {
                            Layout.preferredWidth: parent.width / 2
                            Layout.fillHeight: true

                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight

                            font.bold: true
                            font.pixelSize: units.readUnit
                            text: model.title
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight

                            font.pixelSize: units.readUnit
                            text: model.desc
                        }
                    }
                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            secondValueList.currentIndex = model.index;
                            saveValueButton.key = model.id;
                            console.log('savikng', model.id);
                        }
                    }
                }
            }
            Item {
                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: units.fingerUnit * 2
            }

            Common.TextButton {
                id: saveValueButton

                Layout.fillWidth: true
                Layout.fillHeight: true

                property int key: -1

                text: qsTr('Desa')

                onClicked: {
                    console.log('save button', saveValueButton.key);
                    if (saveValueButton.key>-1) {
                        var newVal = {
                            mainVariable: keyVariable,
                            mainValue: keyValue,
                            secondVariable: secondVariable,
                            secondValue: saveValueButton.key
                        }
                        console.log(newVal);
                        dataModel.select();
                        if (dataModel.insertObject(newVal)>-1)
                            valueChanged();
                        saveValueButton.key = -1;
                    }
                }
            }

            Item {
                Layout.preferredWidth: parent.width / 3
                Layout.preferredHeight: units.fingerUnit * 2
            }

            Common.TextButton {
                id: deleteValueButton

                Layout.fillWidth: true
                Layout.fillHeight: true

                color: 'red'
                text: qsTr('Esborra')

                onClicked: {
                    if (assignmentId > -1) {
                        dataModel.removeObject(assignmentId);
                        valueChanged();
                    }
                }
            }
        }
    }

    function getAllInfo() {

        function ifdef(obj, prop, b) {
            if (typeof (obj[prop]) !== 'undefined')
                return obj[prop];
            else
                return b;
        }

        function ifnull(a, b) {
            return (a==null)?b:a;
        }

        // Get key info
        var obj = variableAndFixedValuesModel.getVariablesAndValuesInfo("valueId=?", [keyValue]);

        if (obj != null) {
            keyVariableTitle = ifnull(obj['varTitle'], '');
            keyVariableDesc = ifnull(obj['varDesc'], '');

            keyValueTitle = ifnull(obj['valueTitle'], '');
            keyValueDesc = ifnull(obj['valueDesc'], '');
        }

        // Get non key info

        var obj = variableAndFixedValuesModel.getVariablesAndValuesInfo("varId=?", [secondVariable]);

        if (obj != null) {
            secondVariableTitle = ifnull(obj['varTitle'], '');
            secondVariableDesc = ifnull(obj['varDesc'], '');
        }

        var secondValueObj = dataModel.getAllDataInfo(keyVariable, keyValue, secondVariable);
        if (secondValueObj != null) {
            assignmentId = secondValueObj['id'];
            secondValueTitle = ifnull(secondValueObj['secondValueTitle'], '');
            secondValueDesc = ifnull(secondValueObj['secondValueDesc'], '');
        } else {
            assignmentId = -1;
            secondValueTitle = qsTr("- No definit encara -")
            secondValueDesc = "";
        }


        secondValuesModel.update();
    }

    Component.onCompleted: getAllInfo()
}
