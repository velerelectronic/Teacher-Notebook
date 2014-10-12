import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1

import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

import PersonalTypes 1.0

Rectangle {
    id: editItem
    color: 'white'

    property string pageTitle: qsTr("Editor de la graella")
    property var buttons: buttonsModel

    signal savedGridValues(int number)
    signal closeGridEditor

    SqlTableModel {
        id: gridModel
        tableName: 'assessmentGrid'
        fieldNames: ['id','created','moment','group','individual','variable','value','comment']
    }

    ListModel {
        id: buttonsModel
        ListElement {
            method: 'closeGeneralEditor'
            image: 'road-sign-147409'
        }
        ListElement {
            method: 'saveGridValues'
            image: 'floppy-35952'
        }
    }

    Flickable {
        id: editFlickable

        anchors.fill: parent
        anchors.margins: units.nailUnit
        contentHeight: editItemRectangle.height
        contentWidth: width
        clip: true

        Rectangle {
            id: editItemRectangle
            color: 'white'
            width: editFlickable.contentWidth
            height: childrenRect.height

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: units.fingerUnit

                GridLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    columns: 2
                    columnSpacing: units.readUnit
                    rowSpacing: units.fingerUnit

                    Text {
                        id: momentText
                        Layout.alignment: Qt.AlignTop
                        width: contentWidth
                        text: qsTr('Moment')
                    }
                    Flow {
                        id: momentField
                        Layout.fillWidth: true
                        Layout.preferredHeight: childrenRect.height

                        Editors.DatePicker {
                            id: datePicker
                        }
                        Editors.TimePicker {
                            id: timePicker
                        }
                        Button {
                            text: qsTr('Ara')
                            onClicked: editItem.fillNowMoment()
                        }
                    }
                    Text {
                        id: groupText
                        width: contentWidth
                        Layout.alignment: Qt.AlignTop
                        text: qsTr('Grup')
                    }
                    Editors.FieldEditor {
                        id: groupEditor
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        Layout.preferredHeight: height
                    }
                    Text {
                        id: variableText
                        width: contentWidth
                        Layout.alignment: Qt.AlignTop
                        text: qsTr('Variable')
                    }
                    Editors.FieldEditor {
                        id: variableEditor
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        Layout.preferredHeight: height
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    ExclusiveGroup {
                        id: individualEditorType
                        onCurrentChanged: {
                            if (current.objectName == 'tableEditor') {
                                individualsEditor.sourceComponent = individualsTableEditor;
                            } else {
                                individualsEditor.sourceComponent = singleIndividualEditor;
                            }
                        }
                    }

                    Button {
                        checkable: true
                        exclusiveGroup: individualEditorType
                        text: qsTr("Taula d'individus")
                        checked: true
                        objectName: 'tableEditor'
                    }
                    Button {
                        checkable: true
                        exclusiveGroup: individualEditorType
                        text: qsTr('Afegir un sol individu')
                    }
                }

                Loader {
                    id: individualsEditor

                    Layout.fillWidth: true
                    Layout.preferredHeight: item.height
                }
            }

            Component.onCompleted: {
                fillNowMoment();
                fillGeneralValues();
            }
        }
    }

    Component {
        id: individualsTableEditor

        ListView {
            id: individualsGrid
            height: contentItem.height
            interactive: false
            spacing: units.nailUnit

            delegate: Rectangle {
                id: singleIndividual

                objectName: 'individualItem'
                property string individualName: modelData
                property alias individualValue: itemValueEditor.text
                property alias individualComment: itemCommentField.text

                radius: units.fingerUnit / 2
                color: (itemValueEditor.text == '')?'#F7D358':'#D0FA58'
                anchors.margins: units.readUnit
                width: individualsGrid.width
                height: childrenRect.height + 2 * radius

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: parent.radius
                    spacing: units.nailUnit
                    Text {
                        id: indivText
                        Layout.preferredWidth: units.fingerUnit * 3
                        Layout.alignment: Qt.AlignTop
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: singleIndividual.individualName
                    }
                    Item {
                        Layout.preferredHeight: childrenRect.height
                        Layout.fillWidth: true
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: units.nailUnit
                            Editors.FieldEditor {
                                id: itemValueEditor
                                Layout.alignment: Qt.AlignTop
                                Layout.fillWidth: true
                                Layout.preferredHeight: height
                                Component.onCompleted: singleIndividual.fillIndividualValues()
                            }
                            TextField {
                                id: itemCommentField
                                Layout.alignment: Qt.AlignTop
                                Layout.fillWidth: true
                                Layout.preferredHeight: height
                            }
                        }

                    }

                }

                Connections {
                    target: variableEditor
                    onTextChanged: singleIndividual.fillIndividualValues()
                }

                function fillIndividualValues() {
                    itemValueEditor.model = gridModel.selectDistinct('value','id','variable=' + "'" + variableEditor.text + "'",false);
                }

            }

            function fillValues() {
                individualsGrid.model = gridModel.selectDistinct('individual','individual','\"group\"=\''+groupEditor.text + '\'',true);
            }

            function saveGridValues() {
                var now = new Date();

                var number = 0;
                for (var i=0; i<individualsGrid.contentItem.children.length; i++) {
                    var item = individualsGrid.contentItem.children[i];
                    if (item.objectName == 'individualItem') {
                        var moment = datePicker.dateString() + ' ' + timePicker.timeString();
                        if (gridModel.insertObject({created: now.toISOString(),moment: moment, group: groupEditor.text,individual: item.individualName,variable: variableEditor.text,value: item.individualValue,comment: item.individualComment}))
                            number++;
                    }
                }
                return number;
            }

            Connections {
                target: groupEditor
                onTextChanged: individualsGrid.fillValues()
            }

            Component.onCompleted: fillValues()
        }
    }

    Component {
        id: singleIndividualEditor

        GridLayout {
            id: valuesGrid
            columns: 2
            property real labelsWidth: Math.max(indivText.width, valueText.width, commentText.width)
            anchors.left: parent.left
            anchors.right: parent.right
            rowSpacing: units.fingerUnit

            Text {
                id: indivText
                width: contentWidth
                Layout.alignment: Qt.AlignTop
                text: qsTr('Individu')
            }
            Editors.FieldEditor {
                id: individualEditor
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.preferredHeight: height
                model: individualModel
                field: 'individual'
            }
            Text {
                id: valueText
                width: contentWidth
                Layout.alignment: Qt.AlignTop
                text: qsTr('Valor')
            }
            Editors.FieldEditor {
                id: valueEditor
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.preferredHeight: height
                model: valueModel
                field: 'value'
            }
            Text {
                id: commentText
                width: contentWidth
                Layout.alignment: Qt.AlignTop
                text: qsTr('Comentari')
            }
            TextField {
                id: commentField
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.preferredHeight: height
            }

            function fillValues() {
                individualEditor.model = gridModel.selectDistinct('individual','id',"\"group\"='" + groupEditor.text + "'", false);
                variableEditor.model = gridModel.selectDistinct('variable','id','',false);
                valueEditor.model = gridModel.selectDistinct('value','id','variable=' + "'" + variableEditor.text + "'",false);
            }

            function saveGridValues() {
                var now = new Date();
                var moment = datePicker.dateString() + ' ' + timePicker.timeString();
                if (gridModel.insertObject({created: now.toISOString(),moment: moment, group: groupEditor.text,individual: individualEditor.text,variable: variableEditor.text,value: valueEditor.text,comment: commentField.text}))
                    return 1;
                else
                    return 0;
            }

            Connections {
                target: groupEditor
                onTextChanged: valuesGrid.fillValues()
            }
            Connections {
                target: variableEditor
                onTextChanged: valuesGrid.fillValues()
            }

            Component.onCompleted: fillValues()
        }

    }

    MessageDialog {
        id: saveDialog
        title: qsTr('Desar els valors')
        text: qsTr("Es desaran els valors a la graella d'avaluació.\nVols continuar?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: savedGridValues(individualsEditor.item.saveGridValues())
    }

    function fillNowMoment() {
        var nowDate = new Date();
        datePicker.setDate(nowDate);
        timePicker.setDateTime(nowDate);
    }

    function fillGeneralValues() {
        groupEditor.model = gridModel.selectDistinct('\"group\"','id','',false);
        variableEditor.model = gridModel.selectDistinct('variable','id','',false);
    }

    function saveGridValues() {
        saveDialog.open();
    }

    function closeGeneralEditor() {
        closeGridEditor();
    }
}
