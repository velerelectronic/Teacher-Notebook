import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import "qrc:///javascript/Storage.js" as Storage

CollectionInspector {
    id: assessmentDescriptorItem
    pageTitle: qsTr('Edita descriptor avaluat ***')

    property int assessment: -1
    property int individual: -1
    property int lastScoreId: -1
    property int descriptor: -1
    property int criterium: -1
    property string comment: ''

    property SqlTableModel scoresSaveModel
    property SqlTableModel scoresModel
    property SqlTableModel levelDescriptorsModel
    property SqlTableModel individualsModel
    property SqlTableModel lastScoresModel

    signal savedAssessmentDescriptor

    Common.UseUnits { id: units }

    model: ObjectModel {
        EditFakeItemInspector {
            id: assessmentComponent
            width: assessmentDescriptorItem.width
            caption: qsTr('Avaluació')
            originalContent: assessment
        }
        EditFakeItemInspector {
            id: groupComponent
            width: assessmentDescriptorItem.width
            caption: qsTr('Grup')
        }
        EditFakeItemInspector {
            id: individualComponent
            width: assessmentDescriptorItem.width
            caption: qsTr('Individu')
        }
        CollectionInspectorItem {
            id: criteriumComponent
            width: assessmentDescriptorItem.width
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
        }

        EditListItemInspector {
            id: descriptorComponent
            width: assessmentDescriptorItem.width
            caption: qsTr('Puntuació')
        }

        EditTextAreaInspector {
            id: commentsComponent
            width: assessmentDescriptorItem.width
            caption: qsTr('Comentaris')
        }

        CollectionInspectorItem {
            id: previousComponent
            width: assessmentDescriptorItem.width
            caption: qsTr('Històric')
            visorComponent: previousValues
            originalContent: scoresModel
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

        var individualObject = individualsModel.getObject(individual);

        groupComponent.originalContent = individualObject['group'];
        individualComponent.originalContent = individualObject['name'] + " " + individualObject['surname'];

        var criteriumObject = levelDescriptorsModel.getObject('criterium',criterium);
        criteriumComponent.originalContent = [criteriumObject['criteriumTitle'],criteriumObject['criteriumDesc']];

        console.log('Last scoreId ' + lastScoreId);
        var obj2 = scoresModel.getObject('scoreId',lastScoreId);

        console.log('obj2 [ "descriptor" ]: ' + obj2['descriptor'] );

        descriptorComponent.originalContent = {
            reference: obj2['descriptor'],
            valued: false,
            model: levelDescriptorsModel,
            nameAttribute: 'definition'
        }

        commentsComponent.originalContent = (typeof obj2['comment'] !== 'undefined')?obj2['comment']:'';
    }

    onSaveDataRequested: {
        var object = {
            assessment: assessmentComponent.originalContent,
            individual: individual,
            descriptor: descriptorComponent.editedContent.reference,
            comment: commentsComponent.editedContent,
            moment: Storage.currentTime()
        }
        //dataBck.createTable('rubrics_scores','id INTEGER PRIMARY KEY, assessment INTEGER, descriptor INTEGER, moment TEXT, individual INTEGER, comment TEXT');

        scoresSaveModel.insertObject(object);
        scoresModel.select();
        lastScoresModel.select();
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
