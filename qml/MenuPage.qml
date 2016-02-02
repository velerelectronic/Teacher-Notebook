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

    signal openWorkingPage(string page, var parameters)
    signal sendOutputMessage(string message)

    property bool acceptPageChange: false

    function acceptNewChanges() {
        acceptPageChange = true;
        acceptPageChange = false;
    }

    Common.UseUnits { id: units }

    ListView {
        id: menuList

        anchors.fill: parent
        spacing: units.nailUnit

        property int indexCandidate: -1

        Connections {
            target: menuPage
            onAcceptPageChangeChanged: {
                if (acceptPageChange) {
                    if (menuList.indexCandidate > -1) {
                        menuList.currentIndex = menuList.indexCandidate;
                    }
                }
            }
        }

        model: ListModel {
            id: menuModel
        }

        delegate: Item {
            id: menuItemRect

            width: menuList.width
            height: units.fingerUnit * 2 + ((ListView.isCurrentItem)?subMenuList.height:0)

            property var submenu: subMenuElements
            property bool isCurrentItem: ListView.isCurrentItem

            function resetCurrentSubMenu() {
                subMenuList.currentIndex = -1;
            }

            Rectangle {
                id: captionText
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: (units.fingerUnit) * 2

                color: (menuItemRect.isCurrentItem)?'yellow':'transparent'

                Text {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    text: model.caption
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        menuList.indexCandidate = model.index;
                        if (model.page !== '') {
                            menuPage.openWorkingPage(model.page + ".qml", model.parameters);
                        }
                    }
                }
            }

            Rectangle {
                anchors {
                    top: captionText.bottom
                    left: parent.left
                    right: parent.right
                    leftMargin: units.fingerUnit / 2
                }
                height: subMenuList.contentItem.height
                color: '#D8D8D8'

                ListView {
                    id: subMenuList
                    anchors.fill: parent

                    property int subIndexCandidate: -1

                    Connections {
                        target: menuPage
                        onAcceptPageChangeChanged: {
                            if (acceptPageChange) {
                                if (subMenuList.subIndexCandidate > -1) {
                                    subMenuList.currentIndex = subMenuList.subIndexCandidate;
                                    subMenuList.subIndexCandidate = -1;
                                }
                            }
                        }
                    }

                    interactive: false
                    model: (menuItemRect.isCurrentItem)?menuItemRect.submenu:[]
                    delegate: Rectangle {
                        width: subMenuList.width
                        height: units.fingerUnit * 1.5

                        color: (ListView.isCurrentItem)?'orange':'transparent'
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
                                subMenuList.subIndexCandidate = model.index;
                                openWorkingPage(model.page + ".qml", model.parameters);
                            }
                        }
                    }
                    onCurrentIndexChanged: {
                        if (currentIndex>-1) {
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
                    itemObject.submenu.object[itemObject.submenu.method]();
                }
            }
        }
    }

    Component.onCompleted: {
        menuModel.append({caption: qsTr('Anotacions'), page: 'ExtendedAnnotationsList', parameters: {}, submenu: {object: menuPage, method: 'getSortLabels'}});
        menuModel.append({caption: qsTr('Taules'), page: '', parameters: {}, submenu: {object: menuPage, method: 'getSortLabelsForTables'}});
        menuModel.append({caption: qsTr('Rúbriques'), page: 'RubricsAssessmentList', parameters: {}, submenu: {object: menuPage, method: 'getRubricsOptions'}});
        menuModel.append({caption: qsTr('Projectes'), page: 'Projects', parameters: {}, submenu: {object: menuPage, method: 'getProjectsList'}});

        menuModel.append({caption: qsTr('Espai de treball'), page: 'WorkSpace', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Pissarra'), page: 'Whiteboard', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Documents'), page: 'DocumentsList', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Recursos'), page: 'ResourceManager', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('! Recerca de coneixement'), page: 'Researcher', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Feeds'), page: 'FeedWEIB', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Rellotge'), page: 'TimeController', parameters: {}, submenu: {object: menuPage, method: ''}});
        menuModel.append({caption: qsTr('Gestor de dades'), page: 'DataMan', parameters: {}, submenu: {object: menuPage, method: ''}});
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

    function getSortLabels() {
        console.log('get saved searcges');
        labelsSortModel.select();
        subMenuElements.append({caption: qsTr('Ordenacions'), page: 'LabelsSort', parameters: {}});
        for (var i=0; i<labelsSortModel.count; i++) {
            var sortLabel = labelsSortModel.getObjectInRow(i);
            subMenuElements.append({caption: sortLabel.title, page: 'ExtendedAnnotationsList', parameters: {sortLabels: sortLabel.labels}});
        }
        subMenuElements.append({caption: qsTr('Anotacions (anterior)'), page: 'AnnotationsList', parameters: {}});
    }

    function getSortLabelsForTables() {
        console.log('get saved searcges');
        labelsSortModel.select();
        for (var i=0; i<labelsSortModel.count; i++) {
            var sortLabel = labelsSortModel.getObjectInRow(i);
            subMenuElements.append({caption: sortLabel.title, page: 'CombinedAnnotationsTable', parameters: {sortLabels: sortLabel.labels}});
        }
    }

    function getRubricsOptions() {
        subMenuElements.append({caption: qsTr('Avaluació'), page: 'RubricsAssessmentList', parameters: {}});
        subMenuElements.append({caption: qsTr('Definicions'), page: 'RubricsDefinitionsList', parameters: {}});
        subMenuElements.append({caption: qsTr('Grups'), page: 'RubricsGroupsList', parameters: {}});
        subMenuElements.append({caption: qsTr('Informes'), page: 'RubricsReportsList', parameters: {}});

        subMenuElements.append({caption: qsTr('Antigues avaluacions'), page: 'AssessmentSystem', parameters: {}});

    }

    function getProjectsList() {
        projectsModel.select();
        subMenuElements.append({caption: qsTr('Sense projecte'), page: 'ExtendedAnnotationsList', parameters: {onlyEmptyProjects: true}});
        for (var i=0; i<projectsModel.count; i++) {
            var projectObj = projectsModel.getObjectInRow(i);
            subMenuElements.append({caption: projectObj.name, page: 'ExtendedAnnotationsList', parameters: {project: projectObj.name}});
        }
    }

    Models.ProjectsModel {
        id: projectsModel
        sort: 'name ASC'
        filters: ["name <> ''"]
    }
}
