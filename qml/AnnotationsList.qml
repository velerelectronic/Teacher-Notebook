import QtQuick 2.5
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

    property var buttons: buttonsModel

    ListModel {
        id: buttonsModel

        Component.onCompleted: {
            append({method: 'newAnnotation', image: 'plus-24844', title: qsTr('Introdueix una nova anotació')});
        }
    }

    function newAnnotation() {
        annotations.editAnnotation(-1,(searchAnnotations.text!='')?searchAnnotations.text:qsTr('Sense títol'),'');
    }

    /*
    VisualItemModel {
        id: buttonsModel
        Button {
            text: qsTr('Nova')
            onClicked: {
                annotations.editAnnotation(-1,(searchAnnotations.text!='')?searchAnnotations.text:qsTr('Sense títol'),'');
//                    editAnnotation.setSource('AnnotationEditor.qml',{title: (searchAnnotations.text!='')?searchAnnotations.text:qsTr('Sense títol'), desc: ''})
//                    editAnnotation.visible = true
            }
        }
    }
*/

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill: parent


        ListView {
            id: annotationsList
            anchors.margins: units.nailUnit
            Layout.fillWidth: true
            Layout.fillHeight: true

            states: [
                State {
                    name: 'simpleList'
                },
                State {
                    name: 'deleteList'
                }
            ]
            clip: true
            header: Item {
                z: 300
                width: annotationsList.width
                height: units.fingerUnit * 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Common.SearchBox {
                        id: searchAnnotations
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        onPerformSearch: {
                            annotationsModel.searchString = text;
                        }
                    }
                    Item {
                        Layout.preferredHeight: units.fingerUnit
                        Layout.preferredWidth: (annotationsList.state == 'deleteList')?(parent.width / 2):editButton.width
                        Button {
                            id: editButton
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                left: parent.left
                            }

                            text: 'Edita'
                            onClicked: {
                                annotationsList.state = 'deleteList';
                            }
                        }
                        Common.EditBox {
                            id: editBox
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }
                            height: maxHeight
                            visible: annotationsList.state == 'deleteList'
                            maxHeight: units.fingerUnit
                            onCancel: {
                                annotationsModel.deselectAllObjects();
                                annotationsList.state = 'simpleList';
                            }
                            onDeleteItems: deletedAnnotations(annotationsModel.removeSelectedObjects())
                        }
                    }

                }
            }
            headerPositioning: ListView.OverlayHeader

            delegate: AnnotationItem {
                id: oneAnnotation
                anchors.left: parent.left
                anchors.right: parent.right
                title: model.title
                desc: (model.desc)?model.desc:''
                image: (model.image)?model.image:''
                // state: (model.selected)?'selected':'basic'
                onAnnotationSelected: {
                    if (annotationsList.state == 'deleteList') {
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
