import QtQuick 2.6
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common

Rectangle {
    id: mainNavigatorRect

    signal setPage(int taskIndex, string qmlPage)

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent

        Common.SearchBox {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
        }

        ListView {
            id: concurrentTasks

            Layout.fillHeight: true
            Layout.fillWidth: true

            orientation: ListView.Horizontal
            boundsBehavior: Flickable.StopAtBounds

            snapMode: ListView.SnapToItem

            model: ListModel {
                id: pagesModel
            }

            spacing: units.nailUnit

            delegate: Rectangle {
                id: pageObject

                width: concurrentTasks.width
                height: concurrentTasks.height

                property string qmlPage: model.page
                property string caption: model.caption

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit

                        Text {
                            anchors.fill: parent
                            padding: units.nailUnit

                            text: model.caption
                        }
                    }
                    Loader {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        clip: true

                        Connections {
                            target: mainNavigatorRect

                            onSetPage: {
                                if (model.index == taskIndex) {
                                    console.log('this', model.index);
                                }
                            }
                        }

                        Component.onCompleted: {
                            console.log('Loading', 'qrc:///modules/' + pageObject.qmlPage + '.qml');
                            setSource('qrc:///modules/' + pageObject.qmlPage + '.qml');
                        }
                    }
                }
            }
        }
    }


    function addPage(caption, qmlPage) {
        pagesModel.append({caption: caption, page: qmlPage});
    }

}
