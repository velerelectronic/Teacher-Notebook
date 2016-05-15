import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import Qt.labs.folderlistmodel 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

BasicPage {
    id: exportManager

    pageTitle: qsTr('Exportador')

    Common.UseUnits {
        id: units
    }

    Models.ScheduleModel {
        id: importModel

        property int fieldsLength: fieldNames.length

        Component.onCompleted: {
            select();
        }
    }

    mainPage: Rectangle {
        ColumnLayout {
            anchors.fill: parent

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(units.fingerUnit, contentHeight)
                font.pixelSize: units.glanceUnit
                text: qsTr('Taula ') + importModel.tableName
            }

            ListView {
                id: mainList
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                model: importModel.count

                headerPositioning: ListView.OverlayHeader

                header: Rectangle {
                    id: mainHeader
                    z: 2
                    width: mainList.width
                    height: units.fingerUnit * 2
                    ListView {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        orientation: ListView.Horizontal
                        interactive: false
                        model: importModel.fieldsLength
                        header: Text {
                            width: mainHeader.width / (importModel.fieldsLength + 1)
                            height: mainHeader.height
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.bold: true
                            font.italic: true
                            text: qsTr('Fila')
                        }

                        delegate: Text {
                            width: mainHeader.width / (importModel.fieldsLength + 1)
                            height: mainHeader.height
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.bold: true
                            text: importModel.fieldNames[model.index]

                        }
                    }
                }

                delegate: Rectangle {
                    id: recordRowItem
                    z: 1
                    width: mainList.width
                    height: units.fingerUnit * 3
                    border.color: 'black'

                    property int index: model.index
                    property int row: model.index+1

                    ListView {
                        id: fieldsList
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        orientation: ListView.Horizontal
                        interactive: false

                        property int fieldWidth: fieldsList.width / (importModel.fieldsLength+1)
                        model: importModel.fieldsLength

                        Component.onCompleted: {
                            fieldsList.record = importModel.getObjectInRow(recordRowItem.index);
                        }

                        property var record: importModel.getObjectInRow(recordRowItem.index)

                        header: Text {
                            width: fieldsList.fieldWidth
                            height: fieldsList.height
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: recordRowItem.row
                        }

                        delegate: Text {
                            width: fieldsList.fieldWidth
                            height: fieldsList.height
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: {
                                var data = fieldsList.record[importModel.fieldNames[modelData]];
                                return data;
                            }
                        }
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 2
                text: qsTr('Endavant...')
                onClicked: {}
            }
        }
    }
}
