import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage

Rectangle {
    id: annotations
    property string pageTitle: qsTr('Anotacions');

    width: 300
    height: 200

    signal editAnnotation (int id,string annotation, string desc)
    signal deletedAnnotations (int num)
    property bool canClose: true

    Common.UseUnits { id: units }
    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.fillWidth: true
            Button {
                id: button
                Layout.preferredHeight: units.fingerUnit
                anchors.margins: units.nailUnit
                text: 'Nova'
                onClicked: {
                    annotations.editAnnotation(-1,(searchAnnotations.text!='')?searchAnnotations.text:qsTr('Sense títol'),'');
//                    editAnnotation.setSource('AnnotationEditor.qml',{title: (searchAnnotations.text!='')?searchAnnotations.text:qsTr('Sense títol'), desc: ''})
//                    editAnnotation.visible = true
                }
            }
            Common.SearchBox {
                id: searchAnnotations
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit
                anchors.margins: units.nailUnit
                onPerformSearch: Storage.listAnnotations(annotationsModel,0,text)
            }
            Button {
                id: editButton
                anchors.margins: units.nailUnit
                Layout.preferredHeight: units.fingerUnit
                text: 'Edita'
                onClicked: editBox.state = 'show'
            }
        }

        Common.EditBox {
            id: editBox
            maxHeight: units.fingerUnit
            Layout.preferredHeight: height
            Layout.fillWidth: true
            anchors.margins: units.nailUnit
            onCancel: annotationsList.unselectAll()
            onDeleteItems: annotationsList.deleteSelected()
        }

        ListView {
            id: annotationsList
            anchors.margins: units.nailUnit
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            delegate: AnnotationItem {
                anchors.left: parent.left
                anchors.right: parent.right
                title: model.title
                desc: model.desc
                image: (model.image)?model.image:''
                state: (model.selected)?'selected':'basic'
                onAnnotationSelected: {
                    if (editBox.state == 'show') {
                        annotationsModel.setProperty(model.index,'selected',!annotationsModel.get(model.index).selected);
                    } else {
                        annotations.editAnnotation(model.id,title,desc)
//                        editAnnotation.setSource('AnnotationEditor.qml',{title: title, desc: desc});
//                        editAnnotation.parent.visible = true
                    }
                }
            }
            model: ListModel { id: annotationsModel }

            Item {
                anchors.fill: parent
                visible: false
                Rectangle {
                    anchors.fill: parent
                    color: 'black'
                    opacity: 0.5
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log('Cancel')
                }
                Loader {
                    id: editAnnotation
                    anchors.fill: parent
                    anchors.margins: units.fingerUnit
                    Connections {
                        target: editAnnotation.item
                        onSaveAnnotation: {
                            editAnnotation.parent.visible = false;
                            Storage.listAnnotations(annotationsModel,0,'');
                        }

                        onCancelAnnotation: editAnnotation.parent.visible = false
                    }

                }
            }

            function unselectAll() {
                for (var i=0; i<annotationsModel.count; i++) {
                    annotationsModel.setProperty(i,'selected',false);
                }
            }
            function deleteSelected() {
                // Start deleting from the end of the model, because the index of further items change when deleting a previous item.
                var num = 0;
                for (var i=annotationsModel.count-1; i>=0; --i) {
                    if (annotationsModel.get(i).selected) {
                        Storage.removeAnnotation(annotationsModel.get(i).id);
                        annotationsModel.remove(i);
                        num++;
                    }
                }
                annotations.deletedAnnotations(num);
            }
        }
    }

    Component.onCompleted: {
        Storage.listAnnotations(annotationsModel,0,'');
    }
}
