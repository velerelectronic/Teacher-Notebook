import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common

Item {
    id: basicPageItem

    property string pageTitle: basicPageItem.pageTitle
    property Component mainPage

    property int padding: 0

    signal closePage()
    signal openMenu(int initialHeight, var menu, var options)

    property ListModel buttonsModel: ListModel { dynamicRoles: true }

    property bool pageClosable: false

    function invokeSubPageFunction(method, parameters) {
        return basicPageLoader.item[method](parameters);
    }

    Loader {
        id: basicPageLoader

        anchors.fill: parent
        anchors.margins: basicPageItem.padding

        property string pageTitle: ((item) && (item.pageTitle))?item.pageTitle:''

        sourceComponent: basicPageItem.mainPage
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
                    Common.ImageButton {
                        Layout.fillHeight: true
                        size: units.fingerUnit
                        image: 'road-sign-147409'
                        onClicked: requestClosePage()
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
                    basicPageItem.buttonsModel.append({icon: 'road-sign-147409', object: workingSpace, method: 'requestClosePage'});
                }
            }

        }
    }

    Connections {
        target: basicPageLoader.item
        ignoreUnknownSignals: true

        // Slide menu

        onOpenMenu: {
            openMenu(initialHeight, menu, options);
        }

        // Page handling
        onOpenPage: {
            console.log('Opening page ' + page);
            openNewPage(page,{});
        }
        onClosePage: {
            closeCurrentPage();
            if (message != '')
                messageBox.publishMessage(message);
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
}

