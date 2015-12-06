import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import PersonalTypes 1.0
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates

BasicPage {
    id: rubricsListBasicPage
    width: 100
    height: 62

    pageTitle: qsTr("Avaluació de rúbriques");

    signal openRubricAssessmentDetails(int assessment, int rubric, string group, var rubricsModel, var rubricsAssessmentModel)
    signal openRubricGroupAssessment(int assessment)
    signal openRubricHistory(string group)

    onOpenRubricAssessmentDetails: {
        openSubPage('RubricAssessmentEditor', {idAssessment: assessment, rubric: rubric, group: group, rubricsModel: rubricsModel, rubricsAssessmentModel: rubricsAssessmentModel}, units.fingerUnit);
    }

    onOpenRubricHistory: openSubPage('RubricAssessmentHistory', {group: group})

    Common.UseUnits { id: units }

    mainPage: Item {
        id: rubricsListArea

        ListView {
            id: rubricsAssessmentList
            anchors.fill: parent

            clip: true
            model: rubricsAssessmentModel

            headerPositioning: ListView.OverlayHeader

            header: Rectangle {
                height: units.fingerUnit
                width: parent.width
                z: 2

                RowLayout {
                    id: layout
                    property real titleWidth: width / 3
                    property real descWidth: titleWidth

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.nailUnit
                    }
                    height: units.fingerUnit * 2

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.bold: true
                        text: qsTr('Identificació')
                    }
                    Text {
                        Layout.preferredWidth: rubricsAssessmentList.width / 6
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.bold: true
                        text: qsTr('Grup')
                    }
                    Text {
                        Layout.preferredWidth: rubricsAssessmentList.width / 6
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.bold: true
                        text: qsTr('Anotació')
                    }
                    Text {
                        Layout.preferredWidth: rubricsAssessmentList.width / 6
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.bold: true
                        text: qsTr('Termini')
                    }

                    Text {
                        Layout.preferredWidth: rubricsAssessmentList.width / 6
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.bold: true
                        text: qsTr('Opcions')
                    }
                }
            }

            delegate: Rectangle {
                width: rubricsAssessmentList.width
                height: units.fingerUnit * 2
                z: 1
                border.color: 'black'
                clip: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: openRubricGroupAssessment(model.id)
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: units.nailUnit
                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: '<b>' + model.title + '</b><br>' + model.desc
                    }
                    Text {
                        Layout.preferredWidth: rubricsAssessmentList.width / 6
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.group
                    }
                    Text {
                        Layout.preferredWidth: rubricsAssessmentList.width / 6
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.annotation
                    }
                    Text {
                        Layout.preferredWidth: rubricsAssessmentList.width / 6
                        Layout.fillHeight: true
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        property string annotation: model.annotation

                        onAnnotationChanged: {
                            console.log('Annotation changed');

                            var obj = annotationsModel.getObject(annotation);

                            if (obj['start'] != '') {
                                if (obj['start'] === obj['end']) {
                                    var date = (new Date()).fromYYYYMMDDFormat(obj['start']);
                                    text = date.toShortReadableDate();
                                } else {
                                    text = qsTr('Des de ') + obj['start'] + qsTr('fins a ') + obj['end'];
                                }
                            }
                        }
                    }

                    Common.ImageButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        image: 'window-27140'
                        onClicked: openMenu(units.fingerUnit * 4, rubricsAssessmentMenu, {})
                    }
                }

                Component {
                    id: rubricsAssessmentMenu

                    Rectangle {
                        id: menuRect

                        property int requiredHeight: childrenRect.height + units.fingerUnit * 2

                        signal closeMenu()

                        color: 'white'

                        ColumnLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }
                            anchors.margins: units.fingerUnit

                            spacing: units.fingerUnit

                            Common.TextButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: units.fingerUnit
                                fontSize: units.readUnit
                                text: qsTr('Detalls...')
                                onClicked: {
                                    menuRect.closeMenu();
                                    openRubricAssessmentDetails(model.id, model.rubric, model.group, rubricsModel, rubricsAssessmentModel)
                                }
                            }
                            Common.TextButton {
                                Layout.fillWidth: true
                                Layout.preferredHeight: units.fingerUnit
                                fontSize: units.readUnit
                                text: qsTr('Historial...')
                                onClicked: {
                                    menuRect.closeMenu();
                                    openRubricHistory(model.group);
                                }
                            }
                        }
                    }

                }

            }
            Common.SuperposedButton {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                size: units.fingerUnit * 2
                imageSource: 'plus-24844'
                onClicked: openMenu(units.fingerUnit * 2, addRubricAssessmentMenu, {})
//                        onClicked: openRubricAssessmentDetails(-1, -1, -1, rubricsModel, rubricsAssessmentModel)
            }
        }

        Component {
            id: addRubricAssessmentMenu

            Rectangle {
                property int requiredHeight: childrenRect.height + 4 * units.fingerUnit

                signal closeMenu()

                ListView {
                    id: possibleList
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: units.fingerUnit
                    }
                    height: contentItem.height

                    clip: true
                    interactive: false

                    model: groupsModel

                    delegate: Item {
                        id: singleRubricXGroup

                        width: possibleList.width
                        height: childrenRect.height

                        property string group: model.group

                        ColumnLayout {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }
//                            height: childrenRect.height

                            Text {
                                Layout.fillWidth: true
                                Layout.preferredHeight: units.fingerUnit
                                font.bold: true
                                font.pixelSize: units.readUnit
                                elide: Text.ElideRight
                                text: qsTr('Grup') + " " + model.group
                            }
                            GridView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: contentItem.height

                                model: rubricsModel
                                interactive: false

                                cellWidth: units.fingerUnit * 4
                                cellHeight: cellWidth

                                delegate: Common.BoxedText {
                                    width: units.fingerUnit * 3
                                    height: width
                                    margins: units.nailUnit
                                    text: model.title
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            closeMenu();
                                            openRubricAssessmentDetails(-1, model.id, singleRubricXGroup.group, rubricsModel, rubricsAssessmentModel);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Text {
                    anchors {
                        top: possibleList.bottom
                        left: parent.left
                        right: parent.right
                        margins: units.fingerUnit
                    }
                    height: units.fingerUnit
                    text: qsTr('Avaluació de rúbrica buida')
                    font.bold: true
                    font.pixelSize: units.readUnit

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            closeMenu();
                            openRubricAssessmentDetails(-1, -1, "", rubricsModel, rubricsAssessmentModel);
                        }
                    }
                }

                Component.onCompleted: {
                    groupsModel.selectUnique('group');
                    console.log('COUNT', groupsModel.count)
                }
            }
        }

        Models.IndividualsModel {
            id: groupsModel

            fieldNames: ['group']

            sort: 'id DESC'
        }

        Models.RubricsModel {
            id: rubricsModel
            Component.onCompleted: select()
        }

        Models.RubricsAssessmentModel {
            id: rubricsAssessmentModel

            sort: 'id DESC'

            Component.onCompleted: select()
        }

        Models.ExtendedAnnotations {
            id: annotationsModel

            Component.onCompleted: select();
        }

        Component.onCompleted: {
            rubricsModel.select();
            rubricsAssessmentModel.select();
        }

    }
}

