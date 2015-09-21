import QtQuick 2.5
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates
import "qrc:///javascript/Storage.js" as Storage


Rectangle {
    id: schedule
    property string pageTitle: qsTr('Agenda');
    signal showEvent(var parameters)
    signal deletedEvents (int num)

    property SqlTableModel scheduleModel
    property int order: 0

    property int requiredHeight: eventList.contentItem.height + units.nailUnit * 2

    property alias interactive: eventList.interactive

    Common.UseUnits { id: units }

    ListView {
        id: eventList
        anchors.fill: parent
        anchors.margins: units.nailUnit

        clip: true

        model: scheduleModel

        headerPositioning: ListView.OverlayHeader
        header: Rectangle {
            width: eventList.width
            height: units.fingerUnit
            z: 2
            RowLayout {
                anchors.fill: parent
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 5
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: ((schedule.order === 1)||(schedule.order === 3))?qsTr('A partir de'):qsTr('Fins a')
                }
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 2 * parent.width / 5
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Terminis')
                }
                Text {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    font.pixelSize: units.readUnit
                    font.bold: true
                    text: qsTr('Descripció')
                }
            }
        }

        delegate: ScheduleItem {
            id: oneScheduleItem
            z: 1
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
            idEvent: model.id
            title: Storage.convertNull(model.event)
            desc: Storage.convertNull(model.desc)
            startDate: Storage.convertNull(model.startDate)
            startTime: Storage.convertNull(model.startTime)
            endDate: Storage.convertNull(model.endDate)
            endTime: Storage.convertNull(model.endTime)
            stateEvent: Storage.convertNull(model.state)
            project: (model.ref !=='')?parseInt(model.ref):-1
            annotationTitleDesc: model.annotationTitle + model.annotationDesc
            section: {
                if (ListView.section === '') {
                    return qsTr('Sense data');
                } else {
                    if (ListView.section !== ListView.previousSection) {
                        var date = (new Date()).fromYYYYMMDDFormat(ListView.section).toShortReadableDate();
                        return date;
                    } else
                        return '';
                }
            }
            onScheduleItemSelected: {
                schedule.showEvent({idEvent: event});
                /*
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
                */
            }
            onScheduleItemLongSelected: {
                schedule.showEvent({idEvent: event});
            }
        }
        snapMode: ListView.SnapToItem

        section.property: ((order==1)||(order==3))?"startDate":"endDate"
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.InlineLabels
        section.delegate: Rectangle {
            width: eventList.width
            height: units.nailUnit * 2
            z: 1
        }
    }
}
