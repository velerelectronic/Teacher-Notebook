import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models

BasicPage {
    id: rubricAssessmentEditorBasicPage

    pageTitle: qsTr('Edita avaluació de rúbrica')

    property int idAssessment: -1
    property int rubric: -1
    property string group: ''
    property int event: -1
    property string annotation: ''
    property SqlTableModel rubricsAssessmentModel

    signal savedRubricAssessment
    signal showEvent(var parameters)

    mainPage: CollectionInspector {
        id: rubricAssessmentEditor

        property string title: ''
        property string desc: ''

        Common.UseUnits { id: units }

        function saveOrUpdate() {
            var res = false;
            var obj = {};
            obj = {
                title: titleComponent.editedContent,
                desc: descComponent.editedContent,
                rubric: rubricComponent.editedContent.reference,
                group: groupComponent.editedContent.reference,
                annotation: annotationComponent.editedContent
            };

            if (idAssessment == -1) {
                res = rubricsAssessmentModel.insertObject(obj);
                if (res !== '') {
                    idAssessment = res;
                    rubricsAssessmentModel.select();
                }
            } else {
                obj['id'] = idAssessment;
                res = rubricsAssessmentModel.updateObject(obj);
                rubricsAssessmentModel.select();
            }
            return res;
        }


        model: ObjectModel {
            EditTextItemInspector {
                id: titleComponent
                width: rubricAssessmentEditor.width
                totalCollectionHeight: rubricAssessmentEditor.totalCollectionHeight
                caption: qsTr('Títol')
                originalContent: rubricAssessmentEditor.title
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            EditTextAreaInspector {
                id: descComponent
                width: rubricAssessmentEditor.width
                totalCollectionHeight: rubricAssessmentEditor.totalCollectionHeight
                caption: qsTr('Descripció')
                originalContent: rubricAssessmentEditor.desc
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            EditListItemInspector {
                id: rubricComponent
                width: rubricAssessmentEditor.width
                totalCollectionHeight: rubricAssessmentEditor.totalCollectionHeight
                caption: qsTr('Rúbrica')

                originalContent: {
                    'reference': rubricAssessmentEditorBasicPage.rubric,
                    'valued': false,
                    'model': rubricsModel,
                    'nameAttribute': 'title'
                }

                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            EditListItemInspector {
                id: groupComponent
                width: rubricAssessmentEditor.width
                totalCollectionHeight: rubricAssessmentEditor.totalCollectionHeight
                caption: qsTr('Grup')
                originalContent: {
                    'reference': group,
                    'value': group,
                    'valued': true,
                    'model': groupsModel,
                    'nameAttribute': 'group'
                }

                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            CollectionInspectorItem {
                id: annotationComponent
                width: rubricAssessmentEditor.width
                totalCollectionHeight: rubricAssessmentEditor.totalCollectionHeight
                caption: qsTr('Anotació')
                originalContent: annotation

                visorComponent: Text {
                    property string shownContent: ''
                    property int requiredHeight: Math.max(units.fingerUnit, contentHeight)

                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: units.readUnit

                    text: shownContent
                }

                editorComponent: ExtendedAnnotationsList {
                    property string editedContent: ''
                    property int requiredHeight: units.fingerUnit * 10

                    chooseMode: true
                    onChosenAnnotation: editedContent = annotation
                }

                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
        }

        Component.onCompleted: {
            groupsModel.select();
            rubricsModel.select();
            eventsModel.select();

            if (idAssessment !== -1) {
                var obj = rubricsAssessmentModel.getObject(idAssessment);
                rubricAssessmentEditor.title = obj['title'];
                rubricAssessmentEditor.desc = obj['desc'];
                rubric = obj['rubric'];
                group = obj['group'];
                annotation = obj['annotation'];
            }
        }

        onCopyDataRequested: {}
        onDiscardDataRequested: {}
        onClosePageRequested: {}

        SqlTableModel {
            id: groupsModel
            tableName: 'individuals_groups'
            fieldNames: ['group']
            primaryKey: 'id'
        }

        Models.RubricsModel {
            id: rubricsModel
        }

        Models.ScheduleModel {
            id: eventsModel

            filters: ["ifnull(state,'') != 'done'"]
            searchFields: ['event','desc']
            limit: 20
        }
    }

}

