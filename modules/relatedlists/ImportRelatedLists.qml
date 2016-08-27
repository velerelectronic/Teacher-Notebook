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
    property SqlTableModel relatedListsModel

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
            // Format is:
            // - First line: main category
            // - Second line: main element
            // - Third line: related category
            // - Fourth line: related element
            // - Fifth line: relationship
            // - Two newlines or more

            var re = /(.+)\n(.+)\n(.+)\n(.+)\n(.+)(?:\n\n+|$)/g;
            newRelatedListsModel.clear();
            var matches = re.exec(contents);
            while (matches !== null) {
                newRelatedListsModel.append({mainCategory: matches[1], mainElement: matches[2], relatedCategory: matches[3], relatedElement: matches[4], relationship: matches[5]});
                matches = re.exec(contents);
            }
        }
    }

    ListModel {
        id: newRelatedListsModel

        ListElement {
            mainCategory: ''
            mainElement: ''
            relatedCategory: ''
            relatedElement: ''
            relationship: ''
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
                    id: newRelatedListsList

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    model: newRelatedListsModel

                    headerPositioning: ListView.OverlayHeader
                    header: Rectangle {
                        z: 2
                        height: units.fingerUnit
                        width: newRelatedListsList.width

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit
                            Text {
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Categoria i element principals')
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Categoria i elements relacionats')
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Relació')
                            }
                        }
                    }

                    spacing: units.nailUnit

                    delegate: Rectangle {
                        z: 1
                        height: Math.max(units.fingerUnit * 2, mainItemText.contentHeight, relatedItemText.contentHeight, relationshipText.contentHeight) + 2 * units.nailUnit
                        width: newRelatedListsList.width

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit
                            Text {
                                id: mainItemText
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: '<p><b>' + model.mainCategory + '</b></p><p>' + model.mainElement + '</p>';
                            }
                            Text {
                                id: relatedItemText
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text:  '<p><b>' + model.relatedCategory + '</b></p><p>' + model.relatedElement + '</p>';
                            }
                            Text {
                                id: relationshipText
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.relationship
                            }
                        }
                    }
                }
                Button {
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.fillWidth: true
                    text: qsTr('Importa tot')
                    onClicked: {
                        console.log('there are', newRelatedListsModel.count);

                        for (var i=0; i< newRelatedListsModel.count; i++) {
                            var object = newRelatedListsModel.get(i);
                            var newObj = {
                                mainCategory: object['mainCategory'],
                                mainElement: object['mainElement'],
                                relatedCategory: object['relatedCategory'],
                                relatedElement: object['relatedElement'],
                                relationship: object['relationship']
                            };
                            console.log('nou obj', newObj);

                            relatedListsModel.insertObject(newObj);
                        }
                        relatedListsModel.select();
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

