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

    Common.UseUnits { id: units }

    ListView {
        id: menuList

        anchors.fill: parent
        spacing: units.nailUnit

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
                        menuList.currentIndex = model.index;
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
                                subMenuList.currentIndex = model.index;
                            }
                        }
                    }
                    onCurrentIndexChanged: {
                        if (currentIndex>-1) {
                            var itemObject = subMenuElements.get(currentIndex);
                            console.log('Sub parameters', itemObject.parameters);
                            for (var prop in itemObject.parameters) {
                                console.log(prop, itemObject.parameters[prop]);
                            }

                            openWorkingPage(itemObject.page + ".qml", itemObject.parameters);
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
                menuPage.openWorkingPage(itemObject.page + ".qml", itemObject.parameters);
                if (itemObject.submenu.method !== '') {
                    itemObject.submenu.object[itemObject.submenu.method]();
                }
            }
        }
    }

    Component.onCompleted: {
        menuModel.append({caption: qsTr('Anotacions'), page: 'ExtendedAnnotationsList', parameters: {}, submenu: {object: menuPage, method: 'getSavedSearches'}});
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

    function getSavedSearches() {
        console.log('get saved searcges');
        savedAnnotationsModel.select();
        for (var i=0; i<savedAnnotationsModel.count; i++) {
            var savedAnnotation = savedAnnotationsModel.getObjectInRow(i);
            subMenuElements.append({caption: savedAnnotation.title, page: 'ExtendedAnnotationsList', parameters: {searchString: savedAnnotation.terms}});
        }
        subMenuElements.append({caption: qsTr('Anotacions (anterior)'), page: 'AnnotationsList', parameters: {}});
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
