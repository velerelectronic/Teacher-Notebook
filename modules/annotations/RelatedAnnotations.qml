import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Item {
    id: relatedAnnotations

    property int requiredHeight
    property string labelBase: ''
    property string labels

    property string mainIdentifier: ''
    property string initialState: ''
    property string stateFilter: inboxState
    property string inboxState: "state = 0 OR state = 1 OR state IS NULL" // inbox + pinnedState
    property string pinnedState: "state = 1"
    property string postponedState: "state = 2"
    property string archivedState: "state = 3"
    property string trashedState: "state < 0"
    property string anyState: "1=1"

    property bool autoImport: false
    property string document: ''

    signal annotationSelected(string title)
    signal annotationImported(string title)
    signal newAnnotation()

    Common.UseUnits {
        id: units
    }

    Component.onCompleted: {
//        refreshAnnotationsList();

        getMainIndex();
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.preferredHeight: units.fingerUnit * 1
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth
                    font.pixelSize: units.readUnit
                    text: qsTr('Etiquetes:')
                }
                Flow {
                    id: labelsGrid
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    spacing: units.nailUnit

                    Repeater {
                        Component.onCompleted: {
                            var newLabels = relatedAnnotations.labels.trim();
                            if (newLabels == '') {
                                model = [];
                            } else {
                                model = newLabels.split(/\s+/g);
                            }
                            refreshAnnotationsList();
                        }

                        delegate: Rectangle {
                            id: labelRect
                            objectName: 'labelItem'
                            width: labelText.width + units.fingerUnit
                            height: labelsGrid.height
                            radius: height / 2
                            color: (selected)?'#AAFFAA':'#AAAAAA'
                            property bool selected: true
                            property string labelText: modelData

                            Text {
                                id: labelText
                                anchors {
                                    top: parent.top
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                }
                                width: contentWidth
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: units.readUnit
                                text: modelData
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    labelRect.selected = !labelRect.selected;
                                    refreshAnnotationsList();
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: units.fingerUnit * 1.5
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth
                    font.pixelSize: units.readUnit
                    text: qsTr('Estats:')
                }
                ListView {
                    id: statesList
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: units.fingerUnit
                    orientation: ListView.Horizontal

                    model: ListModel {
                        id: statesModel

                        Component.onCompleted: {
                            append({image: 'input-25064', stateValue: inboxState});
                            append({image: 'pin-23620', stateValue: pinnedState});
                            append({image: 'hourglass-23654', stateValue: postponedState});
                            append({image: 'check-mark-304890', stateValue: archivedState});
                            append({image: 'can-294071', stateValue: trashedState});
                        }
                    }

                    highlight: Rectangle {
                        color: 'yellow'
                    }

                    delegate: Common.ImageButton {
                        height: statesList.height
                        width: size
                        size: units.fingerUnit
                        image: model.image
                        onClicked: {
                            statesList.currentIndex = model.index;
                            relatedAnnotations.stateFilter = model.stateValue;
                            refreshAnnotationsList();
                        }
                    }

                    function selectAnyState() {
                        currentIndex = -1;
                        relatedAnnotations.stateFilter = relatedAnnotations.anyState;
                    }
                }
            }
        }

        Common.SearchBox {
            id: searchBox
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5
            onPerformSearch: {
                statesList.selectAnyState();
                refreshAnnotationsList();
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ListView {
                id: relatedAnnotationsView

                anchors.fill: parent
                clip: true

                property int listIndex

                model: ExtendedAnnotationsModel {
                    id: relatedAnnotationsModel
                }

                spacing: units.nailUnit

                bottomMargin: newAnnotationButton.height

                delegate: Rectangle {
                    width: relatedAnnotationsView.width
                    height: units.fingerUnit * 2
                    color: ((mainIdentifier !== '') && (model.title == mainIdentifier))?'yellow':'white'
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3
                            font.pixelSize: units.readUnit
                            color: 'green'
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: (model.labels)?model.labels:''
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: "<b>" + model.title + "</b> " + model.desc
                        }

                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 5
                            font.pixelSize: units.readUnit
                            color: 'red'
                            text: model.start + "\n" + model.end
                        }

                        StateComponent {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit * 3

                            stateValue: model.state
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            relatedAnnotations.mainIdentifier = model.title;
                            console.log('MAIN->', relatedAnnotations.mainIdentifier);
                            if (autoImport)
                                importConfirmationDialog.askImportConfirmation(model.title);
                            else
                                annotationSelected(model.title);
                        }
                    }
                }

                footer: (relatedAnnotationsModel.count==0)?noAnnotationsComponent:null

                Component {
                    id: noAnnotationsComponent
                    Text {
                        width: relatedAnnotationsView.width
                        height: units.fingerUnit
                        font.pixelSize: units.readUnit
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr('No hi ha anotacions.')
                    }
                }

                onListIndexChanged: {
                    if (relatedAnnotationsView.listIndex > -1)
                        relatedAnnotationsView.positionViewAtIndex(listIndex,ListView.Center);
                }
                Rectangle {
                    id: newAnnotationButton
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: units.fingerUnit * 2
                    width: units.fingerUnit * 2
                    radius: width / 2
                    color: 'green'

                    Common.ImageButton {
                        size: units.fingerUnit * 2 - units.nailUnit * 2
                        anchors.centerIn: parent
                        image: 'plus-24844'
                        onClicked: newAnnotation()
                    }
                }
            }
        }

    }

    function refreshAnnotationsList() {
        var filters = [];
        var labelsArray = [];
        labelsArray.push(relatedAnnotations.mainIdentifier);

        for (var i=0; i<labelsGrid.children.length; i++) {
            var obj = labelsGrid.children[i];
            if (obj.objectName == 'labelItem') {
                if (obj.selected) {
                    labelsArray.push(obj.labelText);
                    filters.push("(INSTR(' '||labels||' ',?))");
                }
            }
        }

        relatedAnnotationsModel.sort = 'start ASC, end ASC, title ASC';
        relatedAnnotationsModel.searchFields = ['title', 'desc'];
        relatedAnnotationsModel.searchString = searchBox.text;
        relatedAnnotationsModel.filters = ["title = ? OR ((" + ((filters.length>0)?filters.join(" AND "):"1=1") + ") AND (" + relatedAnnotations.stateFilter + "))"];
        relatedAnnotationsModel.bindValues = labelsArray;
        relatedAnnotationsModel.select();

        getMainIndex();
    }

    function getMainIndex() {
        for (var i=0; i<relatedAnnotationsModel.count; i++) {
            var obj = relatedAnnotationsModel.getObjectInRow(i);
            if (obj['title'] == mainIdentifier) {
                relatedAnnotationsView.listIndex = i;
                break;
            }
        }
        console.log('main index', relatedAnnotationsView.listIndex);
    }

    Common.SuperposedMenu {
        id: importConfirmationDialog

        title: qsTr("Vols importar aquesta anotació?")

        standardButtons: StandardButton.Yes | StandardButton.No

        property string annotationTitle

        function askImportConfirmation(annotation) {
            importConfirmationDialog.annotationTitle = annotation;
            importConfirmationDialog.open();
        }

        Text {
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("Amb l'anotació «" + importConfirmationDialog.annotationTitle + "» es realitzaran dues accions:\n1. S'adjuntarà al document «" + document + "».\n2. S'esborrarà l'anotació de la taula original.\nVols continuar?")
        }

        onYes: importSingleAnnotation(importConfirmationDialog.annotationTitle, document)
    }

    function importSingleAnnotation(annotation, doc) {
        // Import a single annotation and remove it

        console.log('Importing', annotation, 'into', doc);
        var annotationObj = relatedAnnotationsModel.getObject(annotation);
        if (annotation == annotationObj['title']) {
            var newAnnotationObj = {
                document: doc,
                title: annotationObj['title'],
                desc: annotationObj['desc'],
                labels: annotationObj['labels'],
                start: annotationObj['start'],
                end: annotationObj['end'],
                state: annotationObj['state']
            };

            documentAnnotationsModel.insertObject(newAnnotationObj);
            relatedAnnotationsModel.removeObject(annotation);
            relatedAnnotations.annotationImported(annotation);
        }
        refreshAnnotationsList();
    }

    Models.DocumentAnnotations {
        id: documentAnnotationsModel
    }
}
