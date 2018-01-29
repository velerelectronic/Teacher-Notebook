import QtQuick 2.7
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///modules/calendar' as Calendar

Common.ThreePanesNavigator {
    id: annotationsCalendarBaseItem

    Common.UseUnits {
        id: units
    }

    property string lastSelectedDate: ''
    property int lastSelectedMarkId: -1
    property int lastSelectedAnnotation: -1

    onLastSelectedDateChanged: {
        if (lastSelectedDate != "") {
            console.log(lastSelectedDate);
            mainMarksModel.selectAnnotations(lastSelectedDate);
        }
    }

    AnnotationsWithTimeMarksModel {
        id: mainMarksModel
    }

    firstPane: Common.NavigationPane {
        color: Qt.darker('yellow', 1.4)

        onClosePane: openPane('first')

        ColumnLayout {
            anchors.fill: parent
            spacing: units.nailUnit

            GridLayout {
                id: calendarGrid

                anchors.fill: parent

                property bool isHorizontal: calendarGrid.width > calendarGrid.height

                columns: (isHorizontal)?2:1
                rows: (isHorizontal)?1:2

                Calendar.WeeksView {
                    id: weeksCalendarView

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    weeksNumber: 5
                    interactive: false
                    daysOverWidget: true

                    subWidget: Rectangle {
                        id: dayCell

                        property int day
                        property int month
                        property int year
                        property string dateStr

                        AnnotationsWithTimeMarksModel {
                            id: marksModel
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                lastSelectedDate = dayCell.dateStr;
                            }
                        }

                        function dateUpdated() {
                            var date = new Date(year, month, day, 0, 0, 0, 0);
                            dayCell.dateStr = date.toYYYYMMDDFormat();
                            getTimeMarks(dayCell.dateStr);
                        }

                        function getTimeMarks(dateStr) {
                            marksModel.selectAnnotations(dateStr);
                            var c = marksModel.count

                            if (c == 0) {
                                dayCell.color = 'white';
                            } else {
                                if (c == 1) {
                                    dayCell.color = 'yellow';
                                } else {
                                    if (c>10) {
                                        dayCell.color = 'red';
                                    } else {
                                        dayCell.color = 'orange';
                                    }
                                }
                            }
                        }
                    }
                }

                Common.GeneralListView {
                    id: marksListView

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: mainMarksModel

                    toolBarHeight: 0
                    headingBar: Rectangle {
                        color: '#DDFFDD'

                        RowLayout {
                            anchors.fill: parent
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Temps')
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Tipus')
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Etiqueta')
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                font.bold: true
                                text: qsTr('Anotació')
                            }
                        }
                    }

                    delegate: Rectangle {
                        width: marksListView.width
                        height: units.fingerUnit * 4

                        color: (model.markId == lastSelectedMarkId)?'yellow':'white'

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit

                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                text: model.timeMark
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit

                                text: model.markType
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 4

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                elide: Text.ElideRight
                                text: model.markLabel
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.pixelSize: units.readUnit
                                text: '<p><b>' + model.annotationTitle + '</b></p><p>' + model.annotationDesc + '</p>'
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                lastSelectedMarkId = -1;
                                // the following order of assignments is important
                                lastSelectedAnnotation = model.annotationId;
                                lastSelectedMarkId = model.markId;
                            }
                        }
                    }

                }
            }

        }

    }

    secondPane: Common.NavigationPane {
        id: secondNavigationPane

        onClosePane: {
            console.log('closeeee');
            secondComponent = null;
            openPane('first');
        }

        Loader {
            id: secondPaneLoader

            anchors.fill: parent

            sourceComponent: secondComponent

            Connections {
                target: annotationsCalendarBaseItem

                onLastSelectedMarkIdChanged: {
                    if ((lastSelectedMarkId > -1) && (lastSelectedAnnotation > -1)) {
                        secondPaneLoader.sourceComponent = null;
                        secondPaneLoader.setSource("ShowAnnotation.qml", {identifier: lastSelectedAnnotation});
                        openPane("second");
                    }
                }
            }
        }
    }
}
