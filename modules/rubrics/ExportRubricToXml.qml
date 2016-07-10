import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQml.StateMachine 1.0 as DSM
import QtQml.Models 2.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/files' as Files
import 'qrc:///editors' as Editors

import RubricXml 1.0

Common.SteppedPage {
    property int assessment
    property string assessmentTitle: ''
    property string assessmentDescription: ''
    property int assessmentRubric
    property string assessmentGroup: ''
    property string assessmentAnnotation: ''
    property string assessmentStart: ''
    property string assessmentEnd: ''

    RubricXml {
        id: rubricExport
    }

    Common.UseUnits {
        id: units
    }

    Models.RubricsAssessmentModel {
        id: assessmentModel
    }

    Models.RubricsCriteriaModel {
        id: criteriaModel

        filters: ['rubric=?']
    }

    Models.RubricsLevelsDescriptorsModel {
        id: generalLevelsAndDescriptorsModel
        filters: ['criterium=?']
    }

    Models.RubricsLevelsModel {
        id: levelsOnlyModel
        filters: ['rubric=?']
    }

    Models.ExtendedAnnotations {
        id: annotationsModel
    }

    Models.RubricsDetailedScoresModel {
        id: detailedScoresModel

        filters: ['assessment=?']
    }

    Models.RubricsScoresModel {
        id: simpleScoresModel

        filters: ['assessment=?']
    }

    Models.IndividualsModel {
        id: individualsModel

        filters: ["\"group\"=?"]
    }

    sections: ObjectModel {
        ListView {
            id: itemsList

            spacing: units.fingerUnit
            model: ObjectModel {
                Common.BoxedText {
                    width: itemsList.width
                    height: Math.max(units.fingerUnit, contentHeight)
                    border.color: 'black'
                    boldFont: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Avaluació de rúbrica')
                }
                Item {
                    width: itemsList.width
                    height: childrenRect.height
                    ColumnLayout {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        spacing: units.nailUnit

                        Text {
                            Layout.fillWidth: true
                            height: Math.max(units.fingerUnit, contentHeight)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: '<b>' + qsTr('Títol') + ':</b>&nbsp;' + assessmentTitle
                        }
                        Text {
                            Layout.fillWidth: true
                            height: Math.max(units.fingerUnit, contentHeight)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: '<b>' + qsTr('Descripció') + ':</b>&nbsp;' + assessmentDescription
                        }
                        Text {
                            Layout.fillWidth: true
                            height: Math.max(units.fingerUnit, contentHeight)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: '<b>' + qsTr('Rúbrica') + ':</b>&nbsp;' + assessmentRubric
                        }
                        Text {
                            Layout.fillWidth: true
                            height: Math.max(units.fingerUnit, contentHeight)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: '<b>' + qsTr('Grup') + ':</b>&nbsp;' + assessmentGroup
                        }
                        Text {
                            Layout.fillWidth: true
                            height: Math.max(units.fingerUnit, contentHeight)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: '<b>' + qsTr('Anotació') + ':</b>&nbsp;' + assessmentAnnotation
                        }
                        Text {
                            Layout.fillWidth: true
                            height: Math.max(units.fingerUnit, contentHeight)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: '<b>' + qsTr('Avaluació') + ':</b>&nbsp;' + assessment
                        }
                        Text {
                            Layout.fillWidth: true
                            height: Math.max(units.fingerUnit, contentHeight)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: '<b>' + qsTr('Inci') + ':</b>&nbsp;' + assessmentStart
                        }
                        Text {
                            Layout.fillWidth: true
                            height: Math.max(units.fingerUnit, contentHeight)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: '<b>' + qsTr('Final') + ':</b>&nbsp;' + assessmentEnd
                        }
                    }
                }

                Common.BoxedText {
                    width: itemsList.width
                    height: Math.max(units.fingerUnit, contentHeight)
                    border.color: 'black'
                    boldFont: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Criteris i descriptors')
                }
                ListView {
                    id: criteriaList
                    width: itemsList.width
                    height: contentItem.height

                    model: criteriaModel
                    leftMargin: units.fingerUnit
                    rightMargin: units.fingerUnit
                    interactive: false

                    spacing: units.nailUnit

                    delegate: Rectangle {
                        id: singleCriteriumRect

                        width: criteriaList.width - criteriaList.leftMargin - criteriaList.rightMargin
                        height: childrenRect.height + units.nailUnit * 2

                        property int criterium: model.id

                        border.color: 'black'
                        ColumnLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: units.nailUnit
                            }
                            spacing: 0
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(units.fingerUnit, criteriumIdText.contentHeight, criteriumTitleText.contentHeight, criteriumOrdText.contentHeight, criteriumWeightText.contentHeight) + 2 * units.nailUnit
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: units.nailUnit
                                    Text {
                                        id: criteriumIdText
                                        Layout.preferredWidth: parent.width / 5
                                        Layout.fillHeight: true
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: qsTr('Identificador ') + model.id
                                    }
                                    Text {
                                        id: criteriumTitleText
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: "<p><b>" + model.title + "</b></p><p>" + model.desc + "</p>"
                                    }
                                    Text {
                                        id: criteriumOrdText
                                        Layout.preferredWidth: parent.width / 5
                                        Layout.fillHeight: true
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: qsTr('Ordre ') + model.ord
                                    }
                                    Text {
                                        id: criteriumWeightText
                                        Layout.preferredWidth: parent.width / 5
                                        Layout.fillHeight: true
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: qsTr('Pes ') + model.weight
                                    }
                                }
                            }
                            ListView {
                                id: descriptorsList
                                Layout.fillWidth: true
                                Layout.preferredHeight: contentItem.height

                                leftMargin: units.fingerUnit
                                rightMargin: units.fingerUnit

                                interactive: false
                                model: levelsAndDescriptorsModel

                                header: Rectangle {
                                    width: descriptorsList.width - descriptorsList.leftMargin - descriptorsList.rightMargin
                                    height: units.fingerUnit
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: units.nailUnit
                                        Text {
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width / 6
                                            font.pixelSize: units.readUnit
                                            font.bold: true
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: qsTr('Descriptor')
                                        }
                                        Text {
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width / 6
                                            font.pixelSize: units.readUnit
                                            font.bold: true
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: qsTr('Definició')
                                        }
                                        Text {
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width / 6
                                            font.pixelSize: units.readUnit
                                            font.bold: true
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: qsTr('Nivell')
                                        }
                                        Text {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            font.pixelSize: units.readUnit
                                            font.bold: true
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: qsTr('Títol i descripció')
                                        }
                                        Text {
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width / 6
                                            font.pixelSize: units.readUnit
                                            font.bold: true
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: qsTr('Puntuació')
                                        }
                                    }
                                }

                                delegate: Rectangle {
                                    width: descriptorsList.width - descriptorsList.leftMargin - descriptorsList.rightMargin
                                    height: Math.max(units.fingerUnit, descriptorText.contentHeight, levelText.contentHeight, definitionText.contentHeight, descriptorTitleText.contentHeight, scoreText.contentHeight) + units.nailUnit * 2
                                    border.color: 'black'
                                    color: '#FFECA9'
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: units.nailUnit
                                        Text {
                                            id: descriptorText
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width / 6
                                            font.pixelSize: units.readUnit
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: model.descriptor
                                        }
                                        Text {
                                            id: definitionText
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width / 6
                                            font.pixelSize: units.readUnit
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: model.definition
                                        }
                                        Text {
                                            id: levelText
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width / 6
                                            font.pixelSize: units.readUnit
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: model.level
                                        }
                                        Text {
                                            id: descriptorTitleText
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            font.pixelSize: units.readUnit
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: "<p><b>" + model.title + "</b></p><p>" + model.desc + "</p>"
                                        }
                                        Text {
                                            id: scoreText
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width / 6
                                            font.pixelSize: units.readUnit
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                            text: model.score
                                        }
                                    }
                                }

                                Models.RubricsLevelsDescriptorsModel {
                                    id: levelsAndDescriptorsModel
                                    filters: ['criterium=?']
                                }

                                Component.onCompleted: {
                                    levelsAndDescriptorsModel.bindValues = [singleCriteriumRect.criterium];
                                    levelsAndDescriptorsModel.select();
                                }
                            }
                        }

                    }
                }

                Common.BoxedText {
                    width: itemsList.width
                    height: Math.max(units.fingerUnit, contentHeight)
                    border.color: 'black'
                    boldFont: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Nivells')
                }

                ListView {
                    id: levelsList
                    width: itemsList.width
                    height: contentItem.height

                    leftMargin: units.fingerUnit
                    rightMargin: units.fingerUnit

                    interactive: false
                    model: levelsOnlyModel

                    header: Rectangle {
                        width: levelsList.width - levelsList.leftMargin - levelsList.rightMargin
                        height: units.fingerUnit
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 5
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Nivell')
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 5
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Títol')
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Descripció')
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 5
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Puntuació')
                            }
                        }
                    }

                    delegate: Rectangle {
                        width: levelsList.width - levelsList.leftMargin - levelsList.rightMargin
                        height: Math.max(units.fingerUnit, levelIdText.contentHeight, levelTitleText.contentHeight, levelDescText.contentHeight, levelScoreText.contentHeight) + 2*units.nailUnit
                        border.color: 'black'
                        color: '#C4FFA9'
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            Text {
                                id: levelIdText
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 5
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.id
                            }
                            Text {
                                id: levelTitleText
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 5
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.title
                            }
                            Text {
                                id: levelDescText
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.desc
                            }
                            Text {
                                id: levelScoreText
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width / 5
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.score
                            }
                        }
                    }
                }

                Common.BoxedText {
                    width: itemsList.width
                    height: Math.max(units.fingerUnit, contentHeight)
                    border.color: 'black'
                    boldFont: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Individus avaluables')
                }

                ListView {
                    id: individualsList
                    width: itemsList.width
                    height: contentItem.height

                    interactive: false
                    model: individualsModel

                    property int availableWidth: width - leftMargin - rightMargin

                    header: Rectangle {
                        width: individualsList.availableWidth
                        height: units.fingerUnit

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            Text {
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Id')
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Nom')
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Llinatges')
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Grup')
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: qsTr('Image de cara')
                            }
                        }
                    }

                    delegate: Rectangle {
                        width: individualsList.availableWidth
                        height: Math.max(units.fingerUnit, individualsIdText.contentHeight, individualsNameText.contentHeight, individualsSurnameText.contentHeight, individualsGroupText.contentHeight, individualsFaceImageText.contentHeight)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            Text {
                                id: individualsIdText
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.id
                            }
                            Text {
                                id: individualsNameText
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.name
                            }
                            Text {
                                id: individualsSurnameText
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.surname
                            }
                            Text {
                                id: individualsGroupText
                                Layout.preferredWidth: parent.width / 5
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.group
                            }
                            Text {
                                id: individualsFaceImageText
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.faceImage
                            }
                        }
                    }
                }

                Common.BoxedText {
                    width: itemsList.width
                    height: units.fingerUnit
                    border.color: 'black'
                    boldFont: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Qualificacions')
                }
                ListView {
                    id: scoresList
                    width: itemsList.width
                    height: contentItem.height

                    interactive: false
                    model: detailedScoresModel

                    header: Rectangle {
                        width: scoresList.width - scoresList.leftMargin - scoresList.rightMargin
                        height: units.fingerUnit

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            Text {
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.bold: true
                                text: qsTr('Descriptor')
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.bold: true
                                text: qsTr('Moment')
                            }
                            Text {
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.bold: true
                                text: qsTr('Individu')
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                font.bold: true
                                text: qsTr('Comentari')
                            }
                        }
                    }

                    delegate: Rectangle {
                        width: scoresList.width - scoresList.leftMargin - scoresList.rightMargin
                        height: Math.max(units.fingerUnit, scoresDescriptorText.contentHeight, scoresMomentText.contentHeight, scoresIndividualText.contentHeight, scoresCommentText.contentHeight) + 2 * units.nailUnit

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit

                            Text {
                                id: scoresDescriptorText
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.descriptor
                            }
                            Text {
                                id: scoresMomentText
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.moment
                            }
                            Text {
                                id: scoresIndividualText
                                Layout.preferredWidth: parent.width / 4
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.individual
                            }
                            Text {
                                id: scoresCommentText
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                font.pixelSize: units.readUnit
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.comment
                            }
                        }
                    }
                }
                Common.BoxedText {
                    width: itemsList.width
                    height: Math.max(units.fingerUnit, contentHeight)
                    border.color: 'black'
                    boldFont: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Exportació a XML')
                }
                Text {
                    id: xmlText
                    width: itemsList.width
                    height: contentHeight
                    textFormat: Text.PlainText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: rubricExport.xml;
                }
                Rectangle {
                    width: itemsList.width
                    height: units.nailUnit
                    color: 'black'
                }
            }
        }

        Files.FileSelector {
            selectDirectory: true

            onFolderSelected: {
                folderText.text = folder;
                moveForward();
            }
        }

        Rectangle {
            ColumnLayout {
                anchors.fill: parent
                spacing: units.nailUnit

                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    font.pixelSize: units.readUnit
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr('Ubicació')
                }
                Text {
                    id: folderText
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    font.pixelSize: units.readUnit
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit
                    font.pixelSize: units.readUnit
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: qsTr("Nom de l'arxiu")
                }
                Editors.TextLineEditor {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
/*
        */

    }


    function addLineToString(str, suffix) {
        return str + "\n" + suffix;
    }

    Component.onCompleted: {
        // Basic info for the rubric
        assessmentModel.select();
        var obj = assessmentModel.getObject('id', assessment);
        assessmentTitle = obj['title'];
        assessmentDescription = obj['desc'];
        assessmentRubric = obj['rubric'];
        assessmentGroup = obj['group'];
        assessmentAnnotation = obj['annotation'];

        annotationsModel.select();

        // Basic rubric info
        var annotationObj = annotationsModel.getObject('title', assessmentAnnotation);
        assessmentStart = annotationObj['start'];
        assessmentEnd = annotationObj['end'];

        rubricExport.createEmptyRubric();
        rubricExport.title = assessmentTitle;
        rubricExport.description = assessmentDescription + '. Source: rubric id ' + assessmentRubric + ' assessment id ' + assessment + ', annotation ' + assessmentAnnotation

        // Insert criteria
        criteriaModel.bindValues = [assessmentRubric];
        criteriaModel.select();

        for (var i=0; i<criteriaModel.count; i++) {
            // A single criterium
            var criteriumObj = criteriaModel.getObjectInRow(i);
            var newCriteriumObj = {
                identifier: criteriumObj['id'],
                title: criteriumObj['title'],
                description: criteriumObj['desc'],
                weight: criteriumObj['weight'],
                order: criteriumObj['ord']
            }
            rubricExport.criteria.append(newCriteriumObj);

            // Insert descriptors for the current criterium
            generalLevelsAndDescriptorsModel.bindValues = [criteriumObj['id']];
            generalLevelsAndDescriptorsModel.select();

            for (var j=0; j<generalLevelsAndDescriptorsModel.count; j++) {
                var descriptorObj = generalLevelsAndDescriptorsModel.getObjectInRow(j);
                var newDescriptorObj = {
                    // The new identifier collects the descriptor id and the definition as a string
                    identifier: descriptorObj['descriptor'] + ":" + descriptorObj['definition'],
                    level: descriptorObj['level'],
                    title: descriptorObj['title'],
                    description: descriptorObj['desc'],
                    score: descriptorObj['score']
                }
                rubricExport.criteria.descriptors(i).append(newDescriptorObj);
            }
        }

        // Individuals in the group

        individualsModel.bindValues = [assessmentGroup];
        individualsModel.select();

        for (var i=0; i<individualsModel.count; i++) {
            var indivObj = individualsModel.getObjectInRow(i);
            // The individual identifier consists of: the original id, name and surname, separated by blankspaces
            var newIndivObj = {
                identifier: indivObj['id'] + ' ' + indivObj['name'] + ' ' + indivObj['surname'],
                group: indivObj['group'],
                name: indivObj['name'],
                surname: indivObj['surname'],
                faceImage: indivObj['faceImage']
            }

            rubricExport.population.append(newIndivObj);
        }

        // Prepare assessment

        rubricExport.assessment.periodStart = assessmentStart;
        rubricExport.assessment.periodEnd = assessmentEnd;

        // Scores data

        detailedScoresModel.bindValues = [assessment];
        detailedScoresModel.select();

        for (var i=0; i<detailedScoresModel.count; i++) {
            var gradeObj = detailedScoresModel.getObjectInRow(i);
            var newGradeObj = {
                individual: gradeObj['individual'] + ' ' + gradeObj['name'] + ' ' + gradeObj['surname'],
                criterium: gradeObj['criterium'],
                // Remember that the new identifier collects the descriptor id and the definition as a string
                descriptor: gradeObj['descriptor'] + ":" + gradeObj['definition'],
                moment: gradeObj['moment'],
                comment: gradeObj['comment']
            }

            rubricExport.assessment.append(newGradeObj);
        }

        xmlText.text = rubricExport.xml;

        // Just levels, ignored for the export
        levelsOnlyModel.bindValues = [assessmentRubric];
        levelsOnlyModel.select();

        recalculateSectionDimensions();
    }

}
