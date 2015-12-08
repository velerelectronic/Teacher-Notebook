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

    property ListModel buttonsModel: ListModel { }

    ListModel {
        id: closeButtonsModel
    }

    ListModel {
        id: openButtonsModel
    }

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

        Loader {
            id: expandedLoader

            property var identifier

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

        openButtonsModel.clear();
        openButtonsModel.append({icon: 'road-sign-147409', object: expandableList, method: 'closeItem'});
        buttonsModel = openButtonsModel;
    }

    function closeItem() {
        console.log('identifier',currentItem.identifier);
        currentIndex = -1;
        console.log('count', buttonsModel.count);
        buttonsModel = closeButtonsModel;
    }

    function getModelProperty(index, propertyName) {

    }

    function setProperty(index, prop, value) {
        model.setProperty(index, prop, value);
    }
}
