import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import "qrc:///javascript/Storage.js" as Storage

CollectionInspector {
    id: assessmentDescriptorItem
    pageTitle: qsTr('Edita descriptor avaluat ***')

    property int assessment: -1
    property int individual: -1
    property string individualName: ''
    property string individualSurname: ''
    property int lastScoreId: -1
    property int newScoreId: -1
    property int descriptor: -1
    property int criterium: -1
    property string comment: ''
    property string group: ''

    property SqlTableModel lastScoresModel

    signal savedAssessmentDescriptor

    Common.UseUnits { id: units }

    function saveOrUpdate() {
        var res = false;
        var obj = {};
        obj['descriptor'] = descriptor;
        obj['comment'] = comment;
        obj['moment'] = Storage.currentTime();

        obj['assessment'] = assessment;
        obj['individual'] = individual;

        if (newScoreId === -1) {
            res = scoresModel.insertObject(obj);
            if (res !== '') {
                newScoreId = parseInt(res);
                lastScoresModel.select();
            }
        } else {
            obj['id'] = newScoreId;
            res = scoresModel.updateObject(obj,newScoreId);
            lastScoresModel.select();
        }

        return res;
    }

    Models.RubricsScoresModel {
        id: scoresModel

        Component.onCompleted: select()
    }

    Models.IndividualsModel {
        id: individualsModel
    }

    Models.RubricsLevelsDescriptorsModel {
        id: levelDescriptorsModel
        filters: [
            "criterium='" + criterium + "'"
        ]
        sort: 'score ASC'
    }

    Models.RubricsDetailedScoresModel {
        id: detailedScoresModel
        filters: [
            "assessment='" + assessment + "'",
            "criterium='" +  criterium + "'",
            "\"group\"='" + group + "'",
            "individual='" + individual + "'"
        ]
        sort: 'moment DESC'
    }

    Models.RubricsScoresModel {
        id: scoresSaveModel
    }

    model: ObjectModel {
        EditFakeItemInspector {
            id: assessmentComponent
            width: assessmentDescriptorItem.width
            totalCollectionHeight: assessmentDescriptorItem.totalCollectionHeight
            caption: qsTr('Avaluació')
            originalContent: assessment
        }
        EditFakeItemInspector {
            id: groupComponent
            width: assessmentDescriptorItem.width
            totalCollectionHeight: assessmentDescriptorItem.totalCollectionHeight
            caption: qsTr('Grup')
            originalContent: assessmentDescriptorItem.group
        }
        EditFakeItemInspector {
            id: individualComponent
            width: assessmentDescriptorItem.width
            totalCollectionHeight: assessmentDescriptorItem.totalCollectionHeight
            caption: qsTr('Individu')
            originalContent: individualName  + " " + individualSurname

        }
        CollectionInspectorItem {
            id: criteriumComponent
            width: assessmentDescriptorItem.width
            totalCollectionHeight: assessmentDescriptorItem.totalCollectionHeight
            caption: qsTr('Criteri')

            visorComponent: Item {
                id: criteriumVisor
                property int requiredHeight: childrenRect.height
                property var shownContent: ['','']
                Text {
                    id: criteriumTitle
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: contentHeight
                    font.bold: true
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: criteriumVisor.shownContent[0]
                }
                Text {
                    anchors {
                        top: criteriumTitle.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: units.nailUnit
                    }
                    height: contentHeight
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: criteriumVisor.shownContent[1]
                }
            }

            Connections {
                target: assessmentDescriptorItem
                onCriteriumChanged: {
                    levelDescriptorsModel.select();
                    var criteriumObject = levelDescriptorsModel.getObject('criterium',criterium);
                    criteriumComponent.originalContent = [];
                    criteriumComponent.push(criteriumObject['criteriumTitle']);
                    criteriumComponent.push(criteriumObject['criteriumDesc']);
                }
            }
        }

        EditListItemInspector {
            id: descriptorComponent
            width: assessmentDescriptorItem.width
            totalCollectionHeight: assessmentDescriptorItem.totalCollectionHeight
            caption: qsTr('Puntuació')
            originalContent: {
                'reference': descriptor,
                'valued': false,
                'model': levelDescriptorsModel,
                'nameAttribute': 'definition'
            }
            onSaveContents: {
                descriptor = originalContent.reference;
                var res = saveOrUpdate();
                if (res) {
                    notifySavedContents();
                    detailedScoresModel.select();
                }
            }
        }

        EditTextAreaInspector {
            id: commentsComponent
            width: assessmentDescriptorItem.width
            totalCollectionHeight: assessmentDescriptorItem.totalCollectionHeight
            caption: qsTr('Comentaris')
            originalContent: comment
            onSaveContents: {
                comment = originalContent;
                var res = saveOrUpdate();
                console.log('RES', res);
                if (res) {
                    notifySavedContents();
                    detailedScoresModel.select();
                }
            }
        }

        CollectionInspectorItem {
            id: previousComponent
            width: assessmentDescriptorItem.width
            totalCollectionHeight: assessmentDescriptorItem.totalCollectionHeight
            caption: qsTr('Històric')
            visorComponent: previousValues
            originalContent: detailedScoresModel
        }
    }

    Component {
        id: previousValues

        ListView {
            id: list
            property int requiredHeight: Math.max(contentItem.height, units.fingerUnit * 2)
            property alias shownContent: list.model
            interactive: false

            highlight: Rectangle {
                width: list.width
                height: units.fingerUnit * 2
                color: 'yellow'
            }

            highlightFollowsCurrentItem: true

            delegate: Rectangle {
                border.color: 'black'
                color: 'transparent'
                height: units.fingerUnit * 2
                width: list.width
                RowLayout {
                    anchors.fill: parent
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        clip: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: model.moment
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 4
                        clip: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: model.definition
                    }
                    Text {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: units.readUnit
                        text: model.comment
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onPressAndHold: {
                        list.currentIndex = model.index;
                        restoreValues.newDescriptor = model.descriptor;
                        restoreValues.newComment = model.comment;
                        restoreValues.open();
                    }
                }
            }
        }
    }

    Component.onCompleted: {
//        scoresModel.select();

        individualsModel.select();

        var individualObject = individualsModel.getObject(individual);

        assessmentDescriptorItem.group = individualObject['group'];
        assessmentDescriptorItem.individualName = individualObject['name'];
        assessmentDescriptorItem.individualSurname = individualObject['surname'];

        console.log('Last scoreId ' + lastScoreId);

        detailedScoresModel.select();

        var obj2 = detailedScoresModel.getObject('scoreId',lastScoreId);
        assessmentDescriptorItem.descriptor = obj2['descriptor'];

        comment = (typeof obj2['comment'] !== 'undefined')?obj2['comment']:'';
    }

    onSaveDataRequested: {
        var object = {
        }
        //dataBck.createTable('rubrics_scores','id INTEGER PRIMARY KEY, assessment INTEGER, descriptor INTEGER, moment TEXT, individual INTEGER, comment TEXT');

        scoresSaveModel.insertObject(object);
        scoresModel.select();
        setChanges(false);
        savedAssessmentDescriptor();
    }

    MessageDialog {
        id: restoreValues

        property int newDescriptor: -1
        property string newComment: ''

        title: qsTr('Restaura valors')
        text: qsTr('Vols restaurar aquests valors? Encara podràs modificar-los després')
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: {
            descriptorComponent.originalContent = {
                reference: newDescriptor,
                valued: false,
                model: levelDescriptorsModel,
                nameAttribute: 'definition'
            };
            commentsComponent.originalContent = newComment;
        }
        onNo: restoreValues.close()
    }

    onCopyDataRequested: {}
    onDiscardDataRequested: {}
    onClosePageRequested: {}
}
