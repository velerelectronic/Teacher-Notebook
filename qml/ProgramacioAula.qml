import QtQuick 2.2
import QtWebKit 3.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import FileIO 1.0
import PersonalTypes 1.0
import 'qrc:///editors' as Editors

Rectangle {
    id: xmlViewer
    property string pageTitle: qsTr('Programació d\'aula');
    property string document

    width: parent.width
    height: parent.height

    TeachingPlanning {
        id: xmlReader
        source: document
        // source: '/Users/jmpayeras/Desenvolupament/prova.xml'

        Component.onCompleted: {
            console.log(document);
            xmlReader.loadXml();
        }

        onObjectivesChanged: console.log(xmlReader.objectives)
    }

    VisualItemModel {
        // In the future, it will change into ObjectModel
        id: mainSectionsModel

        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Dades generals')
            Editors.XmlListEditor {
                width: parent.width
                dataModel: xmlReader.basicData
                editable: editButton.checked
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Introducció')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.introduction
                editable: editButton.checked
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Objectius')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.objectives
                editable: editButton.checked
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Competències bàsiques')
            PlanningSubSection {
                width: parent.width
                title: qsTr('Comunicació lingüística i audiovisual')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceLing
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Matemàtica')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceMat
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Tractament de la informació i competència digital')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceTic
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Social i ciutadana')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceSoc
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Cultural i artística')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceCult
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Aprendre a aprendre')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceLearn
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Autonomia i iniciativa personal')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceAuto
                    editable: editButton.checked
                }
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Avaluació')
            PlanningSubSection {
                width: parent.width
                title: qsTr('Tasques')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.assessmentTasks
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Criteris')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.assessmentCriteria
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Instruments')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.assessmentInstruments
                    editable: editButton.checked
                }
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Continguts')
            PlanningSubSection {
                width: parent.width
                title: qsTr('Coneixements')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsKnowledge
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Habilitats')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsHabilities
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Llenguatge')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsLanguage
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Valors')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsValues
                    editable: editButton.checked
                }
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Recursos')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.resources
                editable: editButton.checked
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Referències')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.references
                editable: editButton.checked
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Comentaris')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.comments
                editable: editButton.checked
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Sessions')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.activities
                editable: editButton.checked
            }
        }
    }

    ListView {
        id: sectionsList
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: buttons.top
        anchors.margins: units.nailUnit
        model: mainSectionsModel
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapToItem
        clip: true
    }
    RowLayout {
        id: buttons
        anchors.margins: units.nailUnit
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: units.fingerUnit * 2
        Button {
            id: editButton
            Layout.fillHeight: true
            text: qsTr('Edita')
            checkable: true
            checked: false
        }

        Button {
            id: saveButton
            Layout.fillHeight: true
            text: qsTr('Desa canvis')
            onClicked: xmlReader.save()
        }
        Item {
            Layout.fillWidth: true
        }
    }
}
