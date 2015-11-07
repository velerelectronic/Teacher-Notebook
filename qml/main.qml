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
        pagesView.requestClosePage();
    }

    Common.UseUnits { id: units }

    Rectangle {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: units.fingerUnit * 1.5

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
                    onClicked: sidePanel.state = (sidePanel.state === 'showPanel')?'hidePanel':'showPanel'
                }
            }

            Text {
                id: title
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height
                color: "#ffffff"
                text: pagesView.pageTitle
                font.italic: false
                font.bold: true
                font.pixelSize: units.readUnit
                verticalAlignment: Text.AlignVCenter
                font.family: "Tahoma"
            }

            ListView {
                id: pagesIcons

                Layout.fillHeight: true
                Layout.preferredWidth: contentItem.width
                Layout.maximumWidth: parent.width / 2

                clip: true

                highlightRangeMode: ListView.ApplyRange
                model: workingPagesModel
                orientation: ListView.Horizontal
                spacing: units.nailUnit

                delegate: Rectangle {
                    width: units.fingerUnit
                    height: units.fingerUnit
                    Text {
                        anchors.fill: parent
                        text: model.index
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: pagesView.currentIndex = model.index
                    }
                }
            }
        }
    }

    ListModel {
        id: workingPagesModel
    }

    ListView {
        id: pagesView
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        property string pageTitle: ((workingPagesModel.count>0) && (currentItem !== null) && (typeof currentItem.item !== 'undefined'))?currentItem.item.pageTitle:qsTr('Teacher Notebook')

        highlightMoveDuration: 250

        orientation: ListView.Horizontal
        interactive: false

        model: workingPagesModel

        delegate: Loader {
            width: pagesView.width
            height: pagesView.height

            Component.onCompleted: {
                setSource(Qt.resolvedUrl('WorkingSpace.qml'),{initialPage: model.page, initialProperties: model.parameters});
            }

            Connections {
                target: item
                onCloseWorkingSpace: {
                    workingPagesModel.remove(model.index);
                }
                onOpenMenu: {
                    console.log('OPEN menu');
                    console.log(menu);
                    slideMenu.initialHeight = initialHeight;
                    slideMenu.menu = menu;
                    slideMenu.state = 'showHeading';
                    slideMenu.options = options;
                }
            }
        }

        function requestClosePage() {
            if ((currentItem !== null) && (currentItem.item !== null))
                currentItem.item.requestClosePage();
        }
    }

    Common.SidePanel2 {
        id: sidePanel

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        panelWidth: parent.width * 2 / 3
        panelHeight: height
        handleSize: units.fingerUnit

        mainItem: MenuPage {
            onOpenWorkingPage: {
                sidePanel.state = 'hidePanel';
                workingPagesModel.append({page: page, parameters: parameters});
                pagesView.currentIndex = workingPagesModel.count-1;
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

