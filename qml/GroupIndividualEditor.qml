import QtQuick 2.3
import QtQml.Models 2.1
import PersonalTypes 1.0

import 'qrc:///models' as Models

BasicPage {
    id: groupIndividualEditor

    pageTitle: qsTr("Editor d'individus i grups")

    property int identifier: -1
    property string group: ''

    mainPage: CollectionInspector {
        id: innerInspector

        Models.IndividualsModel {
            id: groupsIndividualsModel
        }

        signal savedGroupIndividual

        function saveOrUpdate() {
            var object = {
                name: nameComponent.originalContent,
                surname: surnameComponent.originalContent,
                group: groupComponent.originalContent
            }

            var res;
            if (groupIndividualEditor.identifier == -1) {
                res = groupsIndividualsModel.insertObject(object);
                groupIndividualEditor.identifier = res;
            } else {
                object['id'] = groupIndividualEditor.identifier;
                res = groupsIndividualsModel.updateObject(groupIndividualEditor.identifier, object);
            }
            if (res)
                groupsIndividualsModel.select();
            savedGroupIndividual();

            return res;
        }

        model: ObjectModel {
            EditTextItemInspector {
                id: nameComponent
                width: groupIndividualEditor.width
                totalCollectionHeight: groupIndividualEditor.height
                caption: qsTr('Nom')
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            EditTextItemInspector {
                id: surnameComponent
                width: groupIndividualEditor.width
                totalCollectionHeight: groupIndividualEditor.height
                caption: qsTr('Llinatges')
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
            EditTextItemInspector {
                id: groupComponent
                width: groupIndividualEditor.width
                totalCollectionHeight: groupIndividualEditor.height
                caption: qsTr('Grup')
                onSaveContents: {
                    if (saveOrUpdate())
                        notifySavedContents();
                }
            }
        }

        Connections {
            target: groupIndividualEditor
            onIdentifierChanged: innerInspector.fillValues()
        }

        function fillValues () {
            console.log('identifier', groupIndividualEditor.identifier);
            if (groupIndividualEditor.identifier >= 0) {
                var obj = groupsIndividualsModel.getObject(groupIndividualEditor.identifier);
                nameComponent.originalContent = obj['name'];
                surnameComponent.originalContent = obj['surname'];
                groupComponent.originalContent = obj['group'];
            }
        }

        Component.onCompleted: fillValues()
    }
}

