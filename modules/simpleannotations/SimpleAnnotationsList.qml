import QtQuick 2.7
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Common.ThreePanesNavigator {
    id: simpleAnnotationsListBaseItem

    property int lastSelectedAnnotation: -1
    property Component secondComponent

    Common.UseUnits {
        id: units
    }

    SimpleAnnotationsModel {
        id: annotationsModel

        property var today: new Date()

        sort: 'modified DESC'

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

        Common.GeneralListView {
            id: annotationsListView

            anchors.fill: parent

            model: annotationsModel

            toolBar: Rectangle {

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
                            var updated = new Date(Date.parse(model.modified));
                            var diff = updated.getTime() - annotationsModel.today.getTime();
                            var years = diff / (365 * 24 * 60 * 60 * 1000);
                            if (years >= 1) {
                                return qsTr("Fa ") + Math.floor(years) + qsTr(" i ") + Math.floor((years - Math.floor(years)) * 365) + qsTr(" dies");
                            } else {
                                var days = diff / (24 * 60 * 60 * 1000);
                                if (days >= 1) {
                                    return qsTr("Fa ") + Math.floor(days);
                                }
                            }

                            return updated.toISOString() + "\n" + model.modified;
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

                onExtendedAnnotationSelected: {
                    annotationsModel.newAnnotation(title, desc, 'ImportManager');
                    secondPaneLoader.item.removeSelectedAnnotation();
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
        secondComponent = Qt.createComponent("DocumentAnnotationsImporter.qml");
        openPane('second');
    }
}
