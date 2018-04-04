import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import 'qrc:///common' as Common

Rectangle {
    id: spacesItem

    property string caption: ''
    property string qmlPage: ''
    property string pageProperties: ''

    property int initialWidth
    property int initialHeight

    signal selectedSpace(int index)
    signal spaceHasBeenDragged()
    signal doubleSelectedSpace(int index)

    // z will contain the space index in the whole list


    // Main properties


    x: z * units.fingerUnit
    y: z * units.fingerUnit

//    width: initialWidth
//    height: initialHeight

    border.color: 'black'

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
            RowLayout {
                anchors.fill: parent

                Common.ImageButton {
                    size: units.fingerUnit

                    image: 'outline-27146'
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
            }

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
        }
        Loader {
            id: pageLoader

            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true

            function loadPage() {
                console.log('SETTINGG', 'qrc:///modules/' + qmlPage + ".qml", pageProperties);
                if ((qmlPage !== "") && (pageProperties !== null))
                    pageLoader.setSource('qrc:///modules/' + qmlPage + ".qml", (pageProperties !== "")?JSON.parse(pageProperties):{});

            }

            onLoaded: {
                console.log('PROPERTIES of pageLoader item');
                /*
                for (var prop in pageLoader.item) {
                    console.log(prop, "(", typeof(pageLoader.item[prop]), ")", pageLoader.item[prop]);
                }
                */
                console.log(pageLoader.item.toSource());

            }

            Connections {
                target: spacesItem

                onQmlPageChanged: pageLoader.loadPage()
                onPagePropertiesChanged: pageLoader.loadPage()
            }

            Connections {
                target: pageLoader.item
                ignoreUnknownSignals: true

                onOpenCard: {
                    openSubSpace(qsTr('SubSpace'), page, pageProperties);
                }
            }
        }
    }

    Item {
        id: secondSpaceItem

        width: parent.width
        height: parent.height
        x: units.fingerUnit
        y: units.fingerUnit

        visible: false

        Loader {
            id: secondSpace

            anchors.fill: parent
        }

        Common.ImageButton {
            anchors {
                right: parent.right
                top: parent.top
            }
            size: units.fingerUnit
            image: 'road-sign-147409'

            onClicked: {
                secondSpace.sourceComponent = null;
                secondSpaceItem.visible = false;
            }
        }
    }

    function openSubSpace(caption, qmlPage, properties) {
        secondSpaceItem.visible = true;
        secondSpace.setSource("SpaceItem.qml", {caption: caption, qmlPage: qmlPage, pageProperties: JSON.stringify(properties)});
    }

    function resize(newWidth, newHeight) {
        spacesItem.width = newWidth;
        spacesItem.height = newHeight;
    }

    Component.onCompleted: {
        pageLoader.loadPage();
    }
}
