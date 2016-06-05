import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import PersonalTypes 1.0
import QtGraphicalEffects 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage

Item {
    id: menuPage
    property string pageTitle: qsTr('Teacher Notebook');

    signal annotationsListSelected()
    signal annotationSelected(string annotation)
    signal documentsListSelected()
    signal documentSelected(string document)
    signal reportSelected(string report)
    signal reportsListSelected()
    signal rubricsListSelected()
    signal rubricSelected(string rubric)

    signal sendOutputMessage(string message)

    function acceptNewChanges() {
        acceptPageChange = true;
        acceptPageChange = false;
    }

    Common.UseUnits { id: units }

    ColumnLayout {
        anchors.fill: parent
        Text {
            Layout.preferredHeight: contentHeight
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: units.glanceUnit
            font.bold: true
            text: 'Teacher Notebook'
        }

        ListView {
            id: menuList

            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: units.nailUnit
            clip: true

            orientation: ListView.Vertical

            model: ListModel {
                id: menuModel
            }

            delegate: Rectangle {
                id: menuItemRect

                width: menuList.width
                height: captionText.height + subMenuList.height + 2 * captionText.anchors.margins

                color: (isCurrentItem)?'#D8F6CE':'white'

                property var submenu: subMenuElements
                property bool isCurrentItem: ListView.isCurrentItem

                function resetCurrentSubMenu() {
                    subMenuList.currentIndex = -1;
                }

                Text {
                    id: captionText
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    anchors.margins: units.nailUnit
                    height: units.fingerUnit

                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    font.bold: menuItemRect.isCurrentItem
                    text: model.caption

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            menuList.currentIndex = model.index;
                        }
                    }
                }

                ListView {
                    id: subMenuList
                    anchors {
                        top: captionText.bottom
                        left: parent.left
                        right: parent.right
                    }
                    height: (menuItemRect.isCurrentItem)?units.fingerUnit * 3:0

                    property int subIndexCandidate: -1
                    orientation: ListView.Horizontal

                    spacing: units.nailUnit

                    model: (menuItemRect.isCurrentItem)?subMenuElements:[]
                    delegate: Rectangle {
                        width: units.fingerUnit * 4
                        height: units.fingerUnit * 2

                        border.color: 'black'
                        Text {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            text: model.caption
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log('model', model, model.title, model.caption, model.parameters);
                                if (model.parameters == null) {
                                    menuPage[model.method].call(menuPage);
                                } else {
                                    menuPage[model.method].call(menuPage, model.parameters);
                                }
                            }
                        }
                    }
                }
            }
            onCurrentIndexChanged: {
                subMenuElements.clear();

                if (currentIndex>-1) {
                    menuList.currentItem.resetCurrentSubMenu();

                    var itemObject = menuModel.get(currentIndex);
                    if (itemObject.submenu.method !== '') {
                        itemObject.submenu.object[itemObject.submenu.method](itemObject.caption);
                    }
                }
            }
        }
    }


    Component.onCompleted: {
        menuModel.append({caption: qsTr('Documents'), submenu: {object: menuPage, method: 'getDocumentsOptions'}});
        menuModel.append({caption: qsTr('Anotacions'), submenu: {object: menuPage, method: 'getSortLabels'}});
        menuModel.append({caption: qsTr('Taules'), submenu: {object: menuPage, method: 'getSortLabelsForTables'}});
        menuModel.append({caption: qsTr('Rúbriques'), submenu: {object: menuPage, method: 'getRubricsOptions'}});
        menuModel.append({caption: qsTr('Altres eines'), submenu: {object: menuPage, method: 'getOtherToolsList'}});

        menuModel.append({caption: qsTr('Espai de treball'), page: 'WorkSpace', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Pissarra'), page: 'Whiteboard', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Documents'), page: 'DocumentsList', parameters: {}, submenu: {object: menuPage, method: ''}});
    }

    ListModel {
        id: subMenuElements

        dynamicRoles: true
    }

    Models.SavedAnnotationsSearchesModel {
        id: savedAnnotationsModel
    }

    Models.LabelsSortModel {
        id: labelsSortModel
    }

    Models.ConcurrentDocuments {
        id: concurrentDocuments

        sort: 'lastAccessTime DESC'
    }

    function getDocumentsOptions(title) {
        concurrentDocuments.select();
        subMenuElements.clear();

        for (var i=0; i<concurrentDocuments.count; i++) {
            var documentObject = concurrentDocuments.getObjectInRow(i);
            subMenuElements.append({title: title, caption: documentObject['document'], method: "documentSelected", parameters: documentObject['document']});
        }

        subMenuElements.append({title: title, caption: qsTr('Llista'), method: 'documentsListSelected', parameters: null});
    }

    function getSortLabels(title) {
        console.log('get saved searcges');
        labelsSortModel.select();
        subMenuElements.append({title: title, caption: qsTr('Ordenacions'), method: 'LabelsSort', parameters: null});
        subMenuElements.append({title: title, caption: qsTr('Anotacions'), method: 'annotationsListSelected', parameters: null});
    }

    function getSortLabelsForTables(title) {
        console.log('get saved searcges');
        labelsSortModel.select();
        for (var i=0; i<labelsSortModel.count; i++) {
            var sortLabel = labelsSortModel.getObjectInRow(i);
            subMenuElements.append({title: title, caption: sortLabel.title, page: 'CombinedAnnotationsTable', parameters: {sortLabels: sortLabel.labels}});
        }
    }

    function getRubricsOptions(title) {
        subMenuElements.append({title: title, caption: qsTr('Avaluació'), method: 'rubricsListSelected', parameters: {}});
        subMenuElements.append({title: title, caption: qsTr('Definicions'), method: 'rubricDefinitionsSelected', parameters: {}});
        subMenuElements.append({title: title, caption: qsTr('Grups'), page: 'groupsListSelected', parameters: {}});
        subMenuElements.append({title: title, caption: qsTr('Informes'), page: 'reportsListSelected', parameters: {}});
    }

    function getOtherToolsList() {
        subMenuElements.append({caption: qsTr('Gestor de dades'), page: 'DataMan', parameters: {}});
        subMenuElements.append({caption: qsTr('Exportador'), page: 'ExportManager', parameters: {}});
        subMenuElements.append({caption: qsTr('! Recerca de coneixement'), page: 'Researcher', parameters: {}, submenu: {object: menuPage, method: ''}});
        subMenuElements.append({caption: qsTr('Feeds'), page: 'FeedWEIB', parameters: {}});
        subMenuElements.append({caption: qsTr('Rellotge'), page: 'TimeController', parameters: {}});
    }

    Models.ProjectsModel {
        id: projectsModel
        sort: 'name ASC'
        filters: ["name <> ''"]
    }
}
