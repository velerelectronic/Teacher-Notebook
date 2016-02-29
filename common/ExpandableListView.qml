import QtQuick 2.5
import QtQuick.Layouts 1.1
import '../common' as Common

ListView {
    id: expandableList

    Common.UseUnits {
        id: units
    }

    property int requiredHeight: contentItem.height
    property Component itemComponent

    property var itemProperties
    property int itemSize

    signal itemSelected(int index)
    signal newButtonsModel(var buttonsModel)

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
            name: 'selected'
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

    //state: (currentIndex < 0)?'simple':'expanded'

    currentIndex: -1
    property var lastSelected: ""

    delegate: Loader {
        id: simpleItemLoader
        height: simpleItemLoader.requiredHeight
        width: expandableList.width

        property bool isCurrentItem: ListView.isCurrentItem
        onIsCurrentItemChanged: item.isCurrentItem = simpleItemLoader.isCurrentItem

        objectName: 'expandableItem'

        property int requiredHeight: units.fingerUnit

        onHeightChanged: { console.log('Loader height set to',simpleItemLoader.height) }

        Behavior on height {
            PropertyAnimation {
                duration: 250
            }
        }

        property var identifier

        sourceComponent: itemComponent

        onLoaded: {
            if (typeof simpleItemLoader.item.model !== 'undefined') {
                simpleItemLoader.item.model = model;
            }
//            simpleItemLoader.requiredHeight = item.requiredHeight;
        }
        Connections {
            target: simpleItemLoader.item
            ignoreUnknownSignals: true
            onRequiredHeightChanged: {
                console.log('trying to change');
                simpleItemLoader.requiredHeight = item.requiredHeight;
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                expandableList.currentIndex = model.index;
                simpleItemLoader.item.itemSelected();
            }
            onPressAndHold: {
                expandableList.currentIndex = model.index;
            }
        }

        function expandItem(newState) {
            console.log('EXPANDING');
            simpleItemLoader.requiredHeight = simpleItemLoader.item.requiredHeight;
            expandableList.sendState('minimized');
            item.sendState(newState);

            openButtonsModel.clear();
            openButtonsModel.append({icon: 'road-sign-147409', object: expandableList, method: 'closeItems'});
            buttonsModel = openButtonsModel;
            newButtonsModel(buttonsModel);
        }

        function sendState(newState) {
            simpleItemLoader.item.sendState(newState);
        }
    }

    function sendState(newState) {
        console.log('sending state');
        for (var i=0; i<contentItem.children.length; i++) {
            if (contentItem.children[i].objectName == 'expandableItem') {
                contentItem.children[i].sendState(newState);
            }
        }

        buttonsModel = closeButtonsModel;
        newButtonsModel(buttonsModel);
    }

    function closeItems() {
        expandableList.sendState('minimized');
    }


    function getModelProperty(index, propertyName) {

    }

    function setProperty(index, prop, value) {
        model.setProperty(index, prop, value);
    }

    Component.onCompleted: newButtonsModel(buttonsModel)
}
