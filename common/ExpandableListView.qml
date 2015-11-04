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
            }
        },
        State {
            name: 'expanded'
            PropertyChanges {
                target: expandableList
//                highlightRangeMode: ListView.ApplyRange
            }
        }
    ]

    state: (currentIndex < 0)?'simple':'expanded'

    currentIndex: -1
    delegate: Loader {
        id: simpleItemLoader
        height: (currentIndex === model.index)?expandableList.height:item.requiredHeight
        width: expandableList.width

        Behavior on height {
            PropertyAnimation {
                duration: 250
            }
        }

        sourceComponent: (currentIndex === model.index)?expandableComponent:itemComponent

        onLoaded: {
            if (typeof simpleItemLoader.item.model !== 'undefined')
                simpleItemLoader.item.model = model;
        }
    }

    Component {
        id: expandableComponent

        Item {
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
                            onClicked: expandableList.currentIndex = -1
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

                    onLoaded: {
                        console.log('new properties list');
                        for (var prop in itemProperties) {
                            console.log(prop, itemProperties[prop]);
                            expandedLoader.item[prop] = itemProperties[prop];
                        }
                    }
                }
            }
        }
    }

    function expandItem(index, propertiesList) {
        currentIndex = index;
        itemProperties = propertiesList;
        positionViewAtIndex(index,ListView.Beginning);
    }

    function closeItem() {
        currentIndex = -1;
    }

    function getModelProperty(index, propertyName) {

    }
}
