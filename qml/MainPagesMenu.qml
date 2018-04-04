import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Rectangle {
    signal openPage(string caption, string qmlPage, var properties)
    signal newAnnotation(string text)

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            Layout.preferredHeight: units.fingerUnit * 5
            Layout.fillWidth: true

            color: '#E1F5A9'

            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Common.ImageButton {
                    size: units.fingerUnit * 2
                    image: 'plus-24844'

                    onClicked: annotationTextEditor.state = 'editor'
                }

                Common.EditableText {
                    id: annotationTextEditor

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    onTextChanged: newAnnotation(text)
                }
            }
        }


        ListView {
            id: mainPagesList

            Layout.fillHeight: true
            Layout.fillWidth: true

            Common.UseUnits {
                id: units
            }

            model: ListModel {
                id: mainPagesModel
                dynamicRoles: true
            }

            spacing: units.nailUnit

            delegate: Rectangle {
                width: mainPagesList.width
                height: units.fingerUnit * 2

                Text {
                    anchors.fill: parent
                    padding: units.nailUnit
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit

                    text: model.caption
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: openPage(model.caption, model.qmlPage, model.properties)
                }
            }

            function addPage(caption, qmlPage, properties) {
                mainPagesModel.append({caption: caption, qmlPage: qmlPage, properties: properties});
            }

            Component.onCompleted: {
                addPage(qsTr('Anotacions'), 'simpleannotations/SimpleAnnotationsList', {});
                addPage(qsTr("Calendari d'anotacions"), 'simpleannotations/AnnotationsCalendar', {});
                addPage(qsTr('Sistema de fitxers'), 'files/FilesystemBrowser', {});
                addPage(qsTr("Targetes"), 'cards/CardsList', {});

                addPage(qsTr('Graelles'), 'multigrids/MultigridsList', {});
                addPage(qsTr('Rúbriques *'), '', {});
                addPage(qsTr('Galeria'), 'files/Gallery', {});
                addPage(qsTr('Eines *'), '', {});
                addPage(qsTr('Feeds *'), '', {});
                addPage(qsTr('Planificacions *'), '', {});

                // Proposal

                // Main bar with icons for pages/tasks as these:
                // * Annotations
                // * Rubrics
                // * Filesystem
                // * Tools
                // * Feeds
                // * Plannings
                // * Checklists?
                // * Workflow?
            }
        }
    }
}

