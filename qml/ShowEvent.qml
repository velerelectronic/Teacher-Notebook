import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage
// import "qrc:///javascript/FormatDates.js" as FormatDates


ItemInspector {
    id: newEvent
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

    property int idxEvent
    property int idxState
    property int idxDesc
    property int idxStart
    property int idxEnd
    property int idxProject

    Common.UseUnits { id: units }

    onSaveDataRequested: {
        prepareDataAndSave(newEvent.idEvent);
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

    Component.onCompleted: {
        if (newEvent.idEvent != -1) {
            var details = scheduleModel.getObject(newEvent.idEvent);
            newEvent.event = details.event;
            newEvent.desc = details.desc;
            newEvent.startDate = details.startDate;
            newEvent.startTime = details.startTime;
            newEvent.endDate = details.endDate;
            newEvent.endTime = details.endTime;
            newEvent.stateEvent = details.state;
            newEvent.project = (details.ref !== '')?parseInt(details.ref):-1;
        }

        idxEvent = addSection(qsTr('Esdeveniment'), newEvent.event,'yellow',editorType['TextLine']);
        idxState = addSection(qsTr('Estat'), newEvent.stateEvent,'yellow',editorType['State']);
        idxDesc = addSection(qsTr('Descripció'), newEvent.desc,'yellow',editorType['TextArea']);
        idxStart = addSection(qsTr('Inici'),{date: newEvent.startDate, time: newEvent.startTime},'green',editorType['DateTime']);
        idxEnd = addSection(qsTr('Final'),{date: newEvent.endDate, time: newEvent.endTime},'green',editorType['DateTime']);
        idxProject = addSection(qsTr('Projecte'), {reference: newEvent.project, model: projectsModel, nameAttribute: 'name'}, 'white', editorType['List']);

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
        newEvent.project = getContent(idxProject).reference;

        var object = {
            created: Storage.currentTime(),
            event: newEvent.event,
            desc: newEvent.desc,
            startDate: newEvent.startDate,
            startTime: newEvent.startTime,
            endDate: newEvent.endDate,
            endTime: newEvent.endTime,
            state: newEvent.stateEvent,
            ref: newEvent.project
        }

        console.log('Object ref ' + object.ref);

        if (idCode == -1) {
            scheduleModel.insertObject(object);
        } else {
            object['id'] = idCode;
            console.log('updating ' + scheduleModel.updateObject(object));
        }
        newEvent.setChanges(false);
        newEvent.savedEvent(newEvent.event,newEvent.desc,newEvent.startDate,newEvent.startTime,newEvent.endDate,newEvent.endTime);
    }

    function requestClose() {
        closeItem();
    }
}
