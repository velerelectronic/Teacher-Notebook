import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors

Rectangle {
    id: newAnnotationItem

    Common.UseUnits {
        id: units
    }

    signal showMessage(string message)
    signal closeNewAnnotation()
    signal openAnnotation(string title)

    property string labels: ''

    Models.ExtendedAnnotations {
        id: annotationsModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.fingerUnit

        Editors.TextAreaEditor3 {
            id: newAnnotationEditor
            Layout.fillHeight: true
            Layout.fillWidth: true
            border.color: 'black'
        }
        Flow {
            id: flow
            Layout.fillWidth: true
            Layout.preferredHeight: flow.childrenRect.height
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

    Loader {
        id: newAnnotationLoader

        anchors.fill: parent
    }

    Component {
        id: addTimetableAnnotationComponent

        Rectangle {
            id: addTimetableAnnotationMenuRect

            property int requiredHeight: columnLayout.height + units.fingerUnit * 4

            property var referenceDate
            property string annotation
            property int periodDay

            ColumnLayout {
                id: columnLayout

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.fingerUnit
                }

                GridView {
                    id: annotationsGrid

                    Layout.fillWidth: true
                    Layout.preferredHeight: contentItem.height

                    cellHeight: units.fingerUnit * 4
                    cellWidth: units.fingerUnit * 4

                    interactive: false

                    model: timetableAnnotationsModel

                    delegate: Item {
                        property string annotation: model.annotation

                        width: annotationsGrid.cellWidth
                        height: annotationsGrid.cellHeight
                        Common.BoxedText {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            color: 'transparent'
                            text: model.annotation
                            margins: units.nailUnit
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: annotationsGrid.currentIndex = model.index
                        }
                    }

                    highlight: Rectangle {
                        width: units.fingerUnit * 2
                        height: width
                        color: 'yellow'
                    }

                    highlightFollowsCurrentItem: true

                    onCurrentIndexChanged: {
                        addTimetableAnnotationMenuRect.annotation = currentItem.annotation;
                        timePeriodsModel.select();
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2

                    color: 'gray'
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        Common.ImageButton {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit
                            image: 'arrow-145769'
                            onClicked: {
                                var newDate = addTimetableAnnotationMenuRect.referenceDate;
                                newDate.setDate(newDate.getDate()-1);
                                addTimetableAnnotationMenuRect.referenceDate = newDate;
                            }
                        }

                        Text {
                            id: dayText

                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            text: addTimetableAnnotationMenuRect.referenceDate.toLongDate()

                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                            MouseArea {
                                anchors.fill: parent
                                onClicked: parent.state = (parent.state == 'selected')?'unselected':'selected'
                            }
                        }

                        Common.ImageButton {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit
                            image: 'arrow-145766'
                            onClicked: {
                                var newDate = addTimetableAnnotationMenuRect.referenceDate;
                                newDate.setDate(newDate.getDate()+1);
                                addTimetableAnnotationMenuRect.referenceDate = newDate;
                            }
                        }
                    }
                }

                ListView {
                    id: periodTimesList

                    Layout.fillWidth: true
                    Layout.preferredHeight: contentItem.height

                    interactive: false
                    model: timePeriodsModel
                    delegate: Rectangle {
                        width: periodTimesList.width
                        height: units.fingerUnit * 1.5

                        states: [
                            State {
                                name: 'unselected'
                            },
                            State {
                                name: 'selected'
                            }
                        ]
                        state: 'unselected'

                        color: (state == 'selected')?'yellow':'white'
                        border.color: 'black'

                        property string title: model.title
                        property string startTime: model.startTime
                        property string endTime: model.endTime

                        RowLayout {
                            anchors.fill: parent
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: units.fingerUnit * 2
                                text: model.startTime
                            }

                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: units.fingerUnit * 2
                                text: model.endTime
                            }

                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: model.title
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                parent.state = (parent.state == 'unselected')?'selected':'unselected';
                            }
                        }
                    }

                }

                Common.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('Crea totes les anotacions')
                    onClicked: {
                        addTimetableAnnotationMenuRect.createAllAnnotations();
                        newAnnotationItem.closeNewAnnotation();
                    }
                }
            }
            Models.TimeTablesModel {
                id: timetableAnnotationsModel

                fieldNames: ['annotation']

                Component.onCompleted: {
                    selectUnique('annotation');
                }
            }
            Models.TimeTablesModel {
                id: timePeriodsModel

                filters: [
                    'annotation=?',
                    'periodDay=?'
                ]
                bindValues: [
                    addTimetableAnnotationMenuRect.annotation,
                    addTimetableAnnotationMenuRect.periodDay
                ]

                sort: 'periodTime ASC'
            }

            Component.onCompleted: {
                addTimetableAnnotationMenuRect.referenceDate = new Date();
            }

            onReferenceDateChanged: {
                periodDay = ((referenceDate.getDay() + 6) % 7) + 1;
                timePeriodsModel.select();
            }

            function createAllAnnotations() {
                annotationsModel.select();
                for (var i=0; i<periodTimesList.count; i++) {
                    var periodObj = periodTimesList.contentItem.children[i];
                    if (periodObj.state == 'selected') {
                        var date = addTimetableAnnotationMenuRect.referenceDate;
                        var title = periodObj.title;
                        var start = date.toYYYYMMDDFormat() + " " + periodObj.startTime;
                        var end = date.toYYYYMMDDFormat() + " " + periodObj.endTime;

                        newAnnotation(qsTr('Diari') + " " + title + " " + date.toShortReadableDate(), start, end, 0);
                    }
                }
            }
        }
    }

    function newAnnotation(newTitle, start, end, state) {
        console.log('new title', newTitle, start, end, state);
        annotationsModel.insertObject({
                                          title: newTitle,
                                          desc: '',
                                          start: start,
                                          end: end,
                                          state: state
                                      });
        return newTitle;
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
        newAnnotationLoader.sourceComponent = addTimetableAnnotationComponent;
    }

    function importAnnotations() {
        importAnnotations(['title','desc','image'],annotationsModel,[]);
    }
}
