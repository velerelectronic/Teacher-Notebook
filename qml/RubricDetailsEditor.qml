import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

BasicPage {
    id: rubricDetailsBasicPage

    property int idRubric: -1

    mainPage: CollectionInspector {
        id: rubricDetailsItem

        pageTitle: qsTr('Edita detalls de rúbrica')

        property string title: ''
        property string desc: ''
        property SqlTableModel rubricsModel

        signal savedRubricDetails

        function saveOrUpdate(field, contents) {
            var res = false;
            var obj = {};
            obj[field] = contents;

            if (idRubric == -1) {
                res = rubricsModel.insertObject(obj);
                console.log('Resultat', res);
                if (res !== '') {
                    idRubric = res;
                }
            } else {
                obj['id'] = idRubric;
                res = rubricsModel.updateObject(obj);
            }
            return res;
        }

        model: ObjectModel {
            EditTextItemInspector {
                id: rubricTitle
                width: rubricDetailsItem.width
                caption: qsTr('Títol')
                originalContent: rubricDetailsItem.title
                onSaveContents: {
                    if (saveOrUpdate('title',editedContent))
                        notifySavedContents();
                }
            }
            EditTextAreaInspector {
                id: rubricDesc
                width: rubricDetailsItem.width
                caption: qsTr('Descripció')
                originalContent: rubricDetailsItem.desc
                onSaveContents: {
                    if (saveOrUpdate('desc',editedContent))
                        notifySavedContents();
                }
            }
        }

        Component.onCompleted: {
            if (idRubric !== -1) {
                var obj = rubricsModel.getObject(idRubric);

                rubricDetailsItem.title = obj['title'];
                rubricDetailsItem.desc = obj['desc'];
            }
        }


        onCopyDataRequested: {}
        onClosePageRequested: {}
    }

}
