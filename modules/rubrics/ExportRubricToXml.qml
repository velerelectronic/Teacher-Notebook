import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQml.StateMachine 1.0 as DSM
import QtQml.Models 2.2
import 'qrc:///common' as Common
import 'qrc:///models' as Models

import RubricXml 1.0

Item {
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

    Models.ExtendedAnnotations {
        id: annotationsModel
    }

    ListView {
        id: itemsList
        anchors.fill: parent

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
                            Layout.preferredHeight: units.fingerUnit * 2
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                Text {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    font.pixelSize: units.readUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    text: "<p><b>" + model.title + "</b></p><p>" + model.desc + "</p>"
                                }
                                Text {
                                    Layout.preferredWidth: parent.width / 4
                                    Layout.fillHeight: true
                                    font.pixelSize: units.readUnit
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    text: qsTr('Ordre ') + model.ord
                                }
                                Text {
                                    Layout.preferredWidth: parent.width / 4
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
                                        text: qsTr('Nivell')
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
                                height: units.fingerUnit
                                border.color: 'black'
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: units.nailUnit
                                    Text {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width / 6
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.descriptor
                                    }
                                    Text {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width / 6
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.level
                                    }
                                    Text {
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.width / 6
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.definition
                                    }
                                    Text {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        font.pixelSize: units.readUnit
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: "<p><b>" + model.title + "</b></p><p>" + model.desc + "</p>"
                                    }
                                    Text {
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
            Common.BoxedText {
                width: itemsList.width
                height: Math.max(units.fingerUnit, contentHeight)
                border.color: 'black'
                boldFont: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr('Puntuacions')
            }
            ListView {
                width: itemsList.width
                height: contentItem.height

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
            }
            Rectangle {
                width: itemsList.width
                height: units.nailUnit
                color: 'black'
            }
        }
    }

    function addLineToString(str, suffix) {
        return str + "\n" + suffix;
    }

    Component.onCompleted: {
        assessmentModel.select();
        var obj = assessmentModel.getObject('id', assessment);
        assessmentTitle = obj['title'];
        assessmentDescription = obj['desc'];
        assessmentRubric = obj['rubric'];
        assessmentGroup = obj['group'];
        assessmentAnnotation = obj['annotation'];

        annotationsModel.select();
        console.log('Filtering', assessmentTitle);
        var annotationObj = annotationsModel.getObject('title', assessmentAnnotation);
        assessmentStart = annotationObj['start'];
        assessmentEnd = annotationObj['end'];

        criteriaModel.bindValues = [assessmentRubric];

        criteriaModel.select();
        var xml = '<rubric version="1.0"';
        xml += ' title="' + assessmentTitle + '"';
        xml += ' description="' + assessmentDescription + '.';
        xml += ' Source: rubric id ' + assessmentRubric + ', annotation ' + assessmentAnnotation + '"'
        xml += ' group="' + assessmentGroup + '">';

        xml = addLineToString(xml, '<assessment periodStart="' + assessmentStart + '" periodEnd="' + assessmentEnd + '">');
        for (var i=0; i<criteriaModel.count; i++) {
            var criteriumObj = criteriaModel.getObjectInRow(i);
            xml = addLineToString(xml, '<criterium title="' + criteriumObj['title'] + '" description="'+ criteriumObj['desc'] + '" weight="' + criteriumObj['weight'] + '" order="' + criteriumObj['ord'] + '">');

            generalLevelsAndDescriptorsModel.bindValues = [criteriumObj['id']];
            generalLevelsAndDescriptorsModel.select();
            for (var j=0; j<generalLevelsAndDescriptorsModel.count; j++) {
                var descriptorObj = generalLevelsAndDescriptorsModel.getObjectInRow(j);
                xml = addLineToString(xml, '<descriptor');
                xml += ' level="' + descriptorObj['level'] + '"'
                xml += ' definition="' + descriptorObj['definition'] + '"'
                xml += ' title="' + descriptorObj['title'] + '"'
                xml += ' description="' + descriptorObj['desc'] + '"'
                xml += ' score="' + descriptorObj['score'] + '"/>';
            }
            xml += '</criterium>';
        }

        xml += addLineToString(xml, '</assessment>');

        xml = addLineToString(xml, '</rubric>');

        rubricExport.xml = xml;
        xmlText.text = xml;
    }
}
