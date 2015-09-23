import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage
import "qrc:///common/FormatDates.js" as FormatDates


CollectionInspector {
    id: eventEditor
    anchors.margins: units.nailUnit

    pageTitle: qsTr('Edita esdeveniment')

    signal closePage(string message)
    signal savedEvent(string event, string desc,date startDate,date startTime,date endDate,date endTime)
    signal canceledEvent(bool changes)

    signal showEventCharacteristics(int event, var characteristicsModel, var writeModel)
    signal showAnnotation(var parameters)

    property int idEvent: -1
    property string event: ''
    property string desc: ''
    property string startDate: ''
    property string startTime: ''
    property string endDate: ''
    property string endTime: ''
    property string stateEvent: ''
    property int annotation: -1

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
        EditListItemInspector {
            id: annotationComponent
            width: eventEditor.width
            caption: qsTr('Anotació')

            onPerformSearch: annotationsModel.searchString = searchString
            onAddRow: eventEditor.showAnnotation({})
        }

        /*
        EditListItemInspector {
            id: projectComponent
            width: eventEditor.width
            caption: qsTr('Projecte')
        }
        */

        EditDeleteItemInspector {
            id: deleteButton
            width: eventEditor.width

            enableButton: eventEditor.idEvent != -1
            buttonCaption: qsTr('Esborrar esdeveniment')
            dialogTitle: buttonCaption
            dialogText: qsTr("Esborrareu l'esdeveniment. Voleu continuar?")

            model: scheduleModel
            itemId: eventEditor.idEvent
            onDeleted: closePage(qsTr("S'ha esborrat l'esdeveniment"))
        }
    }

    function ifUndefined(text,alternative) {
        return (typeof text === 'undefined')?alternative:text;
    }

    function ifEmpty(text,alternative) {
        return (text !== '')?text:alternative;
    }

    Component.onCompleted: {
        scheduleModel.select();

        console.log("ID event " + idEvent);
        if (eventEditor.idEvent != -1) {
            var details = scheduleModel.getObject('id',eventEditor.idEvent);

            eventEditor.event = ifUndefined(details.event,'');
            eventEditor.desc = ifUndefined(details.desc,'');

            startDate = ifUndefined(details.startDate,'');
            startTime = ifUndefined(details.startTime,'');
            endDate = ifUndefined(details.endDate,'');
            endTime = ifUndefined(details.endTime,'');

            stateComponent.originalContent = details.state;
            annotation = details.ref;
        }

        console.log('TERMINIS ' + [startDate,startTime,endDate,endTime].join('...'));

        titleComponent.originalContent = eventEditor.event;
        descComponent.originalContent = eventEditor.desc;

        startComponent.originalContent = {date: startDate, time: startTime};
        endComponent.originalContent = {date: endDate, time: endTime};

        annotationComponent.originalContent = {
            reference: annotation,
            valued: false,
            nameAttribute: 'title',
            model: annotationsModel
        }

        /*
        projectComponent.originalContent = {
            reference: reference,
            valued: false,
            nameAttribute: 'name',
            model: projectsModel
        }
        */

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
            ref: annotationComponent.editedContent['reference']
        }

        if (idCode == -1) {
            console.log('Totally new');
            object['created'] = Storage.currentTime();
            scheduleModel.insertObject(object);
        } else {
            object['id'] = idCode;
            if (scheduleModel.updateObject(object))
                console.log('Updated!');
            else
                console.log('Not updated');
        }
        annotationsModel.select();

        eventEditor.setChanges(false);
        eventEditor.savedEvent(object['title'],object['desc'],object['startDate'],object['startTime'],object['endDate'],object['endTime']);
    }

    function requestClose() {
        closeItem();
    }

    Models.AnnotationsModel {
        id: annotationsModel

        searchFields: ['title','desc','labels']
        Component.onCompleted: select()
    }

    Models.ScheduleModel {
        id: scheduleModel
    }
}
