import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

BasicPage {
    id: rubricCriteriumItem
    pageTitle: qsTr('Edita criteri de rúbrica')

    property int idCriterium: -1
    property int rubric
    property string title: ''
    property string desc: ''
    property int ord: -1
    property int weight: 1
    property SqlTableModel criteriaModel

    mainPage: CollectionInspector {
        signal savedCriterium

        function saveOrUpdate() {
            var object = {
                rubric: rubric,
                title: titleComponent.editedContent,
                desc: descComponent.editedContent,
                ord: orderComponent.editedContent,
                weight: weightComponent.editedContent
            }

            var res;
            if (idCriterium == -1) {
                res = criteriaModel.insertObject(object);
                idCriterium = res;
            } else {
                object['id'] = idCriterium;
                res = criteriaModel.updateObject(object);
            }
            if (res)
                criteriaModel.select();
            return res;
        }

        model: ObjectModel {
            EditFakeItemInspector {
                id: rubricComponent
                width: rubricCriteriumItem.width
                totalCollectionHeight: rubricCriteriumItem.totalCollectionHeight
                caption: qsTr('Rúbrica')
            }
            EditTextItemInspector {
                id: titleComponent
                width: rubricCriteriumItem.width
                totalCollectionHeight: rubricCriteriumItem.totalCollectionHeight
                caption: qsTr('Títol')
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            EditTextAreaInspector {
                id: descComponent
                width: rubricCriteriumItem.width
                totalCollectionHeight: rubricCriteriumItem.totalCollectionHeight
                caption: qsTr('Descripció')
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            EditTextItemInspector {
                id: orderComponent
                width: rubricCriteriumItem.width
                totalCollectionHeight: rubricCriteriumItem.totalCollectionHeight
                caption: qsTr('Ordre')
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            EditTextItemInspector {
                id: weightComponent
                width: rubricCriteriumItem.width
                totalCollectionHeight: rubricCriteriumItem.totalCollectionHeight
                caption: qsTr('Pes')
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
        }

        Component.onCompleted: {
            rubricsModel.select();
            var rubricObj = rubricsModel.getObject(rubric);
            rubricComponent.originalContent = rubricObj['title'] + ((rubricObj['desc'] !== '')?'\n' + rubricObj['desc']:'');
            if (idCriterium !== -1) {
                var obj = criteriaModel.getObject(idCriterium);
                titleComponent.originalContent = obj['title'];
                descComponent.originalContent = obj['desc'];
                orderComponent.originalContent = obj['ord'];
                weightComponent.originalContent = obj['weight'];
            }
        }

        onSaveDataRequested: {
            var object = {
                rubric: rubricCriteriumItem.rubric,
                title: titleComponent.editedContent,
                desc: descComponent.editedContent,
                ord: orderComponent.editedContent,
                weight: weightComponent.editedContent
            }

            if (idCriterium == -1) {
                criteriaModel.insertObject(object);
            } else {
                object['id'] = idCriterium;
                if (criteriaModel.updateObject(object))
                    console.log('DONE');
                else
                    console.log('NOT Done');
            }
            rubricCriteriumItem.setChanges(false);
            rubricCriteriumItem.savedCriterium();
        }

        Models.RubricsModel {
            id: rubricsModel
        }

        onCopyDataRequested: {}
        onDiscardDataRequested: {}
        onClosePageRequested: {}
    }
}

