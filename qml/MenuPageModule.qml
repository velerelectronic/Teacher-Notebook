import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import PersonalTypes 1.0
import QtGraphicalEffects 1.0
import QtQml.Models 2.2
import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic
import 'qrc:///models' as Models
import 'qrc:///modules/annotations2' as Annotations
import "qrc:///javascript/Storage.js" as Storage

Basic.BasicPage {
    id: menuPage
    property string pageTitle: qsTr('Teacher Notebook');

    signal annotationsListSelected()
    signal annotationsListSelected2()
    signal annotationSelected(string annotation)
    signal databaseManagerSelected()
    signal documentsListSelected()
    signal documentSelected(string document)
    signal reportSelected(string report)
    signal reportsListSelected()
    signal rubricsListSelected()
    signal rubricSelected(string rubric)

    signal sendOutputMessage(string message)

    function acceptNewChanges() {
        acceptPageChange = true;
        acceptPageChange = false;
    }

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill: parent
        Text {
            Layout.preferredHeight: contentHeight
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: units.glanceUnit
            font.bold: true
            text: 'Teacher Notebook'
        }

        Common.HorizontalStaticMenu {
            id: optionsMenu
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            spacing: units.nailUnit
            underlineColor: 'orange'
            underlineWidth: units.nailUnit

            sectionsModel: mainSectionsModel
            connectedList: partsList
        }

        ListView {
            id: partsList
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: partsList.enabled

            clip: true

            spacing: units.fingerUnit

            model: ObjectModel {
                id: mainSectionsModel

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Recents')

                    ColumnLayout {
                        width: parent.width
                        height: Math.max(recentDocumentsGrid.contentItem.height, units.fingerUnit * 2) + units.fingerUnit * 2
                        spacing: units.fingerUnit

                        ListView {
                            id: recentDocumentsGrid

                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            spacing: units.nailUnit
                            orientation: ListView.Horizontal

                            model: ListModel {
                                id: recentElements
                            }

                            delegate: Rectangle {
                                width: units.fingerUnit * 4
                                height: units.fingerUnit * 2

                                border.color: 'black'
                                Text {
                                    anchors.fill: parent
                                    anchors.margins: units.nailUnit
                                    text: model.title
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        documentSelected(model.document);
                                    }
                                }
                            }

                            Component.onCompleted: {
                                concurrentDocuments.select();
                                recentElements.clear();

                                for (var i=0; i<Math.min(concurrentDocuments.count, 9); i++) {
                                    var documentObject = concurrentDocuments.getObjectInRow(i);
                                    recentElements.append({title: documentObject['document'], document: documentObject['document']});
                                }
                            }
                        }

                        Button {
                            Layout.preferredHeight: units.fingerUnit
                            text: qsTr('Llista de documents')
                            onClicked: documentsListSelected()
                        }
                    }
                }

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Avui')

                    ColumnLayout {
                        width: parent.width
                        height: menuPage.height * 0.67

                        Annotations.AnnotationsList {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            filterPeriod: true
                        }
                        Button {
                            text: qsTr('Totes les anotacions')
                            onClicked: annotationsListSelected2()
                        }
                    }
                }

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Opcions')
                }

                Common.BasicSection {
                    width: partsList.width
                    padding: units.fingerUnit
                    captionSize: units.readUnit
                    caption: qsTr('Avançat')

                    Flow {
                        width: parent.width
                        height: childrenRect.height
                        spacing: units.fingerUnit

                        Button {
                            text: qsTr('Gestor de dades')
                            onClicked: databaseManagerSelected();
                        }
                        Button {
                            text: qsTr('Exportador')
                            //, page: 'ExportManager', parameters: {}});
                        }
                        Button {
                            text: qsTr('! Recerca de coneixement')
                            // page: 'Researcher', parameters: {}, submenu: {object: menuPage, method: ''}});
                        }
                        Button {
                            text: qsTr('Feeds')
                            //, page: 'FeedWEIB', parameters: {}});
                        }
                        Button {
                            text: qsTr('Rellotge')
                            //, page: 'TimeController', parameters: {}});
                        }
                        Button {
                            text: qsTr('Espai de treball')
                            //, page: 'WorkSpace', parameters: {}, submenu: {object: menuPage, method: ''}});
                        }
                        Button {
                            text: qsTr('Pissarra')
                            //, page: 'Whiteboard', parameters: {}, submenu: {object: menuPage, method: ''}});
                        }
                    }
                }
            }
        }
    }

    Models.ConcurrentDocuments {
        id: concurrentDocuments

        sort: 'lastAccessTime DESC'
    }

}
