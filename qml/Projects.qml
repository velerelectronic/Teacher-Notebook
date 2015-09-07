import QtQuick 2.3
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates

Rectangle {
    id: gantDiagram

    Common.UseUnits { id: units }

    property string pageTitle: qsTr('Projectes')

    signal editEvent(int idEvent,string event, string desc,string startDate,string startTime,string endDate,string endTime)
    signal newProjectRequest()
    signal showProject(int project)
    signal showCharacteristics(int project)
    signal showEvents(int project)

    property string documents: ''
    property int sectionsHeight: units.fingerUnit * 3
    property int sectionsWidth: units.fingerUnit * 5

    SqlTableModel {
        id: projectsModel

        tableName: globalProjectsModel.tableName
        fieldNames: globalProjectsModel.fieldNames
    }

    Connections {
        target: globalProjectsModel

        onUpdated: projectsModel.select()
    }

    ListView {
        id: projectsList
        z: 2
        anchors.fill: parent
        anchors.margins: units.nailUnit
        clip: true

        model: projectsModel

        delegate: Rectangle {
            id: eventTitle
            width: projectsList.width
            height: sectionsHeight
            clip: true
            border.color: 'black'
            RowLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit
                Common.BoxedText {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    fontSize: units.readUnit
                    margins: 0
                    border.color: 'transparent'
                    text: model.name
                    MouseArea {
                        anchors.fill: parent
                        onClicked: showProject(model.id)
                    }
                }

                Common.BoxedText {
                    Layout.preferredWidth: units.fingerUnit * 5
                    Layout.fillHeight: true
                    fontSize: units.readUnit
                    text: qsTr('Esdeveniments')
                    textColor: 'green'
                    border.color: 'transparent'
                    MouseArea {
                        anchors.fill: parent
                        onClicked: showEvents(model.id)
                    }
                }

                Common.BoxedText {
                    Layout.preferredWidth: units.fingerUnit * 5
                    Layout.fillHeight: true
                    fontSize: units.readUnit
                    textColor: 'pink'
                    border.color: 'transparent'
                    text: qsTr('Característiques')
                    MouseArea {
                        anchors.fill: parent
                        onClicked: showCharacteristics(model.id)
                    }
                }
            }
        }

        Common.SuperposedButton {
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            size: units.fingerUnit * 2
            imageSource: 'plus-24844'
            onClicked: newProject()
        }
    }

    function newProject() {
        newProjectRequest();
    }

    Component.onCompleted: {
        projectsModel.select();
    }

    /*
    SqlTableModel {
        id: events
        tableName: 'schedule'
        filters: []
        Component.onCompleted: {
            setSort(4,Qt.DescendingOrder); // Order by startDate
        }
    }
    */
}
