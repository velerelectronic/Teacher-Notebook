import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import PersonalTypes 1.0
import QtGraphicalEffects 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage

Rectangle {
    id: menuPage
    property string pageTitle: qsTr('Teacher Notebook');

    signal savedQuickAnnotation(string contents)

    property real buttonWidth: units.fingerUnit * 4
    property real buttonHeight: units.fingerUnit * 4

    signal openWorkingPage(string page, var parameters)
    signal sendOutputMessage(string message)

    Common.UseUnits { id: units }

    color: '#AAFFAA'

    ColumnLayout {
        anchors.fill: parent

        QuickAnnotation {
            Layout.fillWidth: true
            Layout.preferredHeight: height
            onSavedQuickAnnotation: {
                if (lastAnnotationsModel.insertObject({title: 'Anotació ràpida',desc: contents})) {
                    annotationsTotal.select();
                    annotationWasSaved();
                    menuPage.savedQuickAnnotation(contents);
                }
            }
        }

        ListView {
            id: mainList
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            spacing: units.nailUnit

            model: ListModel { id: mainListModel }

            preferredHighlightBegin: 0
            preferredHighlightEnd: height

            delegate: Rectangle {
                id: listSection

                color: model.color

                states: [
                    State {
                        name: 'minimum'

                        PropertyChanges {
                            target: listSection
                            height: Math.max(mainList.height / 3, units.fingerUnit * 4)
                        }

                        PropertyChanges {
                            target: mainList
                            interactive: true
                        }

                        PropertyChanges {
                            target: listItemLoader
                            interactivity: false
                        }
                    },
                    State {
                        name: 'maximum'

                        PropertyChanges {
                            target: listSection
                            height: mainList.height
                        }

                        PropertyChanges {
                            target: mainList
                            interactive: false
                        }

                        PropertyChanges {
                            target: listItemLoader
                            interactivity: true
                        }
                    }
                ]

                width: mainList.width
                state: 'minimum'

                Behavior on height {
                    PropertyAnimation { duration: 250 }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (listSection.state == 'minimum') {
                            listSection.state = 'maximum';
                            mainList.currentIndex = model.index;
                        }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit

                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        text: model.title
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                openWorkingPage(model.extraPage + ".qml", model.extraArguments);
                            }
                        }

                        Common.ImageButton {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            image: 'road-sign-147409'
                            onClicked: listSection.state = 'minimum'
                            available: listSection.state == 'maximum'
                        }
                    }
                    Loader {
                        id: listItemLoader
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        sourceComponent: model.component

                        clip: true

                        property bool interactivity: true

                        onInteractivityChanged: item.interactivity = interactivity
                    }
                }
            }

            Component.onCompleted: {
                mainListModel.append({title: qsTr('Darreres anotacions'), color: '#F3F781', extraPage: 'ExtendedAnnotationsList', extraArguments: {}, component: lastAnnotationsComponent})
                mainListModel.append({title: qsTr('Pròxims terminis'), color: '#F7BE81', extraPage: 'TasksSystem', extraArguments: {}, component: nextEventsComponent})
                mainListModel.append({title: qsTr('Projectes'), color: '#FFAACC', extraPage: 'Projects', extraArguments: {}, component: projectsComponent})
            }
        }

        Rectangle {
            Layout.preferredHeight: units.fingerUnit + buttonHeight + units.nailUnit * 3
            Layout.fillWidth: true
            color: '#FFCCAA'

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Common.BoxedText {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    fontSize: units.readUnit
                    color: 'transparent'
                    border.color: 'transparent'
                    margins: units.nailUnit
                    text: qsTr('Opcions')
                    width: parent.width
                    height: units.fingerUnit
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    orientation: ListView.Horizontal

                    clip: true

                    model: widgetsModel

                    spacing: units.nailUnit

                    delegate: Common.BigButton {
                        width: buttonWidth
                        height: buttonHeight
                        anchors.margins: units.nailUnit
                        title: model.title
                        onClicked: menuPage.openWorkingPage(model.page + ".qml",{})
                    }
                }

            }
        }
    }

    ListModel {
        id: widgetsModel

        Component.onCompleted: {
            widgetsModel.append({title: qsTr('Rúbriques'), page: 'RubricsList'});
            widgetsModel.append({title: qsTr('Espai de treball'), page: 'WorkSpace'});
            widgetsModel.append({title: qsTr('Projectes'), page: 'Projects'});
            widgetsModel.append({title: qsTr('Anotacions'), page: 'AnnotationsList'});
            widgetsModel.append({title: qsTr('Pissarra'), page: 'Whiteboard'});
            widgetsModel.append({title: qsTr('Documents'), page: 'DocumentsList'});
            widgetsModel.append({title: qsTr('Avaluació'), page: 'AssessmentSystem'});
            widgetsModel.append({title: qsTr('Recursos'), page: 'ResourceManager'});
            widgetsModel.append({title: qsTr('! Recerca de coneixement'), page: 'Researcher'});
            widgetsModel.append({title: qsTr('Feeds'), page: 'FeedWEIB'});
            widgetsModel.append({title: qsTr('Rellotge'), page: 'TimeController'});
            widgetsModel.append({title: qsTr('Gestor de dades'), page: 'DataMan'});
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: 'green'
        visible: false
    }

    Colorize {
        id: backgroundColorize
        anchors.fill: parent
        source: background
        visible: false

        hue: 0.5
        saturation: 0.5
        lightness: 0
        NumberAnimation on hue {
            duration: 250
        }
        NumberAnimation on saturation {
            duration: 250
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: false
        propagateComposedEvents: true

        property real newHue
        property real newSaturation

        property bool ascendingHue: false
        property bool ascendingSaturation: false

        property real initialCoordinateX: 0
        property real initialCoordinateY: 0

        function rotateValues(currentValue,difference,ascending,minValue,maxValue) {
            if (ascending) {
                if (currentValue + difference > maxValue) {
                    return maxValue;
                } else
                    return currentValue + difference;
            } else {
                if (currentValue - difference < minValue) {
                    return minValue;
                } else
                    return currentValue - difference;
            }
        }

        function changeColors() {
            newHue = Math.random() / 100;
            newSaturation = Math.random() / 100;

            backgroundColorize.hue = rotateValues(backgroundColorize.hue,newHue,ascendingHue,0,1);
            backgroundColorize.saturation = rotateValues(backgroundColorize.saturation,newHue,ascendingSaturation,0.5,1);
            if (backgroundColorize.hue==0)
                ascendingHue = true;
            if (backgroundColorize.hue==1)
                ascendingHue = false;
            if (backgroundColorize.saturation==0.5)
                ascendingSaturation = true;
            if (backgroundColorize.saturation==1)
                ascendingSaturation = false;

        }

        onPressed: {
            propagateComposedEvents = true;
            initialCoordinateX = mouseX;
            initialCoordinateY = mouseY;
            changeColors();
        }
        onMouseYChanged: changeColors()
        onMouseXChanged: changeColors()
        onReleased: {
            if (Math.pow(mouseX - initialCoordinateX, 2) + Math.pow(mouseY - initialCoordinateY, 2) > units.fingerUnit) {
                propagateComposedEvents = false;
                mouse.accepted = true;
            } else {
                propagateComposedEvents = true;
                mouse.accepted = false;
            }
        }
    }

    SqlTableModel {
        id: annotationsTotal
        tableName: globalAnnotationsModel.tableName
        Component.onCompleted: select()
    }
    SqlTableModel {
        id: scheduleTotal
        tableName: globalScheduleModel.tableName
        filters: ["ifnull(state,'') != 'done'"]
        Component.onCompleted: select();
    }

    Connections {
        target: globalScheduleModel
        onUpdated: scheduleTotal.select()
    }

    Component {
        id: lastAnnotationsComponent

        GridView {
            id: lastAnnotations

            cellWidth: units.fingerUnit * 4
            cellHeight: units.fingerUnit * 4

            property alias interactivity: lastAnnotations.interactive

            clip: true
            interactive: false

            property int horizontalCapacity: Math.floor(width / cellWidth)
            property int verticalCapacity: Math.floor(height / cellHeight)
            property int capacity: horizontalCapacity * verticalCapacity

            model: Models.SavedAnnotationsSearchesModel {
                id: savedSearches
                Component.onCompleted: select()
            }

            delegate: Item {
                width: lastAnnotations.cellWidth
                height: lastAnnotations.cellHeight

                Common.BoxedText {
                    anchors {
                        fill: parent
                        margins: units.nailUnit
                    }
                    margins: units.nailUnit

                    color: '#F7F8E0'
                    border.color: 'transparent'

                    fontSize: units.readUnit
                    text: model.title

                    MouseArea {
                        anchors.fill: parent
                        onClicked: openWorkingPage('ExtendedAnnotationsList.qml',{searchString: model.terms})
                    }
                }
            }
        }
    }

    Component {
        id: nextEventsComponent

        GridView {
            id: nextEvents

            property alias interactivity: nextEvents.interactive

            clip: true
            interactive: false

            cellWidth: units.fingerUnit * 4
            cellHeight: units.fingerUnit * 4

            property int horizontalCapacity: Math.floor(width / cellWidth)
            property int verticalCapacity: Math.floor(height / cellHeight)
            property int capacity: horizontalCapacity * verticalCapacity

            model: SqlTableModel {
                id: nextEventsModel
                tableName: globalScheduleModel.tableName
                fieldNames: globalScheduleModel.fieldNames
                limit: (nextEvents.interactivity)?0:nextEvents.capacity

                onLimitChanged: select()

                filters: ["ifnull(state,'') != 'done'"]
                Component.onCompleted: {
                    setSort(6,Qt.AscendingOrder); // Order by end date
                    select();
                }
            }
            Connections {
                target: globalScheduleModel
                onUpdated: nextEventsModel.select()
            }

            delegate: Item {
                width: nextEvents.cellWidth
                height: nextEvents.cellHeight

                Rectangle {
                    color: '#F8ECE0'
                    anchors.fill: parent
                    anchors.margins: units.nailUnit

                    ColumnLayout {
                        id: textEvents
                        anchors.fill: parent
                        anchors.margins: units.nailUnit

                        Text {
                            Layout.fillWidth: true
                            Layout.preferredHeight: contentHeight
                            text: model.endDate
                            font.bold: true
                            font.pixelSize: units.readUnit
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font.pixelSize: units.readUnit
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.event
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: openWorkingPage('ShowEvent.qml',{idEvent: model.id})
                    }
                }
            }
        }
    }

    Component {
        id: projectsComponent

        GridView {
            id: projectsGrid

            property alias interactivity: projectsGrid.interactive

            clip: true
            interactive: false

            cellWidth: units.fingerUnit * 4
            cellHeight: units.fingerUnit * 4

            property int horizontalCapacity: Math.floor(width / cellWidth)
            property int verticalCapacity: Math.floor(height / cellHeight)
            property int capacity: horizontalCapacity * verticalCapacity

            model: SqlTableModel {
                id: projectsModel
                tableName: globalProjectsModel.tableName

                Component.onCompleted: {
                    select();
                }
            }

            Connections {
                target: globalProjectsModel
                onUpdated: projectsModel.select()
            }

            delegate: Item {
                width: projectsGrid.cellWidth
                height: projectsGrid.cellHeight

                Common.BoxedText {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    color: '#F8ECE0'
                    border.color: 'transparent'
                    margins: units.nailUnit
                    text: model.name
                    fontSize: units.readUnit

                    MouseArea {
                        anchors.fill: parent
                        onClicked: openWorkingPage('ProjectEditor.qml',{idProject: id, projectsModel: projectsModel})
                    }
                }
            }

        }
    }

}
