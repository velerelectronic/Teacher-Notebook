import QtQuick 2.2
import QtWebKit 3.0
import FileIO 1.0
import PersonalTypes 1.0
import 'qrc:///editors' as Editors

Rectangle {
    id: xmlViewer
    property string pageTitle: qsTr('Programació d\'aula');
    property string document

    width: parent.width
    height: parent.height

    /*
    XmlReader {
        id: xmlReader
        source: '/Users/jmpayeras/Desenvolupament/prova.xml'

        onObjectivesChanged: {
            console.log('Changed objectives ');
            for (var prop in objectives) {
                console.log('-> ' + prop + ' -- ' + JSON.stringify(objectives[prop]));
            }
        }
    }*/

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
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Introducció')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.introduction
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Objectius')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.objectives
                onUpdatedList: console.log('updated list...')
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
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Matemàtica')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceMat
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Tractament de la informació i competència digital')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceTic
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Social i ciutadana')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceSoc
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Cultural i artística')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceCult
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Aprendre a aprendre')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceLearn
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Autonomia i iniciativa personal')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.competenceAuto
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
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Criteris')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.assessmentCriteria
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Instruments')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.assessmentInstruments
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
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Habilitats')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsHabilities
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Llenguatge')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsLanguage
                }
            }
            PlanningSubSection {
                width: parent.width
                title: qsTr('Valors')
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.contentsValues
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
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Referències')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.references
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Comentaris')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.comments
            }
        }
        PlanningMainSection {
            width: sectionsList.width
            height: sectionsList.height
            title: qsTr('Sessions')
            Editors.XmlListEditor {
                anchors.fill: parent
                dataModel: xmlReader.activities
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
    }
}
