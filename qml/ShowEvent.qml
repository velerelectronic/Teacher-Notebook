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

    onCopyDataRequested: {
        prepareDataAndSave(-1);
    }

    onClosePageRequested: closePage('')

    function saveOrUpdate(field, contents) {
        var res = false;
        var obj = {};
        obj[field] = contents;

        if (idEvent == -1) {
            obj['created'] = Storage.currentTime();
            res = scheduleModel.insertObject(obj);
            console.log('Resultat', res);
            if (res !== '') {
                idEvent = res;
            }
        } else {
            obj['id'] = idEvent;
            res = scheduleModel.updateObject(obj);
        }
        return res;
    }

    function saveOrUpdate2(field1, contents1, field2, contents2) {
        var res = false;
        var obj = {};
        obj[field1] = contents1;
        obj[field2] = contents2;

        if (idEvent == -1) {
            obj['created'] = Storage.currentTime();
            res = scheduleModel.insertObject(obj);
        } else {
            obj['id'] = idEvent;
            res = scheduleModel.updateObject(obj);
        }
        return res;
    }

    model: ObjectModel {
        EditTextItemInspector {
            id: titleComponent
            width: eventEditor.width
            caption: qsTr('Esdeveniment')
            onSaveContents: {
                if (saveOrUpdate('event',editedContent))
                    notifySavedContents();
            }
        }
        EditStateItemInspector {
            id: stateComponent
            width: eventEditor.width
            caption: qsTr('Estat')
            onSaveContents: {
                if (saveOrUpdate('state',editedContent))
                    notifySavedContents();
            }
        }
        EditTextAreaInspector {
            id: descComponent
            width: eventEditor.width
            caption: qsTr('Descripció')
            onSaveContents: {
                if (saveOrUpdate('desc',editedContent))
                    notifySavedContents();
            }
        }
        EditDateTimeItemInspector {
            id: startComponent
            width: eventEditor.width
            caption: qsTr('Inici')
            onSaveContents: {
                if (saveOrUpdate2('startDate',editedContent['date'],'startTime',editedContent['time']))
                    notifySavedContents();
            }
        }
        EditDateTimeItemInspector {
            id: endComponent
            width: eventEditor.width
            caption: qsTr('Final')
            onSaveContents: {
                if (saveOrUpdate2('endDate',editedContent['date'],'endTime',editedContent['time']))
                    notifySavedContents();
            }
        }
        EditListItemInspector {
            id: annotationComponent
            width: eventEditor.width
            caption: qsTr('Anotació')

            onPerformSearch: annotationsModel.searchString = searchString
            onAddRow: eventEditor.showAnnotation({})
            onSaveContents: {
                if (saveOrUpdate('ref',editedContent.reference))
                    notifySavedContents();
            }
        }

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

        if (eventEditor.idEvent != -1) {
            var details = scheduleModel.getObject('id',eventEditor.idEvent);

            eventEditor.event = ifUndefined(details.event,'');
            eventEditor.desc = ifUndefined(details.desc,'');

            startDate = ifUndefined(details.startDate,'');
            startTime = ifUndefined(details.startTime,'');
            endDate = ifUndefined(details.endDate,'');
            endTime = ifUndefined(details.endTime,'');

            stateComponent.originalContent = details.state;
            annotation = parseInt(details.ref);
        }

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

        // Reinit changes
        eventEditor.setChanges(false);
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
