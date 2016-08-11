import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import Qt.labs.folderlistmodel 2.1

import FileIO 1.0
import QtQuick.Dialogs 1.1
import PersonalTypes 1.0

import 'qrc:///editors' as Editors
import 'qrc:///common' as Common

Common.AbstractEditor {
    id: xmlViewer
    property string document

    Common.UseUnits { id: units }

    onDocumentChanged: {
        sessionsListModel.folder = document.substring(0,document.lastIndexOf('/'));
        console.log('DOC');
        console.log(document.substring(0,document.lastIndexOf('/')));
        console.log('folder ' + sessionsListModel.folder);
        console.log(document);
    }

    signal loadingDocument(string document)
    signal loadedDocument(string document)
    signal documentSaved(string document)
    signal documentDiscarded(string document,bool changes)

    // From iteminspector
    signal copyDataRequested

    property bool editMode: false

    width: parent.width
    height: parent.height

    color: 'white'

    TeachingPlanning {
        id: xmlReader
    }


    function toggleEditMode() {
        editMode = !editMode;
    }

    function saveChanges() {
        messageSave.open();
    }

    function duplicateItem() {
        messageCopy.open();
    }

    function discardChanges() {
        if (xmlViewer.changes)
            messageDiscard.open();
        else
            xmlViewer.documentDiscarded(document,xmlViewer.changes);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Common.HorizontalStaticMenu {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            underlineColor: 'orange'
            underlineWidth: units.nailUnit

            sectionsModel: mainSectionsModel
            connectedList: sectionsList
        }

        ListView {
            id: sectionsList
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: mainSectionsModel
            boundsBehavior: Flickable.StopAtBounds
            snapMode: ListView.SnapOneItem
            highlightMoveDuration: 500
            clip: true
        }


    }

    ObjectModel {
        // In the future, it will change into ObjectModel
        id: mainSectionsModel

        Common.BasicSection {
            caption: qsTr('Dades generals')
            padding: units.fingerUnit

            PlanningMainSection {
                id: basicData
                width: sectionsList.width
                height: sectionsList.height

                PlanningSubSection {
                    width: basicData.width
                    title: qsTr('Titol de la unitat')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.unitTitle
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: basicData.width
                    title: qsTr('Projecte')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.project
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: basicData.width
                    title: qsTr('Suport')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.support
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: basicData.width
                    title: qsTr('Grup')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.group
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: basicData.width
                    title: qsTr('Àrees')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.areas
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: basicData.width
                    title: qsTr('Paraules clau')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.keywords
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: basicData.width
                    title: qsTr('Temporització')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.timing
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
            }
        }

        Common.BasicSection {
            caption: qsTr('Introducció')

            PlanningMainSection {
                width: sectionsList.width
                height: sectionsList.height

                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.introduction
                    editable: editMode
                    onNewChanges: xmlViewer.setChanges(true)
                }
            }
        }

        Common.BasicSection {
            caption: qsTr('Objectius')
            padding: units.fingerUnit

            PlanningMainSection {
                width: sectionsList.width
                height: sectionsList.height

                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.objectives
                    editable: editMode
                    onNewChanges: xmlViewer.setChanges(true)
                }
            }
        }

        Common.BasicSection {
            caption: qsTr('Competències bàsiques')
            padding: units.fingerUnit

            PlanningMainSection {
                id: competences
                width: sectionsList.width
                height: sectionsList.height

                PlanningSubSection {
                    width: competences.width
                    title: qsTr('Comunicació lingüística i audiovisual')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.competenceLing
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: competences.width
                    title: qsTr('Matemàtica')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.competenceMat
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: competences.width
                    title: qsTr('Tractament de la informació i competència digital')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.competenceTic
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: competences.width
                    title: qsTr('Social i ciutadana')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.competenceSoc
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: competences.width
                    title: qsTr('Cultural i artística')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.competenceCult
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: competences.width
                    title: qsTr('Aprendre a aprendre')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.competenceLearn
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: competences.width
                    title: qsTr('Autonomia i iniciativa personal')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.competenceAuto
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
            }
        }

        Common.BasicSection {
            caption: qsTr('Avaluació')
            padding: units.fingerUnit

            PlanningMainSection {
                id: assessment
                width: sectionsList.width
                height: sectionsList.height

                PlanningSubSection {
                    width: assessment.width
                    title: qsTr('Tasques')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.assessmentTasks
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: assessment.width
                    title: qsTr('Criteris')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.assessmentCriteria
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: assessment.width
                    title: qsTr('Instruments')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.assessmentInstruments
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
            }
        }

        Common.BasicSection {
            caption: qsTr('Continguts')
            padding: units.fingerUnit

            PlanningMainSection {
                id: contents
                width: sectionsList.width
                height: sectionsList.height

                PlanningSubSection {
                    width: contents.width
                    title: qsTr('Coneixements')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.contentsKnowledge
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: contents.width
                    title: qsTr('Habilitats')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.contentsHabilities
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: contents.width
                    title: qsTr('Llenguatge')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.contentsLanguage
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
                PlanningSubSection {
                    width: contents.width
                    title: qsTr('Valors')
                    Editors.XmlListEditor {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        dataModel: xmlReader.contentsValues
                        editable: editMode
                        onNewChanges: xmlViewer.setChanges(true)
                    }
                }
            }
        }

        Common.BasicSection {
            caption: qsTr('Recursos')
            padding: units.fingerUnit

            PlanningMainSection {
                width: sectionsList.width
                height: sectionsList.height

                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.resources
                    editable: editMode
                    onNewChanges: xmlViewer.setChanges(true)
                }
            }
        }

        Common.BasicSection {
            caption: qsTr('Referències')
            padding: units.fingerUnit

            PlanningMainSection {
                width: sectionsList.width
                height: sectionsList.height

                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.references
                    editable: editMode
                    onNewChanges: xmlViewer.setChanges(true)
                }
            }
        }

        Common.BasicSection {
            caption: qsTr('Comentaris')
            padding: units.fingerUnit

            PlanningMainSection {
                width: sectionsList.width
                height: sectionsList.height

                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.comments
                    editable: editMode
                    onNewChanges: xmlViewer.setChanges(true)
                }
            }
        }

        Common.BasicSection {
            caption: qsTr('Sessions')
            padding: units.fingerUnit

            PlanningMainSection {
                width: sectionsList.width
                height: sectionsList.height

                ListView {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: contentItem.height

                    FolderListModel {
                        id: sessionsListModel
                        showDirs: true
                        showFiles: false
                        showDirsFirst: true
                        onCountChanged: {
                            console.log('FOLDERLISTMODEL ' + count);
                        }
                    }
                    model: sessionsListModel

                    interactive: false
                    delegate: Rectangle {
                        id: singleSession
                        width: sectionsList.width
                        height: sessionText.height + subsessionList.height + units.nailUnit * 2
                        border.color: 'black'

                        property string directory: ''
                        Text {
                            id: sessionText
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: units.nailUnit
                            height: contentHeight
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: units.readUnit
                            font.bold: true
                            text: model.fileName
                            Component.onCompleted: sessionActivitiesModel.folder = model.fileURL
                        }
                        GridView {
                            id: subsessionList
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: sessionText.bottom
                            height: contentItem.height
                            anchors.margins: units.nailUnit
                            interactive: false

                            property real minimumColumnSpace: units.fingerUnit * 6
                            property real numberOfColums: Math.round(width / minimumColumnSpace)
                            property real extraSpace: (width - numberOfColums * minimumColumnSpace) / numberOfColums

                            cellWidth: minimumColumnSpace + extraSpace
                            cellHeight: cellWidth

                            model: sessionActivitiesModel

                            FolderListModel {
                                id: sessionActivitiesModel
                                folder: singleSession.directory
                                showDirs: true
                                showFiles: true
                            }
                            delegate: Item {
                                id: activity
                                property string resourceFileURL: model.fileURL

                                height: subsessionList.cellHeight
                                width: subsessionList.cellWidth
                                Rectangle {
                                    border.color: 'black'
                                    anchors.fill: parent
                                    anchors.margins: units.nailUnit

                                    Text {
                                        anchors.fill: parent
                                        anchors.margins: units.nailUnit
                                        font.pixelSize: units.readUnit
                                        text: model.fileName
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            var current = subsessionList.currentIndex;
                                            subsessionList.currentIndex = model.index;
                                            if (current == model.index) {
                                                imageViewer.state = 'show';
                                                imageViewer.object = activity;
                                                imageViewer.source = model.fileURL;
    //                                            Qt.openUrlExternally(model.fileURL);
                                            }
                                        }

                                        onPressAndHold: {
                                            Qt.openUrlExternally(model.fileURL)
                                        }
                                    }
                                }
                                function gotoPrevious() {
                                    if (subsessionList.currentIndex>0) {
                                        subsessionList.currentIndex = subsessionList.currentIndex - 1;
                                        imageViewer.source = sessionActivitiesModel.get(subsessionList.currentIndex,'fileURL');
                                    }
                                }

                                function gotoNext() {
                                    if (subsessionList.currentIndex<sessionActivitiesModel.count-1) {
                                        subsessionList.currentIndex += 1;
                                        imageViewer.source = sessionActivitiesModel.get(subsessionList.currentIndex,'fileURL');
                                    }
                                }
                            }
                            highlight: Rectangle {
                                radius: units.nailUnit
                                color: 'yellow'
                            }
                        }
                    }
                }

    /*
                Editors.XmlListEditor {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    dataModel: xmlReader.activities
                    editable: editMode
                    onNewChanges: xmlViewer.setChanges(true)
                }
            */
            }

        }

    }

    Common.ImageViewer {
        id: imageViewer
        anchors.fill: parent
        states: [
            State {
                name: 'show'
                PropertyChanges {
                    target: imageViewer
                    visible: true
                }
            },
            State {
                name: 'hide'
                PropertyChanges {
                    target: imageViewer
                    visible: false
                }
            }
        ]
        state: 'hide'
        onCloseViewer: imageViewer.state = 'hide'

        property var object: undefined

        onGotoPrevious: {
            object.gotoPrevious();
        }

        onGotoNext: {
            object.gotoNext();
        }
    }

    MessageDialog {
        id: messageSave
        title: qsTr('Desar canvis');
        text: qsTr('Es desaran els canvis. Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            if (xmlReader.save()) {
                documentSaved(document);
                xmlViewer.setChanges(false);
            }
        }
    }
    MessageDialog {
        id: messageDiscard
        title: qsTr('Descartar canvis');
        text: qsTr('Es descartaran els canvis. N\'estàs segur?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: {
            var changes = xmlViewer.changes;
            xmlViewer.setChanges(false);
            xmlViewer.documentDiscarded(document,changes);
        }
    }
    MessageDialog {
        id: messageCopy
        title: qsTr('Duplicar');
        text: qsTr('Es duplicaran totes les dades a un nou element. Vols continuar?')
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: xmlViewer.copyDataRequested();
    }

    Component.onCompleted: {
        loadingDocument(document);
        xmlReader.source = document;
//        xmlReader.loadXml();
        loadedDocument(document);
    }
}
