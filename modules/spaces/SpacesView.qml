import QtQuick 2.6
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import 'qrc:///common' as Common

Rectangle {
    id: spacesView

    color: 'gray'

    property int otherSpacesSize: units.fingerUnit * 2

    Common.UseUnits {
        id: units
    }

    Item {
        id: barItem

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: units.fingerUnit * 2

        RowLayout {
            anchors.fill: parent
            spacing: units.fingerUnit

            Common.ImageButton {
                Layout.fillHeight: true
                size: units.fingerUnit * 1.5
                image: 'outline-27146'

                onClicked: spaceItemsModel.select()
            }
            Common.ImageButton {
                Layout.fillHeight: true
                size: units.fingerUnit * 1.5
                image: 'microsoft-windows-23242'

                onClicked: spaceItemsActions.openPagesMenu()
            }
            Common.ImageButton {
                Layout.fillHeight: true
                size: units.fingerUnit * 1.5
                image: 'garbage-1295900'

                onClicked: {
                    spaceItemsList.removeAllObjects();
                    spaceItemsList.select();
                }
            }

            Flow {
                id: spacesNamesList

                Layout.fillWidth: true
                Layout.fillHeight: true

                property int cellsForRowNumber: Math.floor(width / (3 * units.fingerUnit))
                property int cellsWidth: Math.max((width / spaceItemsModel.count) - units.nailUnit, units.fingerUnit * 3)

                spacing: units.nailUnit
                clip: true

                property string lastSpaceCaption: ''

                function getLastSpace() {
                    var captionObj = spaceItemsModel.getObjectInRow(spaceItemsModel.count-1);
                    var caption = captionObj['caption'];
                    lastSpaceCaption = caption;
                }

                Repeater {
                    model: spaceItemsModel

                    delegate: Rectangle {
                        width: spacesNamesList.cellsWidth
                        height: units.fingerUnit

                        color: (model.caption == spacesNamesList.lastSpaceCaption)?'yellow':'white'

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                spacesNamesList.lastSpaceCaption = model.caption;
                                spacesView.relayer(model.caption);
                            }
                        }

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                            text: model.caption
                        }
                    }
                }
            }
            Common.ImageButton {
                Layout.fillHeight: true
                size: units.fingerUnit * 1.5
                image: 'plus-24844'

                onClicked: newAnnotationWidget.openNewAnnotation();
            }
        }
    }

    Item {
        id: spacesZone

        anchors {
            top: barItem.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Repeater {
            model: spaceItemsList

            SpaceItem {
                id: oneSpaceItem

                initialWidth: spacesZone.width / 2
                initialHeight: spacesZone.height / 2

                width: model.itemWidth
                height: model.itemHeight

                x: model.itemX
                y: model.itemY

                z: model.itemIndex

                maxX: spacesZone.width
                maxY: spacesZone.height

                caption: model.caption
                qmlPage: model.qmlPage
                pageProperties: JSON.parse(model.pageProperties)

                onSelectedSpace: {
                    relayer(caption);
                    spacesNamesList.lastSpaceCaption = caption;
                }

                onSpaceHasBeenDragged: {
                    spaceItemsModel.updateCoordinates(oneSpaceItem.caption, oneSpaceItem.x, oneSpaceItem.y);
                }

                onDoubleSelectedSpace: spaceItemsOptions.openOptions()

                onSavePageProperties: {
                    console.log('saving page properties', JSON.stringify(pageProperties), 'on', caption);
                    spaceItemsModel.updateObject(caption, {pageProperties: JSON.stringify(pageProperties)});
                }

                onToMainSpace: {
                    addSpace(caption, qmlPage, pageProperties);
                }

                Common.SuperposedWidget {
                    id: spaceItemsOptions

                    function openOptions(caption) {
                        load(qsTr('Opcions'), 'spaces/SpaceItemsOptions', {});
                    }

                    Connections {
                        target: spaceItemsOptions.mainItem
                        ignoreUnknownSignals: true

                        onMinimumSize: {
                            var reqWidth = Math.max(oneSpaceItem.innerItem.requiredWidth, units.fingerUnit * 2);
                            var reqHeight = Math.max(oneSpaceItem.innerItem.requiredHeight, units.fingerUnit * 2);
                            console.log('RW-RH', reqWidth, reqHeight);

                            spaceItemsModel.updateSize(oneSpaceItem.caption, reqWidth, reqHeight);
                            oneSpaceItem.resize(reqWidth, reqHeight);
                            spaceItemsOptions.close();
                        }
                        onMediumSize: {
                            spaceItemsModel.updateSize(oneSpaceItem.caption, spacesZone.width / 2, spacesZone.height / 2);
                            oneSpaceItem.resize(spacesZone.width / 2, spacesZone.height / 2);
                            spaceItemsOptions.close();
                        }
                        onColumnSize: {
                            spaceItemsModel.updateSize(oneSpaceItem.caption, units.fingerUnit * 10, spacesZone.height);
                            oneSpaceItem.resize(units.fingerUnit * 10, spacesZone.height);
                            spaceItemsOptions.close();
                        }
                        onRowSize: {
                            spaceItemsModel.updateSize(oneSpaceItem.caption, spacesZone.width, units.fingerUnit * 10);
                            oneSpaceItem.resize(spacesZone.width, units.fingerUnit * 10);
                            spaceItemsOptions.close();
                        }
                        onScreenSize: {
                            spaceItemsModel.updateSize(oneSpaceItem.caption, spacesZone.width, spacesZone.height);
                            oneSpaceItem.resize(spacesZone.width, spacesZone.height);
                            spaceItemsOptions.close();
                        }

                        onCloseSpace: {
                            spaceItemsList.removeSpace(oneSpaceItem.caption);
                            spaceItemsOptions.close();
                        }
                    }
                }

                Component.onCompleted: {
                    console.log('page-properties', JSON.stringify(oneSpaceItem.pageProperties));
                }
            }
        }
    }

    SpaceItemModel {
        id: spaceItemsList

        function removeSpace(caption) {
            removeObject(caption);
            select();
        }

        Component.onCompleted: select()
    }

    SpaceItemModel {
        id: spaceItemsModel

        function updateCoordinates(caption, posX, posY) {
            updateObject(caption, {itemX: posX, itemY: posY});
            select();
        }

        function updateSize(caption, width, height) {
            updateObject(caption, {itemWidth: width, itemHeight: height});
            select();
        }

        function moveUp(caption) {
            updateObject(caption, {itemIndex: spaceItemsList.count-1});
            select();
        }

        Component.onCompleted: select()
    }

    Common.SuperposedWidget {
        id: spaceItemsActions

        function openPagesMenu() {
            load(qsTr('Accions'), '../qml/MainPagesMenu', {});
        }

        Connections {
            target: spaceItemsActions.mainItem
            ignoreUnknownSignals: true

            // Check all these
            onOpenPage: {
                addSpace(caption, qmlPage, properties);
                spaceItemsActions.close();
            }
        }
    }

    Common.SuperposedWidget {
        id: newAnnotationWidget

        function openNewAnnotation() {
            load(qsTr('Nova anotació'), 'spaces/NewAnnotation', {});
        }

        Connections {
            target: newAnnotationWidget.mainItem

            onCloseNewAnnotation: newAnnotationWidget.close();

            onOpenPage: addSpace(caption, qmlPage, properties);
        }
    }

    function addSpace(caption, qmlPage, properties) {
        console.log('to main space', caption, qmlPage, properties);
        var index = spaceItemsList.count;
        var spaceProperties = {
            itemX: index * units.fingerUnit,
            itemY: index * units.fingerUnit,
            itemIndex: index,
            itemWidth: spacesZone.width / 3,
            itemHeight: spacesZone.height / 3,
            caption: caption,
            qmlPage: qmlPage,
            pageProperties: JSON.stringify(properties)
        }

        spaceItemsModel.insertObject(spaceProperties);
        spaceItemsList.select();
    }

    function relayer(caption) {
        // Put space with caption "caption" in front of others
        spaceItemsModel.moveUp(caption);

        // Recalculate z for all existing spaces

        var spacesObjList = spacesZone.children;
        for (var i=0; i<spaceItemsModel.count; i++) {
            var spaceObj = spaceItemsModel.getObjectInRow(i);
            var newZ = spaceObj['itemIndex'];
            spacesObjList[i].z = newZ;
        }
    }

}

