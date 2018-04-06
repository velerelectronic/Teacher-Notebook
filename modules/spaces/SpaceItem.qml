import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import 'qrc:///common' as Common

Rectangle {
    id: spacesItem

    property string caption: ''
    property string qmlPage: ''
    property var pageProperties: null

    property int initialWidth
    property int initialHeight

    property bool isSubSpace: false
    property alias innerItem: pageLoader.item

    signal selectedSpace(int index)
    signal spaceHasBeenDragged()
    signal doubleSelectedSpace(int index)
    signal toMainSpace(string caption, string qmlPage, var pageProperties)
    signal closeSubSpace()
    signal savePageProperties()

    // z will contain the space index in the whole list


    // Main properties


    x: z * units.fingerUnit
    y: z * units.fingerUnit

//    width: initialWidth
//    height: initialHeight

    border.color: 'black'

    // Two states for Space Items

    states: [
        State {
            name: 'card'
        },
        State {
            name: 'window'
        }
    ]

    Common.UseUnits {
        id: units
    }

    RectangularGlow {
        anchors.fill: parent
        color: 'black'
        glowRadius: units.nailUnit
        spread: 0.2
    }

    Rectangle {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            // Upper bar
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit

            MouseArea {
                anchors.fill: parent

                drag.target: spacesItem

                drag.axis: Drag.XandYAxis
                drag.minimumX: 0
                drag.minimumY: 0

                property bool beingDragged: drag.active

                onBeingDraggedChanged: {
                    if (!beingDragged) {
                        spaceHasBeenDragged();
                    }
                }

                onPressed: {
                    selectedSpace(spacesItem.z);
                }

                onDoubleClicked: {
                    doubleSelectedSpace(spacesItem.z);
                }
            }
            RowLayout {
                anchors.fill: parent

                Common.ImageButton {
                    size: units.fingerUnit

                    image: (isSubSpace)?'screen-capture-23236':'outline-27146'

                    onClicked: {
                        if (isSubSpace) {
                            spacesItem.toMainSpace(caption, qmlPage, pageProperties);
                            closeSubSpace();
                        }
                    }
                }

                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    padding: units.nailUnit

                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    text: caption
                }

                Common.ImageButton {
                    size: units.fingerUnit
                    image: (isSubSpace)?'road-sign-147409':''

                    onClicked: spacesItem.closeSubSpace()
                }
            }

        }
        Loader {
            id: pageLoader

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true

            function loadPage() {
                console.log('SETTINGG', 'qrc:///modules/' + qmlPage + ".qml", pageProperties);
                if ((qmlPage !== "") && (pageProperties != null)) {
                    pageLoader.setSource('qrc:///modules/' + qmlPage + ".qml", pageProperties);
                    pageLoaderConnections.target = pageLoader.item;
                }
            }

            onLoaded: {
                pageLoaderConnections.target = pageLoader.item;
            }


        }
    }


    Connections {
        id: pageLoaderConnections

        target: pageLoader.item

        ignoreUnknownSignals: true

        onOpenCard: {
            console.log('Now opening card');
            openSubSpace(qsTr('SubSpace'), page, pageProperties);
        }

        // This signal will be emitted when a property needs to be stored

        onAbcabc: {
            console.log('ABCABC', name, value);
        }

        onIdentifierChanged: {
            console.log('ident,ident--', pageLoader.item.identifier);
        }

        onSaveProperty: {
            console.log('-saveeee');
            pageProperties[name] = value;
            savePageProperties();
        }
    }

    Connections {
        target: spacesItem

        onQmlPageChanged: pageLoader.loadPage()
        onPagePropertiesChanged: pageLoader.loadPage()
    }


    Item {
        id: secondSpaceItem

        width: parent.width
        height: parent.height
        x: units.fingerUnit
        y: units.fingerUnit

        visible: false

        Loader {
            id: secondSpaceLoader

            anchors.fill: parent
        }

        Connections {
            target: secondSpaceLoader.item

            onToMainSpace: spacesItem.toMainSpace(caption, qmlPage, pageProperties)
            onCloseSubSpace: {
                secondSpaceLoader.sourceComponent = null;
                secondSpaceItem.visible = false;
            }
        }
    }

    function openSubSpace(caption, qmlPage, properties) {
        secondSpaceItem.visible = true;
        secondSpaceLoader.setSource("SpaceItem.qml", {isSubSpace: true, caption: caption, qmlPage: qmlPage, pageProperties: properties});
    }

    function resize(newWidth, newHeight) {
        spacesItem.width = newWidth;
        spacesItem.height = newHeight;
    }

    Component.onCompleted: {
        pageLoader.loadPage();
    }
}
