import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common

Item {
    id: basicPageItem

    property string pageTitle: ''

    property Component mainPage
    property alias mainItem: basicPageLocation.item

    property bool isSubPage: false

    property int padding: 0

    signal openMainPage()
    signal closePage()
    signal openMenu(int initialHeight, var menu, var options)
    signal openPageArgs(string page, var args)
    signal showMessage(string message)

    property ListModel buttonsModel: ListModel { dynamicRoles: true }

    property var buttonsModelStack: []

    property bool pageClosable: true

    function setSource(source, parameters) {
        basicPageLocation.setSource(source, parameters);
    }

    function invokeSubPageFunction(method, parameters) {
        return basicPageLoader.item[method](parameters);
    }

    function pushButtonsModel() {
        console.log('In the stack before pushing', buttonsModelStack.length);
        var newListModel = Qt.createQmlObject("import QtQuick 2.5; ListModel {}", basicPageItem);
        console.log(newListModel);
        for (var i=0; i<basicPageItem.buttonsModel.count; i++) {
            newListModel.append(buttonsModel.get(i));
        }

        buttonsModelStack.push(newListModel);
        basicPageItem.buttonsModel.clear();
        console.log('In the stack after pushing', buttonsModelStack.length);
    }

    function popButtonsModel() {
        console.log('pop: ', buttonsModelStack.length);
        if (buttonsModelStack.length == 0)
            buttonsModel.clear();
        else {
            buttonsModel = buttonsModelStack.pop();
            console.log(buttonsModelStack.length);
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5

            RowLayout {
                anchors.fill: parent
                Common.ImageButton {
                    Layout.preferredWidth: units.fingerUnit
                    Layout.preferredHeight: units.fingerUnit

                    size: units.fingerUnit

                    image: (basicPageItem.isSubPage)?'arrow-145769':'small-41255'
                    onClicked: {
                        if (basicPageItem.isSubPage)
                            closePage();
                        else
                            basicPageItem.openMainPage();
                    }
                }

                Text {
                    id: title
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height
                    font.bold: true
                    font.pixelSize: units.glanceUnit
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Tahoma"
                    text: basicPageItem.pageTitle
                }

                ListView {
                    id: buttonsList
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width
                    spacing: units.fingerUnit
                    interactive: false
                    orientation: ListView.Horizontal

                    model: buttonsModel

                    delegate: Common.ImageButton {
                        width: size
                        height: width
                        size: units.fingerUnit
                        image: model.icon
                        onClicked: {
                            model.object[model.method]();
                        }
                    }
                }
            }
        }
        Loader {
            id: basicPageLocation

            Layout.fillHeight: true
            Layout.fillWidth: true
            sourceComponent: mainPage
            clip: true

            onLoaded: {
                if (typeof basicPageLocation.item !== 'undefined') {
                    basicPageLocation.item.width = basicPageLocation.width;
                    basicPageLocation.item.height = basicPageLocation.height;
                }
            }            
        }
    }


    MouseArea {
        id: subPageArea

        anchors.fill: parent
        onPressed: mouse.accepted = true
        onPositionChanged: mouse.accepted = true
        propagateComposedEvents: false
        visible: false
        enabled: false

        Rectangle {
            anchors.fill: parent
            color: 'black'
            opacity: 0.5
        }

        Rectangle {
            id: subPageRect
            anchors.fill: parent
            anchors.margins: basicPageItem.padding
            border.color: 'black'
            border.width: units.nailUnit

            Rectangle {
                id: subBar
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: parent.border.width
                    leftMargin: anchors.topMargin
                    rightMargin: anchors.topMargin
                }
                height: units.fingerUnit * 1.5
                color: 'green'
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.nailUnit
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: ((subPageloader.item) && (subPageloader.item.pageTitle))?subPageloader.item.pageTitle:''
                        color: 'white'
                    }
                }
            }

            Loader {
                id: subPageloader
                anchors {
                    top: subBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: parent.border.width
                    leftMargin: anchors.bottomMargin
                    rightMargin: anchors.bottomMargin
                }

                Connections {
                    target: subPageloader.item
                    onButtonsModelChanged: subPageloader.copyButtonsModel()
                }
                onLoaded: {
                    subPageloader.copyButtonsModel();
                }

                function copyButtonsModel() {
                    console.log('copying buttons model');
                    basicPageItem.buttonsModel.clear();
                    if ((item !== null) && (typeof item.buttons !== 'undefined')) {
                        var buttonsModel = item.buttonsModel;
                        for (var i=0; i<buttonsModel.count; i++) {
                            console.log(buttonsModel.count, i);
                            basicPageItem.buttonsModel.append(buttonsModel.get(i));
                        }
                    }
                }
            }

        }
    }

    MessageDialog {
        id: closeWorkingPageDialog

        title: qsTr("Tancar aquest espai")
        text: qsTr("Vols tancar aquest espai?")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        onAccepted: closeWorkingSpace()
    }

    function openSubPage(page, param, padding) {
        subPageArea.visible = true;
        subPageArea.enabled = true;
        subPageRect.anchors.margins = padding;
        subPageloader.setSource(Qt.resolvedUrl(page + '.qml'), param);
    }

    function requestClosePage() {
        subPageloader.sourceComponent = null;
        subPageArea.visible = false;
        subPageArea.enabled = false;
    }

    function closeSubPage() {
        subPageloader.source = undefined;
    }

    function closeThisPage() {
        closePage();
    }

    function lookFor() {
        basicPageItem.openPageArgs('OmniboxSearch',{});
    }

    Component.onCompleted: {
        buttonsModel.append({icon: 'magnifying-glass-481818', object: basicPageItem, method: 'lookFor'});
    }
}

