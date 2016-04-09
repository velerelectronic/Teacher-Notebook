import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common

Item {
    id: workingSpace

    property string mainPage: ''

    signal closeWorkingSpace()
    signal openMenu(int initialHeight, var menu, var options)
    signal showMessage(string message)

    Common.UseUnits { id: units }

    ListModel {
        id: pagesModel

        dynamicRoles: true
    }

    StackView {
        id: basicStack

        anchors.fill: parent

        Connections {
            target: basicStack.currentItem
            ignoreUnknownSignals: true

            // Close the current page
            onClosePage: {
                if (basicStack.depth>1)
                    basicStack.pop();
            }

            onOpenWorkingPage: {
                loadFirstPage(page,parameters);
            }

            onOpenMainPage: loadFirstPage(mainPage, {})

            // Slide menu
            onOpenMenu: {
                workingSpace.openMenu(initialHeight, menu, options);
            }

            // Page handling
            onOpenPage: loadSubPage(page,{})
            onOpenPageArgs: loadSubPage(page,args)

            onOpenExternalViewer: {}

            // Show messages
            onShowMessage: workingSpace.showMessage(message)

            // Search for annotations, resources, etc
            onSearch: loadSubPage('OmniboxSearch.qml', options)


            // Remove from this downwards

            // Annotations
            onCombineAnnotationsIntoTable: {
                console.log('Compte 2', annotationsModel.count);
                openNewPage('CombinedAnnotationsTable', {annotationsModel: annotationsModel});
            }

            onDeletedAnnotations: messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' anotacions'))
            onSavedAnnotation: {
                messageBox.publishMessage(qsTr('Anotació desada: títol «') + annotation + '», descripció «' + desc + '»');
                lastAnnotationsModel.select();
            }
            onDuplicatedAnnotation: {
                messageBox.publishMessage(qsTr("S'ha creat un duplicat"));
                lastAnnotationsModel.select();
            }

            onShowAnnotation: {
                openNewPage('ShowAnnotation',parameters);
            }
            onShowAnnotationsSearch: {
                openNewPage('AnnotationsList', parameters)
            }

            onOpenAnnotations: openSubPage('AnnotationsList',{annotationsModel: globalAnnotationsModel, projectsModel: globalProjectsModel})
            onOpenCamera: openNewPage('CameraShoot',{receiver: receiver})
            onImportAnnotations: openNewPage('ModelImporter',{fieldNames: fieldNames, writeModel: writeModel, fieldConstants: fieldConstants})
            onExportAnnotations: openNewPage('ModelImporter',{importData: false, fieldNames: fieldNames, writeModel: writeModel, fieldConstants: fieldConstants})

            // Document list
            onCreatedFile: messageBox.publishMessage('Creat el fitxer «' + file + '»')
            onNotCreatedFile: messageBox.publishMessage('El fitxer «' + file + '» ja existeix')
            onOpenDocument: openNewPage(page, {document: document})
            onOpenTBook: openNewPage('Planning2', {document: document})
            onOpeningDocumentExternally: messageBox.publishMessage(qsTr("Obrint el document «") + document + "»")

            // Events
            onShowEvents: openNewPage('TasksSystem', {project: project})
            onDeletedEvents: messageBox.publishMessage(qsTr("S'han esborrat ") + num + qsTr(' esdeveniments'))
            onShowEvent: openNewPage('ShowEvent', parameters)
            onNewEvent: openNewPage('ShowEvent', parameters)
            onSavedEvent: {
                messageBox.publishMessage(qsTr("S'ha desat l'esdeveniment"));
            }

            // Quick annotations
            onSavedQuickAnnotation: messageBox.publishMessage(qsTr("S'ha desat l'anotacio rapida «" + contents + "»"))

            // Teaching Planning
            onLoadingDocument: messageBox.publishMessage(qsTr('Carregant el document «' + document + '»'))
            onLoadedDocument: messageBox.publishMessage(qsTr("S'ha carregat el document «" + document + "»"))
            onDocumentSaved: messageBox.publishMessage(qsTr('Desat el document «') + document + '»')
            onDocumentDiscarded: {
                if (changes)
                    messageBox.publishMessage(qsTr("S'han descartat els canvis fets al document «") + document + '»');
                closeCurrentPage();
            }

            // Text viewer
            onSavedDocument: messageBox.publishMessage(qsTr('Desat el document «') + document + '»')

            // MarkDown viewer
            onOpenLink: openNewPage('MarkDownViewer', {document: link});

            // Backup
            onSavedBackupToDirectory: {
                var directory = document;
                messageBox.publishMessage(qsTr("S'ha desat una còpia de seguretat dins ") + directory);
            }
            onUnsavedBackup: messageBox.publishMessage(qsTr("No s'ha pogut desar la còpia de seguretat"))
            onBackupReadFromFile: messageBox.publishMessage(qsTr("S'ha introduït el fitxer ") + file + qsTr(" dins la base de dades"))
            onBackupNotReadFromFile: messageBox.publishMessage(qsTr("Error en intentar introduir el fitxer ") + file + qsTr(" dins la base de dades"))

            // Assessment Grid
            onOpenTabularEditor: openNewPage('AssessmentGeneralEditor',{})
            onOpenAssessmentList: openNewPage('AssessmentList', {})
            onExportedContents: messageBox.publishMessage("S'han exportat les dades i s'ha desat una copia al porta-retalls.")

            // Altres - revisar
            onOpenDocumentsList: openNewPage('DocumentsList',{},'')
            onSelectDocument: openNewPage('DocumentsList', {initialDirectory: source, selectDocument: true, documentReceiver: documentReceiver})
            onRefusedCloseEditorRequest: messageBox.publishMessage(qsTr("Encara hi ha canvis sense desar! Desa'ls o descarta'ls abans."))

            onEditRubricAssessmentByIndividual: openNewPage('ShowRubricGroupAssessmentByIndividual',{assessment: assessment,individual: individual})

            onSavedAssessmentDescriptor: {
                messageBox.publishMessage(qsTr("S'han desat les dades del descriptor"));
                closeCurrentPage();
            }

            onSavedGroupIndividual: {
                messageBox.publishMessage(qsTr("S'han desat els canvis a l'individu"));
                closeCurrentPage();
            }

            onSavedCriterium: closeCurrentPage()
            onSavedLevel: closeCurrentPage()
            onSavedRubricDetails: closeCurrentPage()
            onSavedDescriptor: closeCurrentPage()
            onSavedRubricAssessment: {
                messageBox.publishMessage(qsTr("S'ha desat l'avaluació de rúbrica"));
                closeCurrentPage();
            }

            // Projects
            onNewProject: openNewPage('ProjectEditor')
            onNewProjectRequest: openNewPage('ProjectEditor');
            onShowProject: openNewPage('ProjectEditor',{idProject: project})
            onSavedProjectDetails: {
                messageBox.publishMessage(qsTr("S'ha desat el projecte"));
                closeCurrentPage();
            }

            // Resources
            onNewResource: openNewPage('ShowResource')
            onNewResourceAttachment: openNewPage('ResourceAttachment',parameters);
            onCreateResource: openNewPage('ShowResource',{resourcesModel: model});
            onInsertedResourceAttachment: {
                messageBox.publishMessage(message);
                closeCurrentPage();
            }

            onShowResource: openNewPage('ShowResource',{idResource: idResource, resourcesModel: model});
            onUpdatedResourceAttachment: {
                messageBox.publishMessage(message);
                closeCurrentPage();
            }

            // Characteristics
            onShowCharacteristics: {
                openNewPage('CharacteristicsList',{project: project});
            }
            onShowEventCharacteristics: {
                openNewPage('EventCharacteristicsEditor',{event: event, characteristicsModel: characteristicsModel, writeModel: writeModel})
            }

            // Data import
            onImportData: openNewPage('ModelImporter',{fieldNames: fieldNames, fieldConstants: fieldConstants, writeModel: writeModel})

            // TimeTable
            onOpenTimeTable: openNewPage('ShowTimeTable', {identifier: annnotation})

        }
    }

    function loadFirstPage(page, param) {
        basicStack.clear();
        loadSubPage(page, param);
    }

    function loadSubPage(page, param) {
        console.log('opening', page, param);
        if (basicStack.depth>0)
            param['isSubPage'] = true;
        basicStack.push({item: Qt.resolvedUrl(page + ".qml"), properties: param});
    }

    function requestClosePage() {
        if (basicStack.depth>1)
            basicStack.pop();
    }

    function closeCurrentPage() {
        // Erase this function
    }

    Component.onCompleted: {
        loadFirstPage(mainPage, {});
    }
}

