/* Licenses:

  CC0
  * Image: http://pixabay.com/es/peque%C3%B1os-bellota-dibujos-animados-41255/

  Altres:
  * http://pixabay.com/es/bloc-de-notas-nota-l%C3%A1piz-117597/
  * http://pixabay.com/es/pila-papeles-de-pila-notas-cuadro-156015/
  * http://pixabay.com/es/port%C3%A1til-oficina-por-escrito-151261/

  * Add: http://pixabay.com/es/plus-signo-verde-mark-icono-24844/
  * Save: http://pixabay.com/es/disquete-icono-disco-s%C3%ADmbolo-bot%C3%B3n-35952/
  * Close: http://pixabay.com/es/se%C3%B1al-de-tr%C3%A1fico-roadsign-no-147409/
  * Duplicate: http://pixabay.com/es/clon-duplicado-flecha-documentos-153447/
  * Edit: http://pixabay.com/es/editar-l%C3%A1piz-la-escuela-escribir-153612/
  * Edit: http://pixabay.com/es/l%C3%A1piz-pluma-naranja-rojo-190586/
  * Details: http://pixabay.com/es/info-informaci%C3%B3n-ayuda-icono-apoyo-147927/
  * Back: http://pixabay.com/es/flecha-verde-brillante-izquierda-145769/
  * Export: http://pixabay.com/en/box-open-taking-out-container-24557/
  * Select: http://pixabay.com/en/screen-capture-screenshot-app-23236/

  * Today: http://pixabay.com/es/calendario-fechas-mes-hoy-en-d%C3%ADa-27560/
  * Quit: http://pixabay.com/es/eliminar-celular-cuadro-quitar-27201/

  * GanttDiagram: http://pixabay.com/es/por-ciento-40-bar-progreso-metro-40844/
  * Calendar: http://pixabay.com/es/calendario-mensual-oficina-23684/
  * Maximize: http://pixabay.com/es/windows-de-microsoft-maximizar-zoom-23242/
  * Minimize: http://pixabay.com/es/men%C3%BA-rojo-brillante-ventana-abajo-145772/
  * Multiple windows: http://pixabay.com/es/ventanas-equipo-escritorio-97883/

  * Categories: http://pixabay.com/es/jerarqu%C3%ADa-niveles-de-arreglos-35795/

  * Outline select: https://pixabay.com/es/contorno-frontera-mesa-digitales-27146/#_=_
  * Tick mark: https://pixabay.com/es/marca-de-verificaci%C3%B3n-comprobar-296754/
  * New empty annotation: https://pixabay.com/en/homework-paper-paperclip-paper-clip-152957/#_=_
  * New auto-filled annotation: https://pixabay.com/en/questionnaire-questions-paper-158862/
  * Upload: https://pixabay.com/en/upload-uploading-documents-files-25068/
  * Goto now: https://pixabay.com/en/day-calender-week-organizer-42975/
  * Next: https://pixabay.com/en/arrow-green-glossy-right-next-145766/

  * Magnifying glass: https://pixabay.com/photo-481818/
  * Config/settings/options: https://pixabay.com/photo-147414/
  * Open: https://pixabay.com/es/flecha-derecho-east-147175/

  Annotation states:
  * Inbox: https://pixabay.com/es/entrada-carga-archivo-documento-25064/
  * Pinned: https://pixabay.com/es/pasador-azul-oficina-aviso-23620/#
  * Postponed: https://pixabay.com/es/reloj-de-arena-temporizador-arena-23654/
  * Archive: https://pixabay.com/es/marca-de-verificaci%C3%B3n-caja-304890/
  * Deleted: https://pixabay.com/es/puede-papelera-de-basura-basura-294071/

  * Attached: https://pixabay.com/es/clip-de-papel-mantenga-metal-27821/
*/

import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import QtQuick.Dialogs 1.1
import PersonalTypes 1.0
import QtQml.StateMachine 1.0 as DSM
import 'qrc:///common' as Common

Window {
    id: mainApp

    x: 0
    y: 0

    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: true

    onClosing: {
        close.accepted = false;
        workingSpace.requestClosePage();
    }

    Common.UseUnits { id: units }

    BasicDatabase {
        id: basicDatabase

        Component.onCompleted: {
            basicDatabase.initEverything();
        }
    }


    Rectangle {
        color: '#F2F2F2'
        anchors.fill: parent

        WorkingSpace {
            id: workingSpace

            anchors.fill: parent
            anchors.margins: units.nailUnit * 2

            onOpenMenu: {
                slideMenu.initialHeight = initialHeight;
                slideMenu.options = options;
                slideMenu.menu = menu;
                slideMenu.state = 'showHeading';
            }

            onShowMessage: {
                messageBox.publishMessage(message);
            }

            Connections {
                target: workingSpace.item
                ignoreUnknownSignals: true

                onAnnotationsListSelected: {
                    appStateMachine.openAnnotationsList();
                }

                onAnnotationSelected: {
                    appStateMachine.annotation = annotation;
                    appStateMachine.openSingleAnnotation();
                }

                onDocumentsListSelected: {
                    if (typeof document !== 'undefined')
                        appStateMachine.document = document;
                    appStateMachine.openDocumentsList();
                }

                onDocumentSelected: {
                    appStateMachine.document = document;
                    appStateMachine.openSingleDocument();
                }

                onOpenMainPage: {
                    appStateMachine.openMainPage();
                }

                onRubricSelected: {
                    appStateMachine.assessment = assessment;
                    appStateMachine.openSingleRubric();
                }

                onRubricsListSelected: {
                    appStateMachine.openRubricsList();
                }
            }
        }

        Common.DownSlideMenu {
            id: slideMenu
            anchors.fill: parent
        }

        Common.MessageBox {
            id: messageBox
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: units.nailUnit

            color: 'yellow'
            border.color: 'black'
            radius: units.nailUnit
            internalMargins: units.nailUnit
            fontSize: units.readUnit
            interval: 2000
        }
    }

    DSM.StateMachine {
        id: appStateMachine

        initialState: mainMenuState

        // Shared variable across states

        property string annotation: ''
        property string document: ''
        property string rubric: ''
        property int assessment: -1

        // Signals

        signal openAnnotationsList()
        signal openDocumentsList()
        signal openMainPage()
        signal openRubricsList()
        signal openSingleAnnotation()
        signal openSingleDocument()
        signal openSingleRubric()

        DSM.State {
            id: mainMenuState

            onEntered: {
                workingSpace.loadSubPage('MenuPageModule', {});
            }

            DSM.SignalTransition {
                signal: appStateMachine.openDocumentsList
                targetState: documentsListState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openSingleDocument
                targetState: singleDocumentState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openAnnotationsList
                targetState: annotationsListState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openRubricsList
                targetState: rubricsListState
            }
        }

        DSM.State {
            id: documentsListState

            onEntered: {
                workingSpace.loadSubPage('DocumentsListModule', {documentId: appStateMachine.document});
            }

            DSM.SignalTransition {
                signal: appStateMachine.openMainPage
                targetState: mainMenuState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openSingleDocument
                targetState: singleDocumentState
            }
        }

        DSM.State {
            id: singleDocumentState

            onEntered: {
                workingSpace.loadSubPage('SingleDocumentModule', {documentId: appStateMachine.document});
            }

            DSM.SignalTransition {
                signal: appStateMachine.openDocumentsList
                targetState: documentsListState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openMainPage
                targetState: mainMenuState
            }
        }

        DSM.State {
            id: annotationsListState

            onEntered: {
                workingSpace.loadSubPage('AnnotationsListModule', {annotation: appStateMachine.annotation});
            }

            DSM.SignalTransition {
                signal: appStateMachine.openSingleAnnotation
                targetState: singleAnnotationState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openMainPage
                targetState: mainMenuState
            }
        }

        DSM.State {
            id: singleAnnotationState

            onEntered: {
                workingSpace.loadSubPage('SingleAnnotationModule', {annotation: appStateMachine.annotation});
            }

            DSM.SignalTransition {
                signal: appStateMachine.openAnnotationsList
                targetState: annotationsListState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openMainPage
                targetState: mainMenuState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openSingleRubric
                targetState: singleRubricState
            }
        }

        DSM.State {
            id: rubricsListState

            onEntered: {
                workingSpace.loadSubPage('RubricsListModule', {rubric: appStateMachine.rubric});
            }

            DSM.SignalTransition {
                signal: appStateMachine.openSingleRubric
                targetState: singleRubricState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openMainPage
                targetState: mainMenuState
            }
        }

        DSM.State {
            id: singleRubricState

            onEntered: {
                console.log('inside');
                workingSpace.loadSubPage('SingleRubricModule', {assessment: appStateMachine.assessment});
            }

            DSM.SignalTransition {
                signal: appStateMachine.openRubricsList
                targetState: rubricsListState
            }

            DSM.SignalTransition {
                signal: appStateMachine.openMainPage
                targetState: mainMenuState
            }
        }

    }

    Component.onCompleted: {
        appStateMachine.start();
    }
}

