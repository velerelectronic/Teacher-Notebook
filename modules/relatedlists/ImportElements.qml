import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import FileIO 1.0
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/files' as Files

Item {
    property string fileName: ''
    property SqlTableModel categorizedModel

    signal close()

    Common.UseUnits {
        id: units
    }

    FileIO {
        id: fileio

        source: fileName

        function acquireIntoModel() {
            var contents = "";
            if (fileName !== '') {
                contents = fileio.read();
            }
            var re = /(.+)\n(.+)\n(.+)(?:\n\n+|$)/g;
            newElementsModel.clear();
            var matches = re.exec(contents);
            while (matches !== null) {
                newElementsModel.append({category: matches[1], element: matches[2], description: matches[3]});
                matches = re.exec(contents);
            }
        }
    }

    ListModel {
        id: newElementsModel

        ListElement {
            category: ''
            element: ''
            description: ''
        }
    }

    Common.SteppedPage {
        id: steppedPage

        color: 'gray'

        anchors.fill: parent
        moveForwardEnabled: false
        moveBackwardsEnabled: false

        Common.SteppedSection {
            Files.FileSelector {
                anchors.fill: parent

                selectFiles: true

                onFileSelected: {
                    fileName = file;
                    steppedPage.moveForward();
                    fileio.acquireIntoModel();
                }
            }
        }

        Common.SteppedSection {
            ColumnLayout {
                anchors.fill: parent

                ListView {
                    id: newElementsList

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    model: newElementsModel

                    headerPositioning: ListView.OverlayHeader
                    header: Rectangle {
                        z: 2
                        height: units.fingerUnit
                        width: newElementsList.width

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit
                            Text {
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Categoria')
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Element')
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Descripció')
                            }
                        }
                    }

                    spacing: units.nailUnit

                    delegate: Rectangle {
                        z: 1
                        height: Math.max(units.fingerUnit * 2, categoryText.contentHeight, elementText.contentHeight, descriptionText.contentHeight) + 2 * units.nailUnit
                        width: newElementsList.width

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit
                            Text {
                                id: categoryText
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.category
                            }
                            Text {
                                id: elementText
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.element
                            }
                            Text {
                                id: descriptionText
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.description
                            }
                        }
                    }
                }
                Button {
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.fillWidth: true
                    text: qsTr('Importa tot')
                    onClicked: {
                        for (var i=0; i<newElementsModel.count; i++) {
                            var object = newElementsModel.get(i);
                            categorizedModel.insertObject({category: object['category'], element: object['element'], description: object['description']});
                        }
                        categorizedModel.select();
                        steppedPage.moveForward();
                    }
                }
            }
        }
        Common.SteppedSection {
            Text {
                anchors.fill: parent
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr('Importació feta!\n\nClica per tancar.')
                MouseArea {
                    anchors.fill: parent
                    onClicked: close()
                }
            }
        }
    }

}

