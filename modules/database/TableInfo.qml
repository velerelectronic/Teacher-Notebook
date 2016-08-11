import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

Rectangle {
    id: tableInfoItem

    color: 'pink'

    Common.UseUnits {
        id: units
    }

    property string tableName: ''
    property var fieldNames: []
    property var extendedFieldNames: []
    property int requiredHeight: basicInfoText.height + recordsList.contentItem.height

    onFieldNamesChanged: extendFieldNames()

    function extendFieldNames() {
        var newArray = [];
        newArray.push('index');
        console.log('old fieldnames', fieldNames.length);
        for (var i=0; i<fieldNames.length; i++) {
            newArray.push(fieldNames[i]);
        }
        extendedFieldNames = newArray;
    }

    SqlTableModel {
        id: tableModel
        tableName: tableInfoItem.tableName
        fieldNames: tableInfoItem.fieldNames

        Component.onCompleted: {
            select();
            console.log('field names count', fieldNames.length);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit
        spacing: units.nailUnit
        Text {
            id: basicInfoText
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr('Hi ha ') + tableModel.count + qsTr(' elements a la taula «') + tableModel.tableName + ('».');
        }
        ListView {
            id: recordsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: tableModel
            spacing: units.nailUnit

            clip: true

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                z: 2
                width: recordsList.width
                height: units.fingerUnit * 2

                border.color: 'black'

                ListView {
                    id: fieldNamesList

                    anchors.fill: parent
                    anchors.margins: units.nailUnit

                    orientation: ListView.Horizontal

                    model: extendedFieldNames
                    spacing: units.nailUnit
                    interactive: false

                    delegate: Text {
                        height: fieldNamesList.height
                        width: (fieldNamesList.width - fieldNamesList.spacing * (extendedFieldNames.length-1)) / extendedFieldNames.length
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        font.bold: true
                        text: modelData
                    }
                }
            }

            delegate: Rectangle {
                id: singleRecord

                z: 1
                width: recordsList.width
                height: units.fingerUnit * 2

                property var recordObj: model
                property var recordIndex: model.index

                ListView {
                    id: recordsFieldsList

                    anchors.fill: parent
                    anchors.margins: units.nailUnit

                    orientation: ListView.Horizontal
                    model: extendedFieldNames
                    spacing: units.nailUnit
                    interactive: false

                    delegate: Text {
                        height: recordsFieldsList.height
                        width: (recordsFieldsList.width - recordsFieldsList.spacing * (extendedFieldNames.length-1)) / extendedFieldNames.length
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        elide: Text.ElideRight
                        text: (modelData == 'index')?(singleRecord.recordIndex+1):singleRecord.recordObj[modelData]
                    }
                }
            }
        }
    }


    Component.onCompleted: {
        extendFieldNames();
    }
}
