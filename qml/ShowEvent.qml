import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates


CollectionInspector {
    id: eventEditor
    anchors.margins: units.nailUnit

    pageTitle: qsTr('Edita esdeveniment')

    signal closePage(string message)
    signal savedEvent(string event, string desc,date startDate,date startTime,date endDate,date endTime)
    signal canceledEvent(bool changes)

    property int idEvent: -1
    property string event: ''
    property string desc: ''
    property string startDate: ''
    property string startTime: ''
    property string endDate: ''
    property string endTime: ''
    property string stateEvent: ''
    property int project: -1

    property SqlTableModel projectsModel

    Common.UseUnits { id: units }

    onSaveDataRequested: {
        prepareDataAndSave(eventEditor.idEvent);
        closePage(qsTr('Esdeveniment desat: títol «') + event + qsTr('», descripcio «') + desc + qsTr('»'));
    }

    onCopyDataRequested: {
        prepareDataAndSave(-1);
    }

    onDiscardDataRequested: {
        if (changes) {
            closePage(qsTr("S'han descartat els canvis a l'esdeveniment"));
        } else {
            closePage('');
        }
    }

    onClosePageRequested: closePage('')

    model: ObjectModel {
        EditTextItemInspector {
            id: titleComponent
            width: eventEditor.width
            caption: qsTr('Esdeveniment')
        }
        EditStateItemInspector {
            id: stateComponent
            width: eventEditor.width
            caption: qsTr('Estat')
        }
        EditTextAreaInspector {
            id: descComponent
            width: eventEditor.width
            caption: qsTr('Descripció')
        }
        EditDateTimeItemInspector {
            id: startComponent
            width: eventEditor.width
            caption: qsTr('Inici')
        }
        EditDateTimeItemInspector {
            id: endComponent
            width: eventEditor.width
            caption: qsTr('Final')
        }
        EditTextItemInspector {
            id: projectComponent
            width: eventEditor.width
            caption: qsTr('Projecte')
        }
    }

    Component.onCompleted: {
        if (eventEditor.idEvent != -1) {
            var details = scheduleModel.getObject(eventEditor.idEvent);
            titleComponent.originalContent = details.event;
            descComponent.originalContent = details.desc;
            startComponent.originalContent = {date: details.startDate, time: details.startTime};
            endComponent.originalContent = {date: details.endDate, time: details.endTime};
            stateComponent.originalContent = details.state;
            projectComponent.originalContent = (details.ref !== '')?parseInt(details.ref):-1;
        }

        // Reinit changes
        eventEditor.setChanges(false);
    }

    function prepareDataAndSave(idCode) {
        var object = {
            event: titleComponent.editedContent,
            desc: descComponent.editedContent,
            startDate: startComponent.editedContent['date'],
            startTime: startComponent.editedContent['time'],
            endDate: endComponent.editedContent['date'],
            endTime: endComponent.editedContent['time'],
            state: stateComponent.editedContent,
            ref: projectComponent.editedContent
        }

        if (idCode == -1) {
            scheduleModel['created'] = Storage.currentTime();
            scheduleModel.insertObject(object);
        } else {
            object['id'] = idCode;
            scheduleModel.updateObject(object);
        }
        eventEditor.setChanges(false);
        eventEditor.savedEvent(object['title'],object['desc'],object['startDate'],object['startTime'],object['endDate'],object['endTime']);
    }

    function requestClose() {
        closeItem();
    }
}
