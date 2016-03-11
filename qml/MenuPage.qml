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

    signal openWorkingPage(string title, string page, var parameters)
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

                    model: (menuItemRect.isCurrentItem)?menuItemRect.submenu:[]
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
                                openWorkingPage(model.title, model.page, model.parameters);
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
        menuModel.append({caption: qsTr('Anotacions'), submenu: {object: menuPage, method: 'getSortLabels'}});
        menuModel.append({caption: qsTr('Taules'), submenu: {object: menuPage, method: 'getSortLabelsForTables'}});
        menuModel.append({caption: qsTr('Rúbriques'), submenu: {object: menuPage, method: 'getRubricsOptions'}});
        menuModel.append({caption: qsTr('Projectes'), submenu: {object: menuPage, method: 'getProjectsList'}});
        menuModel.append({caption: qsTr('Altres eines'), submenu: {object: menuPage, method: 'getOtherToolsList'}});

        menuModel.append({caption: qsTr('Espai de treball'), page: 'WorkSpace', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Pissarra'), page: 'Whiteboard', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Documents'), page: 'DocumentsList', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Recursos'), page: 'ResourceManager', parameters: {}, submenu: {object: menuPage, method: ''}});
    }

    ListModel {
        id: subMenuElements
    }

    Models.SavedAnnotationsSearchesModel {
        id: savedAnnotationsModel
    }

    Models.LabelsSortModel {
        id: labelsSortModel
    }

    function getSortLabels(title) {
        console.log('get saved searcges');
        labelsSortModel.select();
        subMenuElements.append({title: title, caption: qsTr('Ordenacions'), page: 'LabelsSort', parameters: {}});
        subMenuElements.append({title: title, caption: qsTr('Anotacions continues'), page: 'ContinuousAnnotationsList', parameters: {}});
        for (var i=0; i<labelsSortModel.count; i++) {
            var sortLabel = labelsSortModel.getObjectInRow(i);
            subMenuElements.append({title: title, caption: sortLabel.title, page: 'ExtendedAnnotationsList', parameters: {sortLabels: sortLabel.labels}});
        }
        subMenuElements.append({title: title, caption: qsTr('Anotacions (anterior)'), page: 'AnnotationsList', parameters: {}});
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
        subMenuElements.append({title: title, caption: qsTr('Avaluació'), page: 'RubricsAssessmentList', parameters: {}});
        subMenuElements.append({title: title, caption: qsTr('Definicions'), page: 'RubricsDefinitionsList', parameters: {}});
        subMenuElements.append({title: title, caption: qsTr('Grups'), page: 'RubricsGroupsList', parameters: {}});
        subMenuElements.append({title: title, caption: qsTr('Informes'), page: 'RubricsReportsList', parameters: {}});

        subMenuElements.append({title: title, caption: qsTr('Antigues avaluacions'), page: 'AssessmentSystem', parameters: {}});

    }

    function getProjectsList() {
        projectsModel.select();
        subMenuElements.append({caption: qsTr('Sense projecte'), page: 'ExtendedAnnotationsList', parameters: {onlyEmptyProjects: true}});
        for (var i=0; i<projectsModel.count; i++) {
            var projectObj = projectsModel.getObjectInRow(i);
            subMenuElements.append({caption: projectObj.name, page: 'ExtendedAnnotationsList', parameters: {project: projectObj.name}});
        }
    }

    function getOtherToolsList() {
        subMenuElements.append({caption: qsTr('Gestor de dades'), page: 'DataMan', parameters: {}});
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
