import QtQuick 2.6
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import 'qrc:///common' as Common
import 'qrc:///modules/pagesfolder' as PagesFolder

Rectangle {
    id: mainNavigatorRect

    signal mainIconSelected()
    signal setPage(int taskIndex, string qmlPage)

    property ListModel pagesModel: ListModel {}

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Common.ImageButton {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height

                    image: 'small-41255'
                    onClicked: mainIconSelected()
                }

                Common.SearchBox {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    onIntroPressed: {
                        addPage('annotations2/AnnotationsList', {searchString: text, interactive: true}, qsTr('Cerca anotacions'))
                        text = "";
                    }
                }
            }

        }

        ListView {
            id: concurrentTasks

            Layout.fillHeight: true
            Layout.fillWidth: true

            orientation: ListView.Horizontal
            boundsBehavior: Flickable.StopAtBounds

            snapMode: ListView.SnapToItem

            highlightFollowsCurrentItem: true

            model: pagesModel

            spacing: units.nailUnit

            delegate: Rectangle {
                id: pageObject

                width: concurrentTasks.width
                height: concurrentTasks.height

                property string qmlPage: model.page
                property string caption: model.caption
                property string parameters: model.parameters

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit * 1.5

                        color: 'green'

                        Text {
                            anchors.fill: parent
                            padding: units.nailUnit

                            color: 'white'
                            font.bold: true
                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                            text: model.caption
                        }

                        Common.ImageButton {
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            size: units.fingerUnit
                            image: 'road-sign-147409'

                            onClicked: removePageAskDialog.removeAsk(model.index)
                        }
                    }
                    Loader {
                        id: pageLoader

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

                        Connections {
                            target: pageLoader.item

                            onSelectedPage: {
                                addPage(page, parameters, title);
                            }
                        }

                        PagesFolder.PageConnections {
                            id: pageConnections

                            target: pageLoader.item

                            destination: mainNavigatorRect
                        }


                        Component.onCompleted: {
                            console.log('Loading', 'qrc:///modules/' + pageObject.qmlPage + '.qml');
                            if (pageObject.parameters !== "") {
                                var paramObj = JSON.parse(pageObject.parameters);
                                if (!paramObj)
                                    paramObj = {};
                            }

                            setSource('qrc:///modules/' + pageObject.qmlPage + '.qml', paramObj);
                        }

                        onLoaded: {
                            pageConnections.target = pageLoader.item;
                            pageConnections.destination = mainNavigatorRect;
                        }
                    }
                }

                ListView.onRemove: SequentialAnimation {
                    PropertyAction {
                        target: pageObject
                        property: "ListView.delayRemove"
                        value: true
                    }
                    NumberAnimation {
                        target: pageObject
                        properties: 'opacity'
                        to: 0
                        duration: 1000
                    }
                    PropertyAction {
                        target: pageObject
                        property: "ListView.delayRemove"
                        value: false
                    }
                }
            }
            displaced: Transition {
                NumberAnimation {
                    property: "x"
                    duration: 1000
                }
            }
        }
    }


    MessageDialog {
        id: removePageAskDialog

        property int index;

        function removeAsk(index) {
            removePageAskDialog.index = index;
            open();
        }

        title: qsTr('Tancar pàgina')
        text: qsTr('Tancareu la pàgina i es perdran tots els canvis que no hàgiu desat. Vols continuar?')
        standardButtons: StandardButton.Yes | StandardButton.No

        onYes: {
            removePage(removePageAskDialog.index);
        }
    }

    function addPage(qmlPage, parameters, caption, move) {
        if (typeof move == 'undefined')
            move = true;
        console.log('calling', qmlPage);
        pagesModel.append({caption: caption, page: qmlPage, parameters: JSON.stringify(parameters)});
        if (move) {
            concurrentTasks.currentIndex = pagesModel.count-1;
        }
    }

    function removePage(index) {
        pagesModel.remove(index);
    }

    function changePage(index) {
        concurrentTasks.positionViewAtIndex(index, ListView.Contain);
    }
}
