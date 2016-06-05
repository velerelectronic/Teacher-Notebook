import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.2
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
    signal closeNewAnnotation()
    signal openAnnotation(string title)

    property string labels: ''

    Models.ExtendedAnnotations {
        id: annotationsModel
    }

    clip: true

    Common.SuperposedWidgetList {
        id: menuList
        anchors.fill: parent
        anchors.margins: units.nailUnit

        onCloseList: closeNewAnnotation()

        caption: qsTr('Nova anotació...')

        listItems: ObjectModel {
            id: menuModel

            Editors.TextAreaEditor3 {
                id: newAnnotationEditor
                width: menuList.width
                height: units.fingerUnit * 4
                border.color: 'black'
            }
            Item {
                width: menuList.width
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
                width: menuList.width
                height: units.fingerUnit

                RowLayout {
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
                        width: menuList.width
                        height: units.fingerUnit
                        title: qsTr('Cancela')
                        onClicked: closeNewAnnotation()
                    }
                }
            }

            Rectangle {
                width: menuList.width
                height: units.fingerUnit * 2
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
                width: menuList.width
                height: units.fingerUnit * 2
                border.color: 'black'
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: size
                        size: units.fingerUnit
                        image: 'upload-25068'
                        onClicked: importAnnotations()
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
            end: date
        }

        if (res != null) {
            newObj['title'] = res[1].trim();
            newObj['desc'] = res[2];
            if (annotationsModel.insertObject(newObj)) {
                closeNewAnnotation();
                openAnnotation(newObj['title']);
            }
        } else {
            newObj['title'] = newAnnotationEditor.content;
            newObj['desc'] = '';
            if (annotationsModel.insertObject(newObj)) {
                closeNewAnnotation();
                openAnnotation(newObj['title']);
            }
        }
    }


    function newIntelligentAnnotation() {

    }

    function newTimetableAnnotation() {
        menuList.model = timetableModel;
    }

    function importAnnotations() {
        importAnnotations(['title','desc','image'],annotationsModel,[]);
    }
}
