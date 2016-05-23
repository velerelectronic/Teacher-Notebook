import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.XmlListModel 2.0
import QtQml.Models 2.2
import 'qrc:///common' as Common
import RubricXml 1.0

Item {

    property string rubricFile: ''

    Common.UseUnits {
        id: units
    }

    RubricXml {
        id: rubricXml

        source: rubricFile
    }

    ColumnLayout {
        anchors.fill: parent

        Common.HorizontalStaticMenu {
            id: menuBar

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            underlineColor: 'orange'
            underlineWidth: units.nailUnit

            sectionsModel: rubricSectionsModel
            connectedList: rubricSectionsList
        }

        ListView {
            id: rubricSectionsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true
            model: rubricSectionsModel

            spacing: units.fingerUnit
        }

        ObjectModel {
            id: rubricSectionsModel

            Common.BasicSection {
                padding: units.fingerUnit
                caption: qsTr('Document')

                Text {
                    height: units.fingerUnit * 2
                    width: parent.width
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: rubricFile
                }
            }

            Common.BasicSection {
                padding: units.fingerUnit
                caption: qsTr('Criteris i descriptors')

                ListView {
                    id: criteriaList
                    width: parent.width
                    height: contentItem.height

                    interactive: false

                    model: rubricXml.criteria
                    spacing: units.nailUnit

                    delegate: Rectangle {
                        id: criteriumRowRect
                        width: criteriaList.width
                        height: childrenRect.height

                        property int criteriumIndex: model.index
                        property RubricDescriptorsModel descriptorsModel: model.descriptors

                        ColumnLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            Item {
                                Layout.preferredHeight: units.fingerUnit * 2
                                Layout.fillWidth: true

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: units.nailUnit
                                    spacing: units.nailUnit
                                    Text {
                                        id: descriptorTitle
                                        Layout.preferredWidth: criteriumRowRect.width / 4
                                        Layout.preferredHeight: units.fingerUnit
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.title
                                    }
                                    Text {
                                        Layout.preferredWidth: criteriumRowRect.width / 4
                                        Layout.preferredHeight: units.fingerUnit
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.description
                                    }
                                    Text {
                                        Layout.preferredWidth: criteriumRowRect.width / 4
                                        Layout.preferredHeight: units.fingerUnit
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.weight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: units.fingerUnit
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.order
                                    }
                                }
                            }
                            ListView {
                                id: descriptorsList
                                Layout.preferredHeight: contentItem.height
                                Layout.fillWidth: true

                                model: criteriumRowRect.descriptorsModel
                                interactive: false

                                delegate: Rectangle {
                                    border.color: 'black'
                                    width: descriptorsList.width
                                    height: units.fingerUnit * 2
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: units.nailUnit
                                        spacing: units.nailUnit
                                        Text {
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: units.fingerUnit * 2
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            font.pixelSize: units.readUnit
                                            elide: Text.ElideRight
                                            text: model.level
                                        }
                                        Text {
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width / 4
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            font.pixelSize: units.readUnit
                                            elide: Text.ElideRight
                                            text: '<p><b>' + model.title + '</b></p><p>' + model.description + '</p>'
                                        }
                                        Text {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            font.pixelSize: units.readUnit
                                            elide: Text.ElideRight
                                            text: model.definition
                                        }
                                        Text {
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: units.fingerUnit * 3
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            font.pixelSize: units.readUnit
                                            elide: Text.ElideRight
                                            text: model.score + " punts"
                                        }
                                    }
                                }
                            }
                        }


                    }
                }
            }

            Common.BasicSection {
                padding: units.fingerUnit
                caption: qsTr('Individus avaluables')

                ListView {
                    id: individualsList

                    width: parent.width
                    height: contentItem.height

                    interactive: false
                    model: rubricXml.individuals

                    delegate: Rectangle {
                        width: individualsList.width
                        height: units.fingerUnit * 2
                        border.color: 'black'
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            Text {
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.groupName
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.identifier
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.name
                            }
                        }
                    }
                }
            }

            Common.BasicSection {
                padding: units.fingerUnit
                caption: qsTr('Avaluacions')

                ListView {
                    id: assessmentList

                    width: parent.width
                    height: contentItem.height

                    interactive: false
                    model: rubricXml.assessment

                    delegate: Rectangle {
                        width: individualsList.width
                        height: units.fingerUnit * 2
                        border.color: 'black'
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            Text {
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.criterium
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.individual
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.level
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.comment
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.time
                            }
                        }
                    }
                }
            }
        }

    }

}
