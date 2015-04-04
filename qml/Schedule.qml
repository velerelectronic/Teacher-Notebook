import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///javascript/Storage.js" as Storage


Rectangle {
    id: schedule
    property string pageTitle: qsTr('Agenda');
    signal editEvent(int idEvent,string event, string desc,string startDate,string startTime,string endDate,string endTime,int project,var projectsModel)
    signal deletedEvents (int num)

    property SqlTableModel projectsModel

    Common.UseUnits { id: units }

    ListView {
        id: eventList
        anchors.fill: parent

        property int order: 0
        clip: true

        model: scheduleModel
        delegate: ScheduleItem {
            id: oneScheduleItem
            anchors.left: parent.left
            anchors.right: parent.right
            state: {
                if (model.selected)
                    return 'selected'
                else {
                    if ((model.state) && (model.state=='done')) {
                        return 'done'
                    } else {
                        return 'basic'
                    }
                }
            }
            event: Storage.convertNull(model.event)
            desc: Storage.convertNull(model.desc)
            startDate: Storage.convertNull(model.startDate)
            startTime: Storage.convertNull(model.startTime)
            endDate: Storage.convertNull(model.endDate)
            endTime: Storage.convertNull(model.endTime)
            stateEvent: Storage.convertNull(model.state)
            project: (model.ref !=='')?parseInt(model.ref):-1
            projectsModel: schedule.projectsModel

            onScheduleItemSelected: {
                if (editBox.state == 'show') {
                    scheduleModel.selectObject(model.index,!scheduleModel.isSelectedObject(model.index));
                } else {
                    switch(oneScheduleItem.state) {
                    case 'basic':
                        oneScheduleItem.state = 'expanded';
                        break;
                    case 'expanded':
                        oneScheduleItem.state = 'basic';
                        break;
                    default:
                        break;
                    }
                }
            }
            onScheduleItemLongSelected: {
                console.log('REF' + model.ref);
                schedule.editEvent(id,event,desc,startDate,startTime,endDate,endTime,project,projectsModel);
            }
        }
        snapMode: ListView.SnapToItem

        section.property: ((order==1)||(order==3))?"startDate":"endDate"
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.InlineLabels
        section.delegate: Component {
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                color: 'white'
                height: units.fingerUnit
                Text {
                    anchors.fill: parent
                    font.bold: true
                    font.pixelSize: units.readUnit
                    verticalAlignment: Text.AlignBottom
                    text: ((eventList.order==1)||(eventList.order==3)?qsTr('A partir de'):qsTr('Fins a')) + ' ' + (section!=''?(new Date()).fromYYYYMMDDFormat(section).toLongDate():qsTr('no especificat'))
                }
            }
        }
    }
}
