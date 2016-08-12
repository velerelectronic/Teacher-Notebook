import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Rectangle {
    id: newAnnotationItem

    Common.UseUnits {
        id: units
    }

    signal showMessage(string message)
    signal newTimetableAnnotationSelected(string labels)
    signal close()
    signal discarded()
    signal openAnnotation(string title)

    property string labels: ''
    property string document: ''

    property SqlTableModel annotationsModel

    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        Editors.TextAreaEditor3 {
            id: newAnnotationEditor
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: 'black'
        }
        Item {
            Layout.fillWidth: true
            height: childrenRect.height

            Flow {
                id: flow
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                height: flow.childrenRect.height
                spacing: units.nailUnit

                Text {
                    text: qsTr('Etiquetes')
                }

                Repeater {
                    id: flowRepeater

                    model: newAnnotationItem.labels.split(' ')

                    delegate: Rectangle {
                        width: childrenRect.width + units.nailUnit
                        height: units.fingerUnit
                        color: '#AAFFAA'
                        Text {
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                left: parent.left
                                margins: units.nailUnit
                            }
                            width: contentWidth
                            verticalAlignment: Text.AlignVCenter

                            text: modelData
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            RowLayout {
                id: buttonsLayout

                anchors.fill: parent
                spacing: units.nailUnit
                Common.BigButton {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    title: qsTr('Desa')
                    onClicked: saveNewAnnotation()
                }
                Common.BigButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 4
                    height: units.fingerUnit
                    title: qsTr('Cancela')
                    onClicked: discarded()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            border.color: 'black'
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: units.fingerUnit
                    image: 'calendar-23684'
                    onClicked: newTimetableAnnotationSelected(labels)
                }
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("A partir d'horari")
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 2

            border.color: 'black'
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: size
                    size: units.fingerUnit
                    image: 'upload-25068'
                    onClicked: {
                        close();
                        importDialog.openImportAnnotationsDialog();
                    }
                }
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("Importa...")
                }
            }
        }

    }

    function saveNewAnnotation() {
        console.log('save new annotation');
        var re = new RegExp("^(.+)\n+((?:.|\n|\r)*)$","g");
        console.log(newAnnotationEditor.content);
        var res = re.exec(newAnnotationEditor.content);
        var date = (new Date()).toYYYYMMDDHHMMFormat();
        var newObj = {
            labels: flowRepeater.model.join(' ').trim(),
            start: date,
            end: date,
            document: newAnnotationItem.document
        }

        if (res != null) {
            newObj['title'] = res[1].trim();
            newObj['desc'] = res[2];
        } else {
            newObj['title'] = newAnnotationEditor.content;
            newObj['desc'] = '';
        }
        if (annotationsModel.insertObject(newObj)) {
            annotationsModel.select();
            close();
        }
    }


    function newIntelligentAnnotation() {

    }

    function newTimetableAnnotation() {
        menuList.model = timetableModel;
    }

    Common.SuperposedWidget {
        id: importDialog

        function openImportAnnotationsDialog() {
            load(qsTr('Importa anotacions antigues'), 'annotations/RelatedAnnotations', {autoImport: true, document: newAnnotationItem.document});
        }

        Connections {
            target: importDialog.mainItem

            onAnnotationImported: {
                annotationsModel.select();
            }
        }
    }
}
