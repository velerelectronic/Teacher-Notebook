import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import PersonalTypes 1.0

Rectangle {
    id: annotations
    property string pageTitle: qsTr('Anotacions');

    width: 300
    height: 200

    signal showAnnotation (int id,string annotation, string desc)
    signal deletedAnnotations (int num)

    signal importAnnotations(var fieldNames, var writeModel, var fieldConstants)
    signal exportAnnotations(var fieldNames, var writeModel, var fieldConstants)

    property bool canClose: true

    function newAnnotation() {
        annotations.showAnnotation(-1,(annotationsModel.searchString!='')?annotationsModel.searchString:qsTr('Sense títol'),'');
    }

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        ListView {
            id: annotationsList
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
                        onIntroPressed: {
                            console.log('INTRO')
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
                labels: (model.labels)?model.labels:''
                // state: (model.selected)?'selected':'basic'
                onAnnotationSelected: {
                    if (annotationsList.state == 'deleteList') {
                        annotationsModel.selectObject(model.index,!annotationsModel.isSelectedObject(model.index));
                    } else {
                        // State == 'hidden'
                        oneAnnotation.state = (oneAnnotation.state == 'basic')?'expanded':'basic';
                    }
                }
                onAnnotationLongSelected: annotations.showAnnotation(model.id,title,desc)
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
            Common.SuperposedButton {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                size: units.fingerUnit * 2
                imageSource: 'plus-24844'
                onClicked: newAnnotation()
                onPressAndHold: importAnnotations(['title','desc','image'],annotationsModel,[])
            }

            Common.SuperposedButton {
                anchors {
                    top: parent.top
                    right: parent.right
                }
                size: units.fingerUnit * 2
                imageSource: 'box-24557'
                onClicked: exportAnnotations(['title','desc','image'],annotationsModel,[])
            }
        }
    }

    Models.DetailedAnnotationsModel {
        id: annotationsModel
        Component.onCompleted: select()
    }

    Connections {
        target: globalAnnotationsModel
        onUpdated: annotationsModel.select()
    }
    Connections {
        target: globalScheduleModel
        onUpdated: annotationsModel.select()
    }
    Connections {
        target: globalResourcesAnnotationsModel
        onUpdated: annotationsModel.select()
    }
}
