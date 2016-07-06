import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import PersonalTypes 1.0
import ClipboardAdapter 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates

Item {
    id: rubricsListArea

    signal rubricGroupAssessmentSelected(int assessment)
    signal rubricGroupAssessmentExportSelected(int assessment)

    property int assessment

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
                Item {
                    Layout.preferredWidth: units.fingerUnit * 3
                    Layout.fillHeight: true
                }
            }
        }

        spacing: units.nailUnit

        onCurrentIndexChanged: {
            if (currentIndex>-1)
                positionViewAtIndex(currentIndex, ListView.Center);
        }

        delegate: Rectangle {
            width: rubricsAssessmentList.width
            height: units.fingerUnit * 2
            z: 1
            color: (isSelected)?'yellow':'white'
            property bool isSelected: model.id == assessment
            clip: true

            onIsSelectedChanged: {
                if (isSelected)
                    rubricsAssessmentList.currentIndex = model.index;
            }

            MouseArea {
                anchors.fill: parent
                onClicked: rubricGroupAssessmentSelected(model.id)
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
                Button {
                    Layout.preferredWidth: units.fingerUnit * 3
                    Layout.fillHeight: true
                    text: qsTr('Exporta')
                    onClicked: rubricsListArea.rubricGroupAssessmentExportSelected(model.id)
                }
            }

            Component.onCompleted: {
                if (isSelected)
                    rubricsAssessmentList.currentIndex = model.index;
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

        Component.onCompleted: {
            if (currentIndex>-1)
                positionViewAtIndex(currentIndex, ListView.Center);
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

//        searchString: (rubricsListBasicPage.searchString !== '')?rubricsListBasicPage.searchString:undefined
//        searchFields: rubricsListBasicPage.searchFields

        sort: 'id DESC'

        limit: 100
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
