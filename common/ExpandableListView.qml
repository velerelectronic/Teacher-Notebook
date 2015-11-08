import QtQuick 2.5
import QtQuick.Layouts 1.1
import '../common' as Common

ListView {
    id: expandableList

    Common.UseUnits {
        id: units
    }

    property Component itemComponent
    property Component expandedComponent

    property var itemProperties

    property int itemSize

    states: [
        State {
            name: 'simple'
            PropertyChanges {
                target: expandableList
//                highlightRangeMode: ListView.ApplyRange
                interactive: true
            }
        },
        State {
            name: 'expanded'
            PropertyChanges {
                target: expandableList
//                highlightRangeMode: ListView.ApplyRange
                interactive: false
            }
        }
    ]

    state: (currentIndex < 0)?'simple':'expanded'

    currentIndex: -1
    property var lastSelected: ""

    delegate: Loader {
        id: simpleItemLoader
        height: (currentIndex === model.index)?expandableList.height:item.requiredHeight
        width: expandableList.width

        Behavior on height {
            PropertyAnimation {
                duration: 250
            }
        }

        property var identifier

        sourceComponent: (currentIndex === model.index)?expandableComponent:itemComponent

        onLoaded: {
            if (typeof simpleItemLoader.item.model !== 'undefined')
                simpleItemLoader.item.model = model;
        }
    }

    Component {
        id: expandableComponent

        Item {
            id: expandableItem

            property var identifier

            ColumnLayout {
                anchors.fill: parent
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 1.5
                    color: 'green'
                    border.color: 'black'
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit
                        Common.ImageButton {
                            image: 'road-sign-147409'
                            size: parent.height
                            onClicked: expandableList.closeItem()
                        }
                    }
                }
                Loader {
                    id: expandedLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Connections {
                        target: expandableList
                        onItemPropertiesChanged: {
                            expandedLoader.sourceComponent = expandedComponent;
                        }
                    }

                    Connections {
                        target: item
                        onIdentifierChanged: lastSelected = item.identifier
                    }

                    onLoaded: {
                        for (var prop in itemProperties) {
                            expandedLoader.item[prop] = itemProperties[prop];
                        }
                    }
                }
            }
            onHeightChanged: {
                expandableList.positionViewAtIndex(currentIndex,ListView.Beginning);
            }
        }
    }

    function expandItem(index, identifier, propertiesList) {
        currentIndex = index;
        propertiesList['identifier'] = identifier;
        itemProperties = propertiesList;
        console.log('Last selected', lastSelected);
    }

    function closeItem() {
        console.log('identifier',currentItem.identifier);
        currentIndex = -1;
    }

    function getModelProperty(index, propertyName) {

    }

    function setProperty(index, prop, value) {
        model.setProperty(index, prop, value);
    }
}
