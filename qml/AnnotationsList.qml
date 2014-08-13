import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import PersonalTypes 1.0

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
                onPerformSearch: {
                    console.log('Perform search');
                    annotationsModel.searchString = text;
                }
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
            onCancel: annotationsModel.deselectAllObjects()
            onDeleteItems: deletedAnnotations(annotationsModel.removeSelectedObjects())
        }

        ListView {
            id: annotationsList
            anchors.margins: units.nailUnit
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            delegate: AnnotationItem {
                id: oneAnnotation
                anchors.left: parent.left
                anchors.right: parent.right
                title: model.title
                desc: (model.desc)?model.desc:''
                image: (model.image)?model.image:''
                // state: (model.selected)?'selected':'basic'
                onAnnotationSelected: {
                    if (editBox.state == 'show') {
                        annotationsModel.selectObject(model.index,!annotationsModel.isSelectedObject(model.index));
                    } else {
                        // State == 'hidden'
                        oneAnnotation.state = (oneAnnotation.state == 'basic')?'expanded':'basic';
                    }
                }
                onAnnotationLongSelected: annotations.editAnnotation(model.id,title,desc)
            }
            model: annotationsModel

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
                        }

                        onCancelAnnotation: editAnnotation.parent.visible = false
                    }

                }
            }
        }
    }

    Component.onCompleted: {
        annotationsModel.searchFields = ['title','desc'];
    }
}
