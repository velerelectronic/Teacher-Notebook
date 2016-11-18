import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///modules/documents' as Documents
import 'qrc:///modules/basic' as Basic
import 'qrc:///modules/pagesfolder' as PagesFolder

Rectangle {
    id: pagesFolderItem

    property string selectedContext: ''
    //property int selectedSection: sectionsList.currentIndex
    property string selectedPageTitle: ''

    signal goBack()
    signal publishMessage(string message)
    signal minimizePage()
    signal maximizePage()

    color: '#AADDAA'

    Common.UseUnits {
        id: units
    }

    ListModel {
        id: openPagesModel

        function addPage(page, parameters, title) {
            console.log('add page', page, parameters);
            var found = false;
            for (var i=0; i<count; i++) {
                var obj = get(i);
                if ((obj['page'] == page) && (obj['parameters'] == parameters)) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                append({page: page, parameters: parameters, title: title});
                openPagesGrid.selectPage(count-1);
            } else {
                openPagesGrid.selectPage(i);
            }
        }
    }


    Item {
        id: openPagesLayout

        anchors.fill: parent

        GridView {
            id: openPagesGrid

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: contentItem.height

            cellWidth: width / 5
            cellHeight: cellWidth * (pagesFolderItem.height / pagesFolderItem.width)

            model: openPagesModel
            interactive: false

            delegate: Rectangle {
                id: openPageRect

                width: openPagesGrid.cellWidth
                height: openPagesGrid.cellHeight

                property string pageTitle: model.title
                property int pageIndex: model.index

                color: (GridView.isCurrentItem)?'yellow':'transparent'
                states: [
                    State {
                        name: 'initial'

                        PropertyChanges {
                            target: mainPageLayout
                            visible: false
                        }
                        PropertyChanges {
                            target: openPagesLayout
                            visible: true
                        }
                    },

                    State {
                        name: 'minimized'

                        ParentChange {
                            target: openPageLoader
                            parent: openPageBackground
                        }
                        PropertyChanges {
                            target: openPageLoader
                            scale: openPageBackground.width / showPageItem.width
                        }
                        PropertyChanges {
                            target: openPagesLayout
                            visible: true
                        }
                        PropertyChanges {
                            target: mainPageLayout
                            visible: false
                        }
                    },
                    State {
                        name: 'maximized'

                        AnchorChanges {
                            anchors.top: pagesFolderItem.top
                        }

                        ParentChange {
                            target: openPageLoader
                            parent: showPageItem
                        }
                        PropertyChanges {
                            target: mainPageLayout
                            visible: true
                            anchors.top: pagesFolderItem.top
                        }
                        PropertyChanges {
                            target: openPagesLayout
                            visible: false
                        }
                        PropertyChanges {
                            target: openPageLoader
                            scale: 1
                        }
                        PropertyChanges {
                            target: disablerArea
                            enabled: false
                        }
                    }
                ]

                state: 'initial'

                PageConnections {
                    id: pageConnections

                    destination: openPageLoader
                    stack: openPageLoader
                }

                Rectangle {
                    id: openPageBackground

                    anchors.fill: parent
                    anchors.margins: units.nailUnit

                    StackView {
                        id: openPageLoader

                        z: 1
                        anchors {
                            top: parent.top
                            left: parent.left
                        }

                        width: showPageItem.width
                        height: showPageItem.height
                        clip: true

                        transformOrigin: Item.TopLeft

                        function addPage(page, parameters) {
                            // Parameters must be an associative array
                            console.log('page--->');
                            console.log('qrc:///modules/' + page + '.qml', parameters);
                            openPageLoader.push({item: 'qrc:///modules/' + page + '.qml', properties: parameters});
                        }

                        function goBack() {
                            if (depth>1) {
                                pop();
                            }
                        }

                        onCurrentItemChanged: {
                            console.log('current item changed');
                            pageConnections.target = openPageLoader.currentItem;

                            pageConnections.destination = openPageLoader;
                            pageConnections.primarySource = openPageLoader.get((depth>1)?openPageLoader.depth-1:0)
                        }

                        Component.onCompleted: {
                            console.log('opening', model.page, model.parameters);
                            var parameters = (model.parameters !== '')?JSON.parse(model.parameters):{};
                            openPageLoader.addPage(model.page, parameters);
                        }


                    }
                }

                MouseArea {
                    z: 2
                    anchors.fill: parent
                    onClicked: {
                        selectedPageTitle = model.title;
                        openPagesGrid.selectPage(model.index);
                        //openPageRect.state = 'maximized';
                    }
                    onPressAndHold: openPagesModel.remove(model.index)
                }

                Connections {
                    target: pagesFolderItem

                    onGoBack: openPageLoader.goBack()
                    onMinimizePage: {
                        if (openPageRect.state == 'maximized') {
                            openPageRect.state = 'minimized';
                        }
                    }
                    onMaximizePage: {
                        openPagesGrid.selectPage(openPageRect.pageIndex);
                    }
                }

            }

            function selectPreviousPage() {
                selectPage(openPagesGrid.currentIndex-1);
            }

            function selectNextPage() {
                selectPage(openPagesGrid.currentIndex+1);
            }

            function selectPage(index) {
                if (openPagesGrid.currentItem !== null)
                    openPagesGrid.currentItem.state = 'minimized';

                openPagesGrid.currentIndex = index;
                if (openPagesGrid.currentItem !== null) {
                    openPagesGrid.currentItem.state = 'maximized';
                    selectedPageTitle = openPagesGrid.currentItem.pageTitle;
                }
            }
        }

        NewSectionDialog {
            anchors {
                top: openPagesGrid.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            selectedContext: pagesFolderItem.selectedContext

            onContextSelected: pagesFolderItem.selectedContext = context;
        }
    }

    Rectangle {
        id: mainPageLayout

        anchors.fill: parent
        visible: false

        color: 'white'

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.fingerUnit + units.nailUnit * 2
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    spacing: units.fingerUnit

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        image: 'arrow-145769'
                        onClicked: goBack()
                    }

                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: units.glanceUnit
                        font.bold: true
                        text: selectedPageTitle
                    }


                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        image: 'arrow-145769'
                        onClicked: openPagesGrid.selectPreviousPage()
                    }

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        image: 'menu-145772'
                        onClicked: minimizePage()
                    }

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        image: 'arrow-145766'
                        onClicked: openPagesGrid.selectNextPage()
                    }
                }
            }
            Item {
                id: showPageItem

                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        MouseArea {
            id: disablerArea

            anchors.fill: parent
            onPressed: {
                mouse.accepted = true;
                maximizePage();
            }
        }
    }
}
