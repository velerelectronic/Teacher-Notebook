import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'common' as Common
import "Storage.js" as Storage

Rectangle {
    id: annotations
    property string title: qsTr('Anotacions');
    property int esquirolGraphicalUnit: 100

    width: 300
    height: 200

    signal editAnnotation (string title, string desc)

    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Button {
                id: button
                Layout.fillHeight: true
                text: 'Nova'
                onClicked: {
                    editAnnotation.setSource('AnnotationEditor.qml',{title: (searchAnnotations.text!='')?searchAnnotations.text:qsTr('Sense títol'), desc: ''})
                    editAnnotation.visible = true
                }
            }
            Common.SearchBox {
                id: searchAnnotations
                Layout.fillWidth: true
                anchors.margins: 10
                onPerformSearch: Storage.listAnnotations(annotationsModel,0,text)
            }
            Button {
                id: editButton
                Layout.fillHeight: true
                text: 'Edita'
                onClicked: editBox.state = 'show'
            }
        }

        Common.EditBox {
            id: editBox
            Layout.preferredHeight: height
            Layout.fillWidth: true
            onCancel: annotationsList.unselectAll()
            onDeleteItems: annotationsList.deleteSelected()
        }

        ListView {
            id: annotationsList
            anchors.margins: 10
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            delegate: AnnotationItem {
                anchors.left: parent.left
                anchors.right: parent.right
                title: model.title
                desc: model.desc
                state: (model.selected)?'selected':'basic'
                onAnnotationSelected: {
                    console.log(model.selected)
                    if (editBox.state == 'show') {
                        annotationsModel.setProperty(model.index,'selected',!annotationsModel.get(model.index).selected);
                    } else {
                        editAnnotation.setSource('AnnotationEditor.qml',{title: title, desc: desc});
                        editAnnotation.visible = true
                    }
                }
            }
            model: ListModel { id: annotationsModel }

            Loader {
                id: editAnnotation
                anchors.fill: parent
                anchors.margins: 20
                visible: false
                Connections {
                    target: editAnnotation.item
                    onSaveAnnotation: {
                        Storage.saveAnnotation(title,desc);
                        editAnnotation.visible = false;
                        Storage.listAnnotations(annotationsModel,0,'');
                    }

                    onCancelAnnotation: editAnnotation.visible = false
                }
            }
            function unselectAll() {
                for (var i=0; i<annotationsModel.count; i++) {
                    annotationsModel.setProperty(i,'state','basic');
                }
            }
            function deleteSelected() {
                // Start deleting from the end of the model, because the index of further items change when deleting a previous item.
                for (var i=annotationsModel.count-1; i>=0; --i) {
                    if (annotationsModel.get(i).selected) {
                        Storage.removeAnnotation(annotationsModel.get(i).id);
                        annotationsModel.remove(i);
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        Storage.listAnnotations(annotationsModel,0,'');
    }
}
