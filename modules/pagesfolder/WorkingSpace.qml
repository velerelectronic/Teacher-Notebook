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

    Models.RecentPages {
        id: recentPagesModel

        sort: 'timestamp ASC'

        function getLastPage() {
            return getObjectInRow(0);
        }

        function addPage(page, parameters, title) {
            console.log('adding', page, parameters);
            var found = false;
            var i;
            var date = new Date();
            openPagesGrid.unselectCurrentPage();

            for (i=0; i<count; i++) {
                var obj = getObjectInRow(i);
                if ((obj['page'] == page) && (obj['parameters'] == parameters)) {
                    var objId = obj['id'];
                    updateObject(objId, {timestamp: date.toISOString(), title: title});
                    found = true;
                    break;
                }
            }
            if (!found) {
                insertObject({page: page, parameters: parameters, timestamp: date.toISOString(), title: title});
            }
            select();
            openPagesGrid.selectPage(count-1);
        }

        function deletePage(identifier) {
            removeObject(identifier);
            select();
        }

        Component.onCompleted: select()
    }

    Item {
        id: openPagesLayout

        anchors.fill: parent

        ListView {
            id: openPagesGrid

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            spacing: units.nailUnit
            height: units.fingerUnit

            orientation: ListView.Horizontal
            property int cellWidth: width / 5
            property int cellHeight: cellWidth * (pagesFolderItem.height / pagesFolderItem.width)

            model: recentPagesModel

            delegate: Item {
                id: openPageRect

                width: openPagesGrid.width / 5
                height: openPagesGrid.cellHeight

                property string pageTitle: model.title
                property int pageIndex: model.index

                states: [
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
                            y: 0
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

                state: 'minimized'

                PageConnections {
                    id: pageConnections

                    destination: openPageLoader
                    stack: openPageLoader
                }

                Behavior on x {
                    PropertyAnimation {
                        duration: 500
                    }
                }

                Rectangle {
                    id: openPageRect2

                    x: 0
                    y: 0
                    width: parent.width
                    height: parent.height
                    opacity: (1 - x/width)

                    color: (GridView.isCurrentItem)?'yellow':'transparent'

                    RowLayout {
                        anchors.fill: parent

                        Rectangle {
                            id: openPageBackground

                            Layout.preferredWidth: openPagesGrid.cellWidth
                            Layout.fillHeight: true

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

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            verticalAlignment: Text.AlignVCenter

                            font.bold: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.title
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            verticalAlignment: Text.AlignVCenter

                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.parameters
                        }
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
                            openPagesGrid.unselectCurrentPage();
                            openPagesGrid.selectPage(openPageRect.pageIndex);
                        }
                    }

                }

                MouseArea {
                    id: mainArea
                    anchors.fill: parent
                    property int initialX: 0

                    /*
                    drag.target: openPageRect2
                    drag.axis: Drag.XAxis
                    drag.minimumX: 0
                    drag.maximumX: width
                    */

                    property bool beingDragged: drag.active
                    onBeingDraggedChanged: {
                        if (!drag.active) {
                            if (openPageRect2.x > parent.width / 2) {
                                recentPagesModel.deletePage(model.id);
                            } else {
                                openPageRect2.x = 0;
                            }
                        }
                    }
                    onClicked: {
                        selectedPageTitle = model.title;
                        recentPagesModel.addPage(model.page, model.parameters, model.title)
                        //openPagesGrid.selectPage(model.index);
                        //openPageRect.state = 'maximized';
                    }

                    /*
                    onPressed: {
                        console.log('now')
                        mainArea.initialX = mouse.x;
                        mouse.accepted = true;
                    }
                    onPositionChanged: {
                        if (mouse.x - mainArea.initialX < 0)
                            mouse.accepted = false;
                        else {
                            console.log(mouse.x - mainArea.initialX);
                            openPageRect2.x = mouse.x - mainArea.initialX;
                        }
                    }
                    onReleased: {
                        if (mouse.x - mainArea.initialX > parent.width / 2) {
                            recentPagesModel.deletePage(model.id);
                        } else {
                            openPageRect2.x = 0;
                        }
                    }
                    */
                }

            }


            function selectPreviousPage() {
                selectPage(openPagesGrid.currentIndex-1);
            }

            function selectNextPage() {
                selectPage(openPagesGrid.currentIndex+1);
            }

            function unselectCurrentPage() {
                if (openPagesGrid.currentItem !== null)
                    openPagesGrid.currentItem.state = 'minimized';
            }

            function selectPage(index) {
                openPagesGrid.currentIndex = index;
                if (openPagesGrid.currentItem !== null) {
                    openPagesGrid.currentItem.state = 'maximized';
                    selectedPageTitle = openPagesGrid.currentItem.pageTitle;
                }
            }
        }

        NewSectionDialog {
            id: newSectionDialog
            anchors {
                top: openPagesGrid.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            selectedContext: pagesFolderItem.selectedContext

            onAddPage: recentPagesModel.addPage(page, parameters, title)
            onContextSelected: pagesFolderItem.selectedContext = context;
        }
    }

    Rectangle {
        id: mainPageLayout

        y: 0
        x: 0
        width: parent.width
        height: parent.height
        visible: false

        color: 'white'

        Behavior on y {
            PropertyAnimation {
                duration: 250
            }
        }

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
                MouseArea {
                    anchors.fill: parent

                    drag.target: mainPageLayout
                    drag.axis: Drag.YAxis
                    drag.minimumY: 0
                    drag.maximumY: mainPageLayout.height

                    property bool beingDragged: drag.active

                    onBeingDraggedChanged: {
                        if (!drag.active) {
                            if (mainPageLayout.y < mainPageLayout.height / 2) {
                                mainPageLayout.y = 0;
                            } else {
                                minimizePage();
                            }
                        }
                    }

                    onClicked: console.log('aa');
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
