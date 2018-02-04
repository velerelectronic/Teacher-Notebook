import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common
import 'qrc:///modules/basic' as Basic

Common.ThreePanesNavigator {
    id: simpleAnnotationsListBaseItem

    property int lastSelectedAnnotation: -1
    property Component secondComponent

    signal openAnnotation(int identifier)

    Common.UseUnits {
        id: units
    }

    AnnotationTimeMarksModel {
        id: timeMarksModel
    }

    SimpleAnnotationsModel {
        id: annotationsModel

        property var today: new Date()

        sort: 'updated DESC'

        function update() {
            var today = new Date();
            select();
        }

        onUpdatedAnnotation: {
            if (annotation > -1) {
                lastSelectedAnnotation = annotation;
                update();
            }
        }

        Component.onCompleted: {
            createTable();
            update();
        }
    }

    firstPane: Common.NavigationPane {
        color: Qt.darker('yellow', 1.4)

        onClosePane: openPane('first')

        Common.GeneralListView {
            id: annotationsListView

            anchors.fill: parent

            model: annotationsModel

            toolBarHeight: (units.fingerUnit + units.nailUnit) * 2

            toolBar: Item {
                Basic.ButtonsRow {
                    id: annotationsListButtons

                    color: '#AAFFAA'
                    clip: true

                    anchors.fill: parent

                    buttonsSpacing: units.fingerUnit

                    Item {
                        height: annotationsListButtons.height
                        width: annotationsListButtons.height
                    }

                    Common.SearchBox {
                        id: searchBox

                        height: annotationsListButtons.height
                        width: annotationsListButtons.width / 2

                        text: docAnnotationsRect.searchString

                        onIntroPressed: {
                            annotationsModel.searchFields = annotationsModel.fieldNames;
                            annotationsModel.searchString = text;
                            annotationsModel.update();
                        }
                    }

                    Common.ImageButton {
                        height: annotationsListButtons.height
                        width: height

                        image: 'check-mark-303498'
                        onClicked: {
                        }
                    }
                }
            }

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
                        text: qsTr('Anotació')
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4

                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: qsTr('Propietari')
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4

                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: qsTr('Modificada')
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        font.bold: true
                        text: qsTr('Estat')
                    }
                }
            }

            delegate: Rectangle {
                width: annotationsListView.width
                height: units.fingerUnit * 2

                color: (model.id == lastSelectedAnnotation)?'yellow':'white'

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4

                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        elide: Text.ElideRight
                        text: '<p><b>' + model.title + '</b></p><p>' + model.desc + '</p>'
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4

                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: model.owner
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4

                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: {
                            var updated = new Date(Date.parse(model.updated));
                            var diff = annotationsModel.today.getTime() - updated.getTime();

                            var years = 0;
                            var months = 0;
                            var days = 0;
                            var hours = 0;

                            hours = Math.floor(diff / (60 * 60 * 1000));

                            days = Math.floor(hours / 24);
                            hours = hours % 24;

                            months = Math.floor(days / 30);
                            years = Math.floor(days / 365);
                            days = days % 30;

                            var time0 = qsTr("Fa");
                            var time1 = "";
                            var time2 = "";

                            if (years >=1) {
                                time1 = years + qsTr(" anys");
                                time2 = months + qsTr(" mesos");
                            } else {
                                if (months >=1) {
                                    time1 = months + qsTr(" mesos");
                                    time2 = days + qsTr(" dies");
                                } else {
                                    if (days >=1) {
                                        time1 = days + qsTr(" dies");
                                        time2 = hours + qsTr(" hores");
                                    } else {
                                        if (hours >= 1) {
                                            time1 = hours + qsTr(" hores");
                                            time2 = "";
                                        } else {
                                            time0 = qsTr("A les");
                                            var h = updated.getHours()
                                            var m = updated.getMinutes()
                                            time1 = h + ":" + ((m<10)?'0':'') + m
                                            time2 = ""
                                        }
                                    }
                                }
                            }

                            return [time0, time1, time2].join(" ");
                        }
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: model.state
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        lastSelectedAnnotation = model.id;
                        openAnnotation(lastSelectedAnnotation);
                    }
                }
            }

            Common.SuperposedButton {
                id: addAnnotationButton
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                size: units.fingerUnit * 2
                imageSource: 'plus-24844'
                onClicked: {
                    var annotId = annotationsModel.newAnnotation(qsTr('Nova anotació'), '');
                    if (annotId>-1)
                        lastSelectedAnnotation = annotId;
                }
            }

            Common.SuperposedButton {
                id: importAnnotationButton

                anchors {
                    right: addAnnotationButton.left
                    bottom: parent.bottom
                }
                size: units.fingerUnit * 2
                imageSource: 'box-24557'
                onClicked: openImporter()
                onPressAndHold: openImporter2()
            }
        }
    }

    secondPane: Common.NavigationPane {
        id: secondNavigationPane

        onClosePane: {
            console.log('closeeee');
            secondComponent = null;
            simpleAnnotationsListBaseItem.openPane('first');
        }

        Loader {
            id: secondPaneLoader

            anchors.fill: parent

            sourceComponent: secondComponent

            Connections {
                target: secondPaneLoader.item
                ignoreUnknownSignals: true

                onAnnotationCreated: {
                    lastSelectedAnnotation = identifier;
                    annotationsModel.update();
                }
            }

            Connections {
                target: simpleAnnotationsListBaseItem

                onOpenAnnotation: {
                    secondPaneLoader.setSource("ShowAnnotation.qml", {identifier: identifier});
                    openPane("second");
                }
            }
        }
    }

    thirdPane: Common.NavigationPane {
        color: 'gray'
    }

    function openImporter() {
        secondComponent = Qt.createComponent("ExtendedAnnotationsImport.qml");
        openPane('second');
    }

    function openImporter2() {
        secondComponent = Qt.createComponent("DocumentAnnotationsImport.qml");
        openPane('second');
    }
}
