import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import 'qrc:///common' as Common

Flickable {
    id: multiWidgetArea

    Common.UseUnits { id: units }

    property bool isVertical: true
    signal emitSignal(string name, var param)

    rightMargin: units.fingerUnit
    contentWidth: width - rightMargin
    contentHeight: listArea.height

    flickableDirection: Flickable.VerticalFlick

    ListView {
        id: listArea
        width: multiWidgetArea.contentWidth
        height: contentItem.height
        orientation: ListView.Vertical
        interactive: false

        ListModel {
            id: widgetList
        }

        model: widgetList
        spacing: units.nailUnit

        property real eachSize: Math.max(units.fingerUnit * 10, multiWidgetArea.width / model.count, multiWidgetArea.height / model.count)

        delegate: RectangularGlow {
            id: wholePage
            width: listArea.width
            height: listArea.eachSize

            states: [
                State {
                    name: 'maximized'
                    PropertyChanges {
                        target: wholePage
                        height: multiWidgetArea.height
                    }
                    PropertyChanges {
                        target: listArea
                        snapMode: ListView.SnapToItem
                    }
                },
                State {
                    name: 'normal'
                    PropertyChanges {
                        target: wholePage
                        height: listArea.eachSize
                    }
                    PropertyChanges {
                        target: listArea
                        snapMode: ListView.NoSnap
                    }
                }
            ]

            state: 'normal'
            property alias pageItem: pageLoader.item

            color: 'gray'
            glowRadius: units.nailUnit / 3
            spread: 0.4

            Rectangle {
                anchors.fill: parent
                anchors.margins: parent.glowRadius
                color: 'white'

                RowLayout {
                    id: widgetControls
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: units.nailUnit
                    height: units.fingerUnit

                    spacing: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        text: pageLoader.item.pageTitle
                        font.pixelSize: units.readUnit
                        font.bold: true
                    }
                    ListView {
                        id: buttonsList
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        orientation: ListView.Horizontal
                        LayoutMirroring.enabled: true
                        layoutDirection: ListView.LeftToRight
                        spacing: units.fingerUnit / 2
                        clip: true
                        model: (pageLoader.item.buttons)?pageLoader.item.buttons:undefined

                        delegate: Rectangle {
                            id: button
                            height: units.fingerUnit
                            width: height
                            color: (checked)?'white':'transparent'
                            opacity: (button.enabled)?1.0:0.2

                            property bool enabled: (model.enabled)?model.enabled:true
                            property bool checkable: (model.checkable)?model.checkable:false
                            property bool checked: false

                            Image {
                                anchors.fill: parent
                                source: 'qrc:///icons/' + model.image + '.svg'
                                fillMode: Image.PreserveAspectFit
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (checkable)
                                        checked = !checked;
                                    pageLoader.item[model.method]();
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit
                        Image {
                            anchors.fill: parent
                            source: 'qrc:///icons/microsoft-windows-23242.svg'
                            fillMode: Image.PreserveAspectFit
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (wholePage.state === 'normal')
                                    wholePage.state = 'maximized';
                                else
                                    wholePage.state = 'normal';
                            }
                        }
                    }
                }
                Loader {
                    id: pageLoader
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: widgetControls.bottom
                        bottom: parent.bottom
                        margins: units.nailUnit
                    }

                    Component.onCompleted: pageLoader.setSource('qrc:///qml/' + model.page + '.qml',model.param)
                    onLoaded: {
/*
                        if (pageLoader.item.buttons) {
                            buttonsList.model = pageLoader.item.buttons;
                            console.log(pageLoader.item.buttons);
                        }
*/
                    }
                    Connections {
                        target: pageLoader.item
                        ignoreUnknownSignals: true
                        onEmitSignal: {
                            console.log('Signal ' + name + '-' + param);
                            multiWidgetArea.emitSignal(name, param);
                        }
                    }
                }
            }

        }


    }

    function addWidget(page,param) {
        widgetList.append({page: page, param: param});
        return widgetList.count;
    }

    function getWidget(index) {
        return
    }

    function pagesVector() {
        var vector = [];
        var items = listArea.contentItem.children;
        for (var i=0; i<items.length; i++) {
            vector.push(items[i].pageItem);
        }
        return vector;
    }
}
