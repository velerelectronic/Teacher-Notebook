import QtQuick 2.7

ListView {
    id: individualsGrid
    width: editorList.width
    height: contentItem.height
    interactive: false
    spacing: units.nailUnit

    header: Text {
        width: individualsGrid.width
        height: units.fingerUnit
    }

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
                        onTextChanged: editItem.setChanges(true)
                        Component.onCompleted: singleIndividual.fillIndividualValues()
                    }
                    TextField {
                        id: itemCommentField
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        Layout.preferredHeight: height
                        onTextChanged: editItem.setChanges(true)
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

    footer: Common.Button {
        width: individualsGrid.width
        height: units.fingerUnit * 2
        text: qsTr('Afegeix individu')
        onClicked: addIndividualDialog.open();
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
                if (item.individualValue != '') {
                    if (gridModel.insertObject({created: now.toISOString(),moment: moment, group: groupEditor.text,individual: item.individualName,variable: variableEditor.text,value: item.individualValue,comment: item.individualComment}))
                        number++;
                }
            }
        }
        editItem.setChanges(false);
        return number;
    }

    Connections {
        target: groupEditor
        onTextChanged: individualsGrid.fillValues()
    }

    Component.onCompleted: fillValues()
}
