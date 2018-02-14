import QtQuick 2.7
import QtQml.Models 2.3
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Item {
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

    MultigridVariablesAndValuesModel {
        id: variableAndValuesModel
    }

    MultigridFixedValuesModel {
        id: secondValuesModel

        filters: ['variable=?']

        function update() {
            bindValues = [secondVariable];
            select();
        }
    }

    MultigridAssignmentDataModel {
        id: assignmentsModel
    }

    MultigridDataModel {
        id: saveDataModel
    }

    Flickable {
        anchors.fill: parent

        contentWidth: innerDataEditor.width
        contentHeight: innerDataEditor.height

        Item {
            id: innerDataEditor

            width: multigridDataEditorBaseItem.width
            height: childrenRect.height

            GridLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: keyVarHeight + secondVarHeight + rowSpacing
                columns: 3
                columnSpacing: 0
                rowSpacing: units.fingerUnit

                property int keyVarHeight: Math.max(labelKey.contentHeight, keyVarText.contentHeight, keyValueText.contentHeight)
                property int secondVarHeight: Math.max(labelSecondVar.contentHeight, secondVarText.contentHeight, secondValueText.contentHeight)

                Common.BoxedText {
                    id: labelKey

                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.keyVarHeight
                    Layout.alignment: Qt.AlignTop
                    boldFont: true
                    padding: units.nailUnit
                    text: qsTr('Clau')
                }
                Common.BoxedText {
                    id: keyVarText

                    Layout.preferredWidth: parent.width * 0.4
                    Layout.preferredHeight: parent.keyVarHeight
                    Layout.alignment: Qt.AlignTop

                    fontSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    padding: units.nailUnit

                    text: '<p><b>' + keyVariableTitle + '</b></p><p>' + keyVariableDesc + '</p>'
                }
                Common.BoxedText {
                    id: keyValueText

                    Layout.preferredWidth: parent.width * 0.4
                    Layout.preferredHeight: parent.keyVarHeight
                    Layout.alignment: Qt.AlignTop

                    fontSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    padding: units.nailUnit

                    text: '<p><b>' + keyValueTitle + '</b></p><p>' + keyValueDesc + '</p>'
                }
                Common.BoxedText {
                    id: labelSecondVar

                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.secondVarHeight
                    Layout.alignment: Qt.AlignTop

                    boldFont: true
                    padding: units.nailUnit
                    text: qsTr('Variable')
                }
                Common.BoxedText {
                    id: secondVarText

                    Layout.preferredWidth: parent.width * 0.4
                    Layout.preferredHeight: parent.secondVarHeight
                    Layout.alignment: Qt.AlignTop

                    fontSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    padding: units.nailUnit

                    text: '<p><b>' + secondVariableTitle + '</b></p><p>' + secondVariableDesc + '</p>'
                }
                Common.BoxedText {
                    id: secondValueText

                    Layout.preferredWidth: parent.width * 0.4
                    Layout.preferredHeight: parent.secondVarHeight
                    Layout.alignment: Qt.AlignTop

                    fontSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    padding: units.nailUnit

                    text: '<p><b>' + secondValueTitle + '</b></p><p>' + secondValueDesc + '</p>'
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    Layout.alignment: Qt.AlignTop

                    font.bold: true
                    text: qsTr('Modifica valor')
                }
                ListView {
                    id: secondValueList

                    Layout.preferredWidth: parent.width * 0.4
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
                            //dataModel.select();
                            if (saveDataModel.insertObject(newVal)>-1)
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
                            saveDataModel.removeObject(assignmentId);
                            valueChanged();
                        }
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
        var obj = null;
        variableAndValuesModel.getVariablesAndValuesInfo(["valueId=?"], [keyValue]);

        if (variableAndValuesModel.count>0) {
            obj = variableAndValuesModel.getObjectInRow(0);
        }

        if (obj !== null) {
            keyVariableTitle = ifnull(obj['varTitle'], '');
            keyVariableDesc = ifnull(obj['varDesc'], '');

            keyValueTitle = ifnull(obj['valueTitle'], '');
            keyValueDesc = ifnull(obj['valueDesc'], '');
        }

        // Get non key info

        var secondObj = null;
        variableAndValuesModel.getVariablesAndValuesInfo(["varId=?"], [secondVariable]);
        if (variableAndValuesModel.count>0) {
            secondObj = variableAndValuesModel.getObjectInRow(0);
        }

        if (secondObj !== null) {
            secondVariableTitle = ifnull(secondObj['varTitle'], '');
            secondVariableDesc = ifnull(secondObj['varDesc'], '');
        }

        var secondValueObj = assignmentsModel.getAllDataInfo(keyVariable, keyValue, secondVariable);

        if (secondValueObj !== null) {
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
