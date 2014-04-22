import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import "Storage.js" as Storage
import 'common' as Common
import 'common/FormatDates.js' as FormatDates

ItemInspector {
    id: newEvent
    anchors.margins: units.nailUnit

    pageTitle: qsTr('Edita esdeveniment')

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

    property int idxEvent
    property int idxState
    property int idxDesc
    property int idxStart
    property int idxEnd

    Common.UseUnits { id: units }

    onSaveDataRequested: {
        prepareDataAndSave(newEvent.idEvent);
    }

    onCopyDataRequested: {
        prepareDataAndSave(-1);
    }

    onDiscardDataRequested: {
        // Ask for confirmation
        canceledEvent(changes);
    }

    Component.onCompleted: {
        function nullToEmpty(arg) {
            return (arg)?arg:'';
        }

        var details = {}
        if (newEvent.idEvent != -1) {
            details = Storage.getDetailsEventId(newEvent.idEvent);
            console.log('Details ' + JSON.stringify(details));
            newEvent.event = nullToEmpty(details.event);
            newEvent.desc = nullToEmpty(details.desc);
            newEvent.startDate = nullToEmpty(details.startDate);
            newEvent.startTime = nullToEmpty(details.startTime);
            newEvent.endDate = nullToEmpty(details.endDate);
            newEvent.endTime = nullToEmpty(details.endTime);
            newEvent.stateEvent = nullToEmpty(details.state);
        }

        newEvent.idxEvent = newEvent.addSection(qsTr('Esdeveniment'), newEvent.event,'yellow',editorType.TextLine);
        newEvent.idxState = newEvent.addSection(qsTr('Estat'), newEvent.stateEvent,'yellow',editorType.State);
        newEvent.idxDesc = newEvent.addSection(qsTr('Descripcio'), newEvent.desc,'yellow',editorType.TextArea);
        newEvent.idxStart = newEvent.addSection(qsTr('Inici'),{date: newEvent.startDate, time: newEvent.startTime},'green',editorType.Date);
        newEvent.idxEnd = newEvent.addSection(qsTr('Final'),{date: newEvent.endDate, time: newEvent.endTime},'green',editorType.Date);

        // Reinit changes
        newEvent.setChanges(false);
    }

    function prepareDataAndSave(idCode) {
        newEvent.event = getContent(idxEvent);
        newEvent.stateEvent = getContent(idxState);
        newEvent.desc = getContent(idxDesc).toString();
        var start = getContent(idxStart);
        newEvent.startDate = start['date'];
        newEvent.startTime = start['time'];
        var end = getContent(idxEnd);
        newEvent.endDate = end['date'];
        newEvent.endTime = end['time'];

        Storage.saveEvent(idCode,newEvent.event,newEvent.desc,newEvent.startDate,newEvent.startTime,newEvent.endDate,newEvent.endTime,newEvent.stateEvent);
        newEvent.setChanges(false);
        newEvent.savedEvent(newEvent.event,newEvent.desc,newEvent.startDate,newEvent.startTime,newEvent.endDate,newEvent.endTime);
    }
}
