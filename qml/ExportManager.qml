import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import Qt.labs.folderlistmodel 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///components' as Components

BasicPage {
    id: exportManager

    pageTitle: qsTr('Exportador')

    property int selectedRemoveId: -1

    Common.UseUnits {
        id: units
    }

    Models.ScheduleModel {
        id: importModel

        property int fieldsLength: fieldNames.length
        signal selected()

        Component.onCompleted: {
            select();
            selected();
        }
    }

    Models.ExtendedAnnotations {
        id: receptorModel
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

                highlight: Rectangle {
                    color: 'yellow'
                    width: mainList.width
                    height: units.fingerUnit * 3
                }

                delegate: Rectangle {
                    id: recordRowItem
                    z: 1
                    width: mainList.width
                    height: units.fingerUnit * 3
                    border.color: 'black'
                    color: 'transparent'

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

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mainList.currentIndex = model.index;
                            var fields = fieldsList.record;
                            selectedRemoveId = fields['id'];
                            var state = (fields['state'] == 'done')?3:0;
                            var obj = {
                                title: fields['id'] + " " + fields['event'],
                                created: fields['created'],
                                desc: fields['desc'],
                                labels: 'import',
                                start: fields['startDate'] + " " + fields['startTime'],
                                end: fields['endDate'] + " " + fields['endTime'],
                                state: state
                            }

                            receptorModel.insertObject(obj);

                            receptorList.setSource('qrc:///components/RelatedAnnotations.qml', {mainIdentifier: obj['title']});
                        }
                    }
                }

                Connections {
                    target: importModel
                    onSelected: mainList.currentIndex = -1;
                }
            }

            Loader {
                id: receptorList
                Layout.fillWidth: true
                Layout.preferredHeight: parent.width / 2
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 2
                text: qsTr('Esborra original')
                onClicked: {
                    importModel.removeObject(selectedRemoveId);
                    importModel.select();
                    importModel.selected();
                }
            }
        }
    }
}
