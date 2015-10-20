import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common

BasicPage {
    id: rubricDetailsBasicPage

    property int idRubric: -1
    property SqlTableModel rubricsModel

    pageTitle: qsTr('Edita detalls de rúbrica')

    mainPage: CollectionInspector {
        id: rubricDetailsItem


        property string title: ''
        property string desc: ''

        signal savedRubricDetails

        function saveOrUpdate() {
            var res = false;
            var obj = {
                title: rubricTitle.editedContent,
                desc: rubricDesc.editedContent
            };

            if (idRubric == -1) {
                res = rubricsModel.insertObject(obj);
                if (res !== '') {
                    idRubric = res;
                }
            } else {
                obj['id'] = idRubric;
                res = rubricsModel.updateObject(obj);
            }
            rubricsModel.select();
            return res;
        }

        model: ObjectModel {
            EditTextItemInspector {
                id: rubricTitle
                width: rubricDetailsItem.width
                caption: qsTr('Títol')
                originalContent: rubricDetailsItem.title
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            EditTextAreaInspector {
                id: rubricDesc
                width: rubricDetailsItem.width
                caption: qsTr('Descripció')
                originalContent: rubricDetailsItem.desc
                onSaveContents: {
                    if (saveOrUpdate())
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
    }

}
