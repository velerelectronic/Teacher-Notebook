import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: pagesFolderItem

    property string selectedContext: ''
    //property int selectedSection: sectionsList.currentIndex
    property string selectedPageTitle: ''

    signal goBack()
    signal publishMessage(string message)
    signal minimizePage()
    signal maximizePage()

    color: '#88AA88'

    Common.UseUnits {
        id: units
    }

    Models.RecentPages {
        id: recentPagesModel

        sort: 'timestamp ASC'

        function addPage(page, parameters, title) {
            console.log('adding', page, parameters);
            var found = false;
            var i;
            var date = new Date();

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
        }

        function deletePage(identifier) {
            removeObject(identifier);
            select();
        }

        Component.onCompleted: select()
    }

    Common.SuperposedWidget {
        id: newSectionDialog

        function openNewSection() {
            load(qsTr('Nova secció'), 'pagesfolder/NewSectionDialog', {selectedContext: pagesFolderItem.selectedContext})
            newSectionConnections.target = newSectionDialog.mainItem;
        }

        Connections {
            id: newSectionConnections

            onAddPage: {
                newSectionDialog.close();
                recentPagesModel.addPage(page, parameters, title);
            }
            onContextSelected: pagesFolderItem.selectedContext = context;
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            id: openPagesLayout

            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit + 2 * units.nailUnit

            ListView {
                id: openPagesList

                anchors.fill: parent

                spacing: units.nailUnit
                orientation: ListView.Horizontal
                model: recentPagesModel

                delegate: Item {
                    id: openPageRect

                    width: openPagesList.width / 4
                    height: openPagesList.height

                    property string pageTitle: model.title
                    property bool editMode: false

                    function toggleState() {
                        editMode = !editMode;
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: (parent.ListView.isCurrentItem)?'white':'gray'

                        MouseArea {
                            id: mainArea
                            anchors.fill: parent

                            onClicked: {
                                selectedPageTitle = model.title;
                                widgetsLoaderItem.addPage(model.page, model.parameters)
                                openPagesList.currentIndex = model.index;
                                //openPagesGrid.selectPage(model.index);
                                //openPageRect.state = 'maximized';
                            }

                            onPressAndHold: {
                                openPageRect.toggleState();
                            }
                        }

                        Text {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            verticalAlignment: Text.AlignVCenter

                            font.bold: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.title
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            visible: openPageRect.editMode

                            Common.ImageButton {
                                Layout.fillHeight: true
                                image: 'garbage-1295900'
                                onClicked: {
                                    widgetsLoaderItem.removeWidget(model.page, model.parameters);
                                    recentPagesModel.deletePage(model.id);
                                }
                            }
                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                            }
                            Common.ImageButton {
                                Layout.fillHeight: true
                                image: 'road-sign-147409'
                                onClicked: openPageRect.toggleState()
                            }
                        }
                    }
                }

            }

            Common.ImageButton {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                size: units.fingerUnit
                image: 'plus-24844'
                onClicked: newSectionDialog.openNewSection()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit + units.nailUnit * 2
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.fingerUnit

                ListView {
                    id: backButtonView

                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width

                    property int previousWidgetsCount

                    model: previousWidgetsCount
                    spacing: units.nailUnit
                    orientation: ListView.Horizontal

                    delegate: Common.ImageButton {
                        width: backButtonView.height
                        height: backButtonView.height

                        image: 'arrow-145769'

                        onClicked: goBack()
                    }
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
                    image: 'menu-145772'

                    onClicked: minimizePage()
                }
            }
        }

        Item {
            id: widgetsLoaderItem

            Layout.fillHeight: true
            Layout.fillWidth: true

            ListModel {
                id: openWidgetsModel
            }

            property int currentIndex: -1

            function indexOf(page, parameters) {
                var index = -1;
                for (var i=0; i<openWidgetsModel.count; i++) {
                    var object = openWidgetsModel.get(i);
                    if ((object.page == page) && (object.parameters == parameters)) {
                        index = i;
                        break;
                    }
                }
                return index;
            }

            function addPage(page, parameters) {
                var index = widgetsLoaderItem.indexOf(page, parameters);
                if (index>-1) {
                    widgetsLoaderItem.currentIndex = index;
                } else {
                    openWidgetsModel.append({page: page, parameters: parameters});
                    widgetsLoaderItem.currentIndex = openWidgetsModel.count - 1;
                }
            }

            function removeWidget(page, parameters) {
                var index = widgetsLoaderItem.indexOf(page, parameters);
                if (index<0)
                    openWidgetsModel.remove(index);
            }

            Repeater {
                model: openWidgetsModel

                StackView {
                    id: openPageLoader

                    anchors.fill: parent

                    property string page: model.page
                    property string parameters: model.parameters

                    visible: model.index === widgetsLoaderItem.currentIndex

                    PageConnections {
                        id: pageConnections

                        destination: openPageLoader
                        stack: openPageLoader
                    }


                    function addPage(page, parameters) {
                        // Parameters must be an associative array
                        console.log('page--->');
                        console.log('qrc:///modules/' + page + '.qml', parameters);
                        var newComp = Qt.createComponent('qrc:///modules/' + page + '.qml');
                        var newItem = newComp.createObject(openPageLoader, parameters);
                        openPageLoader.push(newItem);
                    }

                    function goBack() {
                        if (depth>1) {
                            pop();
                        }
                    }

                    Connections {
                        target: pagesFolderItem

                        onGoBack: openPageLoader.goBack()
                    }

                    onCurrentItemChanged: {
                        console.log('current item changed');
                        pageConnections.target = openPageLoader.currentItem;

                        pageConnections.destination = openPageLoader;
                        pageConnections.primarySource = openPageLoader.get((depth>1)?openPageLoader.depth-1:0)

                        backButtonView.previousWidgetsCount = Math.max(openPageLoader.depth-1,0);
                    }

                    Component.onCompleted: {
                        console.log('opening', model.page, model.parameters);
                        var parameters = (openPageLoader.parameters !== '')?JSON.parse(openPageLoader.parameters):{};
                        openPageLoader.addPage(openPageLoader.page, parameters);
                    }
                }

            }
        }
    }
}
