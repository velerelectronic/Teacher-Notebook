import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models

BaseCard {
    Common.UseUnits {
        id: units
    }

    clip: true

    requiredHeight: openPagesList.contentItem.height

    Models.RecentPages {
        id: recentPagesModel

        sort: 'timestamp DESC'

        limit: 10

        function deletePage(identifier) {
            removeObject(identifier);
            select();
        }
    }

    ListView {
        id: openPagesList

        anchors.fill: parent

        spacing: units.nailUnit
        model: recentPagesModel
        interactive: false

        header: Text {
            width: openPagesList.width
            height: units.fingerUnit
            font.pixelSize: units.readUnit
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr('Carpeta completa')

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    selectedPage('pagesfolder/WorkingSpace', '', qsTr("Carpeta de pàgines"));
                }
            }
        }

        delegate: Item {
            id: openPageRect

            width: openPagesList.width
            height: units.fingerUnit * 1.5

            property string pageTitle: model.title
            property bool editMode: false

            function toggleState() {
                editMode = !editMode;
            }

            Rectangle {
                anchors.fill: parent
                color: 'white'

                MouseArea {
                    id: mainArea
                    anchors.fill: parent

                    onClicked: {
                        var parametersDict;
                        try {
                            parametersDict = JSON.parse(model.parameters);
                        }catch(e) {
                            parametersDict = {};
                        }

                        selectedPage(model.page, parametersDict, openPageRect.pageTitle)
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

        footer: (recentPagesModel.count>0)?emptyRecentPagesComponent:null

        Component {
            id: emptyRecentPagesComponent

            Item {
                width: openPagesList.width
                height: units.fingerUnit * 1.5

                Common.TextButton {
                    anchors.fill: parent
                    text: qsTr('Buida recents')

                    onClicked: emptyRecentPagesDialog.open()
                }
            }
        }
    }

    MessageDialog {
        id: emptyRecentPagesDialog

        title: qsTr("Buidar llista")

        text: qsTr("Es buidarà la llista de pàgines obertes recentment. Vols continuar?")

        standardButtons: StandardButton.Yes | StandardButton.No

        onYes: {
            recentPagesModel.removeAllObjects();
            updateContents();
        }
    }

    function updateContents() {
        recentPagesModel.select();
    }

    Component.onCompleted: updateContents()
}
