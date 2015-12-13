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
*/

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import QtQuick.Dialogs 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Window {
    id: mainApp

    x: 0
    y: 0

    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: true


    property string currentPageTitle: ''

    onClosing: {
        close.accepted = false;
        pagesLoader.requestClosePage();
    }

    Common.UseUnits { id: units }

    Rectangle {
        color: '#F2F2F2'
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: header
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit * 1.5

                color: "#009900"
                visible: true
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit

                    Image {
                        Layout.preferredWidth: height
                        Layout.preferredHeight: parent.height

                        source: 'qrc:///images/small-41255_150.png'
                        fillMode: Image.PreserveAspectFit
                        MouseArea {
                            anchors.fill: parent
                            onClicked: sideBar.state = (sideBar.state === 'showPanel')?'hidePanel':'showPanel'
                        }
                    }

                    Text {
                        id: title
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height
                        color: "#ffffff"
                        text: pagesLoader.pageTitle
                        font.italic: false
                        font.bold: true
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Tahoma"
                    }

                    ListView {
                        id: buttonsList
                        Layout.fillHeight: true
                        Layout.preferredWidth: contentItem.width
                        spacing: units.nailUnit
                        interactive: false
                        orientation: ListView.Horizontal

                        delegate: Common.ImageButton {
                            width: size
                            height: width
                            size: units.fingerUnit
                            image: model.icon
                            onClicked: {
                                model.object[model.method]();
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true

                RowLayout {
                    id: rowLayout
                    property int margin: Math.min(parent.width / 50, units.fingerUnit * 2)
                    anchors {
                        fill: parent
                        leftMargin: rowLayout.margin
                        rightMargin: rowLayout.margin
                        topMargin: units.nailUnit
                        bottomMargin: units.nailUnit
                    }
                    spacing: margin

                    Rectangle {
                        id: sideBar
                        Layout.preferredWidth: width
                        Layout.fillHeight: true
                        z: 2

                        states: [
                            State {
                                name: 'showPanel'
                                PropertyChanges {
                                    target: sideBar
                                    visible: true
                                    width: Math.max(rowLayout.width / 4, units.fingerUnit * 5)
                                }
                            },
                            State {
                                name: 'hidePanel'
                                PropertyChanges {
                                    target: sideBar
                                    visible: false
                                    width: -rowLayout.margin
                                }
                            }
                        ]
                        state: 'showPanel'
                        color: 'transparent'

                        transitions: [
                            Transition {
                                from: 'hidePanel'
                                to: 'showPanel'
                                PropertyAnimation {
                                    property: 'width'
                                    duration: 250
                                }
                            },
                            Transition {
                                from: 'showPanel'
                                to: 'hidePanel'
                                SequentialAnimation {
                                    PropertyAnimation {
                                        property: 'width'
                                        duration: 250
                                    }
                                    PropertyAnimation {
                                        property: 'visible'
                                    }
                                }
                            }
                        ]

                        MenuPage {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            onOpenWorkingPage: {
                                pagesLoader.loadPage(page,parameters);
                                console.log('Open working page in menupage');
                                for (var prop in parameters) {
                                    console.log(prop, ",,,", parameters[prop]);
                                }
                            }
                        }
                    }
                    Loader {
                        id: pagesLoader
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        z: 1
                        property string pageTitle: ((item !== null) && (typeof item.item !== 'undefined'))?item.item.pageTitle:qsTr('Teacher Notebook')

                        Connections {
                            target: pagesLoader.item
                            onCloseWorkingSpace: {
                            }
                            onOpenMenu: {
                                console.log('OPEN menu');
                                console.log(menu);
                                slideMenu.initialHeight = initialHeight;
                                slideMenu.menu = menu;
                                slideMenu.state = 'showHeading';
                                slideMenu.options = options;
                            }
                            onButtonsModelChanged: {
                                buttonsList.model = pagesLoader.item.buttonsModel;
                            }
                        }

                        function loadPage(page, parameters) {
                            setSource(Qt.resolvedUrl('WorkingSpace.qml'),{initialPage: page, initialProperties: parameters});
                            buttonsList.model = item.buttonsModel;
                        }

                        function requestClosePage() {
                            if ((item !== null) && (typeof item.pageClosable !== 'function')) {
                                if (item.requestClosePage())
                                    return true;
                            }
                            return false;
                        }
                    }

                }
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


    BasicDatabase {
        id: basicDatabase
    }

    SqlTableModel {
        id: nextEventsModel
        tableName: globalScheduleModel.tableName
        limit: 3
        filters: ["ifnull(state,'') != 'done'"]
        Component.onCompleted: {
            setSort(1,Qt.DescendingOrder); // Order by last inclusion
            select();
        }
    }

    SqlTableModel {
        id: lastAnnotationsModel
        tableName: globalAnnotationsModel.tableName
        limit: 3
        Component.onCompleted: {
            setSort(0,Qt.DescendingOrder);
            select();
        }
    }

    SqlTableModel {
        id: auditModel
    }

    Models.ProjectsModel {
        id: globalProjectsModel

        Component.onCompleted: select()
    }

    function auditTable(tableName, fields) {
        console.log('Audit table ' + tableName);

        auditModel.tableName = tableName;
        auditModel.fieldNames = fields;
        auditModel.select();
        console.log('# rows: ' + auditModel.count);
        for (var i=0; i<auditModel.count; i++) {
            console.log('Row ' + (i+1));
            var obj = auditModel.getObjectInRow(i);
            for (var prop in obj) {
                console.log(i + " " + prop + " -> " + obj[prop]);
            }
        }
    }

    Component.onCompleted: {

        basicDatabase.initEverything();

        /*
        auditTable('rubrics_last_scores',[
                       'assessment',
                    'individual',
                    'name',
                    'surname',
                    '\"group\"',
                    'criteriumTitle',
                    'criteriumDesc',
                    'weight',
                    'descriptor',
                    'moment',
                    'comment',
                    'criterium',
                    'level',
                    'definition',
                    'lastScoreId',
                    'score']);
*/
        auditTable('rubrics_descriptors_scores',[
                       'assessment',
                       'rubric',
                       'individual',
                       'name',
                       'surname',
                       '\"group\"',

                       'criterium',
                       'criteriumTitle',
                       'criteriumDesc',
                       'weight',

                       'descriptor',
                       'moment',
                       'comment',

                       'level',
                       'definition',
                       'scoreId'
                   ]);
    }

}

