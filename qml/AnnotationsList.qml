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

    signal showAnnotation (var parameters)
    signal deletedAnnotations (int num)

    signal importAnnotations(var fieldNames, var writeModel, var fieldConstants)
    signal exportAnnotations(var fieldNames, var writeModel, var fieldConstants)
    signal openingDocumentExternally(string document)
    signal showEvent(var parameters)

    property bool canClose: true

    property string searchString: ''

    function newAnnotation() {
        annotations.showAnnotation({idAnnotation: -1});
    }

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        ListView {
            id: annotationsList
            Layout.fillWidth: true
            Layout.fillHeight: true

            bottomMargin: units.fingerUnit * 3
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

                        text: annotations.searchString
                        onPerformSearch: {
                            var textArray = text.split(/\s+/i);
                            // text.split(/[$|\b+][#\B+][^|\b+]/i);
                            console.log(textArray);
                            var descArray = [];
                            var labelsArray = [];
                            for (var i=0; i<textArray.length; i++) {
                                if (textArray[i].indexOf('#') === 0) {
                                    labelsArray.push(textArray[i].substr(1));
                                } else {
                                    descArray.push(textArray[i]);
                                }
                            }

                            annotationsModel.searchString = descArray.join(' ');

                            var filtersArray = [];
                            for (var i=0; i<labelsArray.length; i++) {
                                filtersArray.push("INSTR(UPPER(labels),UPPER('" + labelsArray[i] + "'))");
                            }

                            annotationsModel.filters = filtersArray.join();
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

            section.property: 'projectName'
            section.delegate: Common.BoxedText {
                color: 'green'
                width: annotationsList.width
                height: units.fingerUnit
                text: section
                fontSize: units.readUnit
                margins: units.nailUnit
                textColor: 'white'
            }

            delegate: AnnotationItem {
                id: oneAnnotation
                anchors.left: parent.left
                anchors.right: parent.right

                idAnnotation: model.id
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
                onAnnotationLongSelected: annotations.showAnnotation({idAnnotation: model.id})
                onOpeningDocumentExternally: openingDocumentExternally(document)
                onShowEvent: annotations.showEvent(parameters)
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
                id: addButton
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
                    bottom: parent.bottom
                    left: parent.left
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
