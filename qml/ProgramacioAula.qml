import QtQuick 2.2
// import QtWebKit 3.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import FileIO 1.0
import PersonalTypes 1.0
import 'qrc:///editors' as Editors

Rectangle {
    id: xmlViewer
    property string pageTitle: qsTr('Programació d\'aula');
    property string document
    property bool becameVisible: false
    property alias buttons: buttonsModel

    signal documentSaved(string document)
    signal loadingDocument(string document)
    signal loadedDocument(string document)

    width: parent.width
    height: parent.height

    TeachingPlanning {
        id: xmlReader
    }

    VisualItemModel {
        id: buttonsModel
        Button {
            id: editButton
            text: qsTr('Edita')
            checkable: true
            checked: false
        }

        Button {
            id: saveButton
            text: qsTr('Desa canvis')
            onClicked: {
                if (xmlReader.save())
                    documentSaved(document);
            }
        }
    }

    VisualItemModel {
        // In the future, it will change into ObjectModel
        id: mainSectionsModel

        PlanningMainSection {
            id: basicData
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Dades generals')

            PlanningSubSection {
                width: basicData.width
                title: qsTr('Titol de la unitat')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.unitTitle
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: basicData.width
                title: qsTr('Projecte')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.project
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: basicData.width
                title: qsTr('Suport')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.support
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: basicData.width
                title: qsTr('Grup')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.group
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: basicData.width
                title: qsTr('Àrees')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.areas
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: basicData.width
                title: qsTr('Paraules clau')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.keywords
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: basicData.width
                title: qsTr('Temporització')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.timing
                    editable: editButton.checked
                }
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
            id: competences
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Competències bàsiques')
            PlanningSubSection {
                width: competences.width
                title: qsTr('Comunicació lingüística i audiovisual')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceLing
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: competences.width
                title: qsTr('Matemàtica')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceMat
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: competences.width
                title: qsTr('Tractament de la informació i competència digital')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceTic
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: competences.width
                title: qsTr('Social i ciutadana')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceSoc
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: competences.width
                title: qsTr('Cultural i artística')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceCult
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: competences.width
                title: qsTr('Aprendre a aprendre')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceLearn
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: competences.width
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
            id: assessment
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Avaluació')
            PlanningSubSection {
                width: assessment.width
                title: qsTr('Tasques')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.assessmentTasks
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: assessment.width
                title: qsTr('Criteris')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.assessmentCriteria
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: assessment.width
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
            id: contents
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Continguts')
            PlanningSubSection {
                width: contents.width
                title: qsTr('Coneixements')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsKnowledge
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: contents.width
                title: qsTr('Habilitats')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsHabilities
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: contents.width
                title: qsTr('Llenguatge')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsLanguage
                    editable: editButton.checked
                }
            }
            PlanningSubSection {
                width: contents.width
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
        anchors.fill: parent
        anchors.margins: units.nailUnit
        model: mainSectionsModel
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        snapMode: ListView.SnapToItem
        clip: true
    }

    Component.onCompleted: {
        loadingDocument(document);
        xmlReader.source = document;
        xmlReader.loadXml();
        loadedDocument(document);
    }
}
