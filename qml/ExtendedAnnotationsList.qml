import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage

Rectangle {
    id: annotations
    property string pageTitle: qsTr('Anotacions (esteses)');

    property bool isVertical: width<height

    signal showExtendedAnnotation (var parameters)

    signal openMenu(int initialHeight, var menu)
    /*
    signal deletedAnnotations (int num)

    signal importAnnotations(var fieldNames, var writeModel, var fieldConstants)
    signal exportAnnotations(var fieldNames, var writeModel, var fieldConstants)
    signal openingDocumentExternally(string document)
    signal showEvent(var parameters)
*/

//    property bool canClose: true

    property string searchString: ''

    function newAnnotation() {
        annotations.showExtendedAnnotation({title: annotationsModel.searchString.replace('#',' ')});
    }


    Common.UseUnits { id: units }

    GridLayout {
        id: mainGrid

        anchors.fill: parent

        states: [
            State {
                name: 'simple'

                PropertyChanges {
                    target: mainGrid
                    rows: 1
                    columns: 1
                }

                PropertyChanges {
                    target: selectedAnnotationsList
                    width: 0
                    height: 0
                }
            },
            State {
                name: 'split'

                PropertyChanges {
                    target: mainGrid
                    rows: (isVertical)?2:1
                    columns: 3-rows
                }

                PropertyChanges {
                    target: selectedAnnotationsList
                    width: (!isVertical)?(mainGrid.width/2):mainGrid.width
                    height: (isVertical)?(mainGrid.height/2):mainGrid.height
                }
            }
        ]
        state: (selectedAnnotationsModel.count==0)?'simple':'split'

        ListView {
            id: annotationsList
            Layout.fillWidth: true
            Layout.fillHeight: true

            bottomMargin: units.fingerUnit * 3
            clip: true

            header: Item {
                z: 300
                width: annotationsList.width
                height: units.fingerUnit * 1.5

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

                            selectedAnnotationsModel.clear();

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

                    Common.ImageButton {
                        image: 'floppy-35952'
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        onClicked: {
                            if (searchAnnotations.text !== '') {
                                var t = searchAnnotations.text;
                                searchesModel.insertObject({title: t, terms: t, created: Storage.currentTime()});
                            }
                        }
                    }
                }
            }
            headerPositioning: ListView.OverlayHeader

            section.property: 'project'

            section.delegate: Common.BoxedText {
                color: 'green'
                width: annotationsList.width
                height: units.fingerUnit
                text: section
                fontSize: units.readUnit
                margins: units.nailUnit
                textColor: 'white'
            }

            delegate: Rectangle {
                id: annotationItem
                width: annotationsList.width
                height: units.fingerUnit * 2
                border.color: 'black'
                states: [
                    State {
                        name: 'unselected'
                        PropertyChanges {
                            target: annotationItem
                            color: 'white'
                        }
                    },
                    State {
                        name: 'selected'
                        PropertyChanges {
                            target: annotationItem
                            color: 'yellow'
                        }
                    }
                ]
                state: 'unselected'
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.title
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        color: 'red'
                        text: model.start + "\n" + model.end
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: 'green'
                        text: model.labels
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        text: model.state
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (annotationItem.state === 'unselected') {
                            annotationItem.state = 'selected';
                            selectedAnnotationsModel.append({title: model.title, fake: model.index});
                            console.log('Appended',model.title);
                        } else {
                            annotationItem.state = 'unselected';
                            for (var i=0; i<selectedAnnotationsModel.count; i++) {
                                if (selectedAnnotationsModel.get(i)['title'] == model.title) {
                                    selectedAnnotationsModel.remove(i);
                                }
                            }
                        }
                    }
                }
            }

            model: annotationsModel

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

        ListView {
            id: selectedAnnotationsList

            Layout.preferredWidth: width
            Layout.preferredHeight: height

            clip: true
            orientation: ListView.Horizontal

            snapMode: ListView.SnapOneItem

            Behavior on width {
                NumberAnimation { duration: 200 }
            }

            Behavior on height {
                NumberAnimation { duration: 200 }
            }

            model: selectedAnnotationsModel

            delegate: Item {
                property string thisTitle: model.title

                width: selectedAnnotationsList.width
                height: selectedAnnotationsList.height

                Common.BoxedText {
                    id: numberBar
                    color: 'green'
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: units.fingerUnit

                    margins: units.nailUnit
                    textColor: 'white'
                    text: (model.index+1).toString() + qsTr(' de ') + selectedAnnotationsModel.count
                }

                ShowExtendedAnnotation {
                    anchors {
                        top: numberBar.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    title: parent.thisTitle

                    onOpenMenu: annotations.openMenu(initialHeight,menu)
                }
            }
        }
    }

    ListModel {
        id: selectedAnnotationsModel
    }

    Models.ExtendedAnnotations {
        id: annotationsModel

        searchFields: ['title', 'desc', 'project']
        Component.onCompleted: {
            setSort(1, Qt.DescendingOrder);
            select();
        }
    }

    Models.SavedAnnotationsSearchesModel {
        id: searchesModel
        Component.onCompleted: select()
    }
}
