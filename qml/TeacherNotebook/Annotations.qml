import QtQuick 2.0
import QtQuick.Controls 1.1
import "Storage.js" as Storage

Rectangle {
    id: annotations
    width: 300
    height: 200

    signal editAnnotation (string title, string desc)

    SearchBox {
        id: searchAnnotations
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        onPerformSearch: Storage.listAnnotations(annotationsModel,0,text)
    }

    ListView {
        id: annotationsList
        anchors {
            top: searchAnnotations.bottom
            bottom: button.top
            left: parent.left
            right: parent.right
            margins: 10
        }
        clip: true
        delegate: AnnotationItem {
            anchors.left: parent.left
            anchors.right: parent.right
            height: childrenRect.height + 10
            title: model.title
            desc: model.desc
            onAnnotationSelected: {
                editAnnotation.setSource('AnnotationEditor.qml',{title: title, desc: desc});
                editAnnotation.visible = true

                console.log(title + desc)
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
    }
    Button {
        id: button
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: 'Nova'
        onClicked: {
            editAnnotation.setSource('AnnotationEditor.qml',{title: qsTr('Sense títol'), desc: ''})
            editAnnotation.visible = true
        }
    }

    Component.onCompleted: {
        Storage.listAnnotations(annotationsModel,0,'');
    }
}
