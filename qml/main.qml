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
  * Rubrics: https://pixabay.com/es/lista-de-comprobaci%C3%B3n-de-verificaci%C3%B3n-154274/#

  * Trash: https://pixabay.com/es/de-basura-icono-basura-papelera-1295900/#
  * Unkwown: https://pixabay.com/es/signo-de-interrogaci%C3%B3n-pregunta-40876/
  * Empty document: https://pixabay.com/es/cuadro-caja-de-cart%C3%B3n-cart%C3%B3n-147574/

  * Move up: https://pixabay.com/es/hasta-hacia-arriba-flecha-verde-97614/
  * Move down: https://pixabay.com/es/descargar-abajo-flecha-en-virtud-de-97606/

  * Colour: https://pixabay.com/es/paleta-pinta-colores-de-madera-23406/
  * Pencil type: https://pixabay.com/es/pincel-l%C3%A1piz-artes-artista-153754/
  * Pencil tool: https://pixabay.com/es/pluma-l%C3%A1piz-color-brown-dibujar-147569/
  * Dot width: https://pixabay.com/es/lavado-signo-secador-cuadrados-36666/
  * Move tool: https://pixabay.com/es/flechas-direcciones-hasta-abajo-145992/
  * Zoom tool: https://pixabay.com/es/zoom-enfoque-desplazamiento-acci%C3%B3n-27958/

  * Increase number of rows: https://pixabay.com/es/fila-icono-s%C3%ADmbolo-27461/
  * Increase number of columns: https://pixabay.com/es/columna-icono-s%C3%ADmbolo-gris-equipo-27460/

  * More options: https://pixabay.com/es/comentario-texto-cuadro-gris-negro-27179/
*/

import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import QtQuick.Dialogs 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/pagesfolder' as PagesFolder
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/calendar' as Calendar
import "qrc:///common/FormatDates.js" as FormatDates

// Three types of navigation between pages
// 1. Each page links to several pages (but not backwards)
// 2. Subpages inside a page. When the subpage is closed, the control is transfered to the parent page.
// 3. Sequential pages. A list of pages interlinked in a linear sequence.

Window {
    id: mainApp

    x: 0
    y: 0

    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    visible: true

    onClosing: {
        close.accepted = false;
        pagesFolder.closeCurrentPage()
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

        PagesFolder.PagesFolder {
            id: pagesFolder

            anchors.fill: parent

            onPublishMessage: informationMessage.publishMessage(message)
        }

        Basic.InformationMessages {
            id: informationMessage

            z: 200
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
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
}

