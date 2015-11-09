import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///editors' as Editors
import 'qrc:///models' as Models
import "qrc:///common/FormatDates.js" as FormatDates

BasicPage {
    id: rubricsListBasicPage
    width: 100
    height: 62

    property string pageTitle: qsTr("Rúbriques");

    signal openRubricAssessmentDetails(int assessment, int rubric, string group, var rubricsModel, var rubricsAssessmentModel)
    signal openRubricDetails(int rubric, var rubricsModel)
    signal openRubricEditor(int rubric, var rubricsModel)
    signal openRubricGroupAssessment(int assessment)
    signal openRubricHistory(string group)
    signal openInternalRubricGroupAssessment(int assessment)

    onOpenRubricAssessmentDetails: {
        openSubPage('RubricAssessmentEditor', {idAssessment: assessment, rubric: rubric, group: group, rubricsModel: rubricsModel, rubricsAssessmentModel: rubricsAssessmentModel}, units.fingerUnit);
    }

    onOpenInternalRubricGroupAssessment: {
        console.log('VARS 4', assessment);
        openSubPage('RubricGroupAssessment', {assessment: assessment}, units.fingerUnit);
    }

    onOpenRubricDetails: openSubPage('RubricDetailsEditor', {rubric: rubric, rubricsModel: rubricsModel}, units.fingerUnit)
    onOpenRubricEditor: openSubPage('Rubric', {rubric: rubric, rubricsModel: rubricsModel}, units.fingerUnit)
    onOpenRubricHistory: openSubPage('RubricAssessmentHistory', {group: group})

    mainPage: Rectangle {
        id: rubricsListArea

        property bool newIndividual: false

        Common.TabbedView {
            id: tabbedView

            anchors.fill: parent

            Component.onCompleted: {
                tabbedView.widgets.append({title: qsTr('Avaluacions'), component: rubricsAssessmentComponent});
                tabbedView.widgets.append({title: qsTr('Definicions'), component: rubricsListComponent});
                tabbedView.widgets.append({title: qsTr('Grups'), component: rubricsGroupsComponent});
                tabbedView.widgets.append({title: qsTr('Rúbriques x grups'), component: possibleRubricsComponent});
                tabbedView.widgets.append({title: qsTr('Llistes'), component: historyComponent});
            }
        }

        Component {
            id: rubricsAssessmentComponent

            Item {
                id: rubricsAssessmentItem

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
                        onClicked: openRubricAssessmentDetails(-1, -1, -1, rubricsModel, rubricsAssessmentModel)
                    }
                }

            }
        }

        Component {
            id: rubricsListComponent

            ListView {
                id: rubricsList

                clip: true

                model: rubricsModel
                delegate: Rectangle {
                    width: rubricsList.width
                    height: units.fingerUnit * 2
                    border.color: 'black'
                    MouseArea {
                        anchors.fill: parent
                        onClicked: rubricsListBasicPage.openRubricEditor(model.id,rubricsModel)
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                            text: model.title
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                            text: model.desc
                        }
                        Button {
                            Layout.fillHeight: true
                            // Layout.preferredWidth: width
                            text: qsTr('Avalua')
                            onClicked: openRubricAssessmentDetails(-1, model.id, '', rubricsModel, rubricsAssessmentModel)
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
                    onClicked: openRubricDetails(-1, rubricsModel)
                }
            }

        }

        Component {
            id: rubricsGroupsComponent

            GroupsIndividuals {
                id: groupsIndividuals
            }
        }

        Component {
            id: possibleRubricsComponent

            Rectangle {
                ListView {
                    id: possibleList
                    anchors.fill: parent

                    clip: true

                    model: groupsModel

                    delegate: Rectangle {
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
                            height: childrenRect.height

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
                                            console.log('ID RUBRIC', singleRubricXGroup.idRubric);
                                            openRubricAssessmentDetails(-1, model.id, singleRubricXGroup.group, rubricsModel, rubricsAssessmentModel);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Component.onCompleted: {
                    groupsModel.selectUnique('group');
                    console.log('COUNT', groupsModel.count)
                }
            }
        }

        Component {
            id: historyComponent

            Rectangle {
                id: historyItem

                ColumnLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit
                    Common.BoxedText {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        text: qsTr('Llistes')
                    }
                    Common.BoxedText {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        text: qsTr('Rúbrica:')
                    }

                    ListView {
                        id: rubricsList

                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit * 2
                        model: rubricsModel

                        orientation: ListView.Horizontal

                        delegate: Common.BoxedText {
                            height: rubricsList.height
                            width: units.fingerUnit * 4

                            property int rubric: model.id
                            property string rubricTitle: model.title

                            color: 'transparent'
                            border.color: 'black'
                            margins: units.nailUnit

                            text: model.title

                            MouseArea {
                                anchors.fill: parent
                                onClicked: rubricsList.currentIndex = model.index;
                            }

                        }
                        highlight: Rectangle {
                            height: units.fingerUnit * 4
                            width: units.fingerUnit * 4
                            color: 'yellow'
                        }
                    }

                    Common.BoxedText {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        text: qsTr('Criteris:')
                    }

                    ListView {
                        id: criteriaList

                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit * 2

                        model: criteriaModel
                        orientation: ListView.Horizontal

                        delegate: Common.BoxedText {
                            id: singleCriterium

                            height: criteriaList.height
                            width: units.fingerUnit * 4

                            property int criterium: model.id
                            property string criteriumTitle: model.title

                            states: [
                                State {
                                    name: 'selected'
                                    PropertyChanges {
                                        target: singleCriterium
                                        color: 'yellow'
                                    }
                                },
                                State {
                                    name: 'unselected'
                                    PropertyChanges {
                                        target: singleCriterium
                                        color: 'transparent'
                                    }
                                }
                            ]

                            state: 'unselected'

                            color: 'transparent'
                            border.color: 'black'
                            margins: units.nailUnit

                            text: model.title

                            MouseArea {
                                anchors.fill: parent
                                onClicked: singleCriterium.state = (singleCriterium.state == 'unselected')?'selected':'unselected'
                            }

                        }
                    }
                    Common.BoxedText {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit
                        text: qsTr('Grups:')
                    }
                    ListView {
                        id: groupsList

                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit * 2

                        model: groupsModel
                        orientation: ListView.Horizontal

                        delegate: Common.BoxedText {
                            id: singleGroup

                            height: groupsList.height
                            width: units.fingerUnit * 4

                            property string group: model.group

                            states: [
                                State {
                                    name: 'selected'
                                    PropertyChanges {
                                        target: singleGroup
                                        color: 'yellow'
                                    }
                                },
                                State {
                                    name: 'unselected'
                                    PropertyChanges {
                                        target: singleGroup
                                        color: 'transparent'
                                    }
                                }
                            ]

                            state: 'unselected'

                            border.color: 'black'
                            margins: units.nailUnit

                            text: model.group

                            MouseArea {
                                anchors.fill: parent
                                onClicked: singleGroup.state = (singleGroup.state == 'unselected')?'selected':'unselected';
                            }

                        }
                        Component.onCompleted: {
                            groupsModel.selectUnique('group');
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RowLayout {
                            anchors.fill: parent
                            spacing: units.nailUnit

                            Calendar {
                                id: historyStartDate

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Calendar {
                                id: historyEndDate

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: units.fingerUnit * 2
                        text: qsTr('Genera llista')
                        onClicked: historyItem.generateList()
                    }
                }
                Models.RubricsCriteriaModel {
                    id: criteriaModel

                    filters: ['rubric=?']
                    bindValues: [(rubricsList.currentIndex>=0)?rubricsList.currentItem.rubric:-1]

                }

                Models.IndividualsModel {
                    id: individualsModel
                }

                Connections {
                    target: rubricsList
                    onCurrentIndexChanged: criteriaModel.select()
                }
                function generateList() {
                    historyListLayout.visible = true;
                    var text = "<html>";
                    text += "<head>";
                    text += "<style text=\"text/css\">";
                    text += "h1 { text-decoration: underline }";
                    text += "</style>";
                    text += "</head>";
                    text += "<body>";
                    text += "<h1>Llista</h1>"

                    var rubricTitle = rubricsList.currentItem.rubricTitle;
                    text += "<p>Rúbrica: " + rubricTitle + "</p>";

                    for (var i=0; i < criteriaList.contentItem.children.length; i++) {
                        var criteriumObj = criteriaList.contentItem.children[i];
                        if (criteriumObj.state == 'selected') {
                            text += "<h2>Criteri: " + criteriumObj.criteriumTitle + "</h2>";

                            for (var j=0; j < groupsList.contentItem.children.length; j++) {
                                var groupObj = groupsList.contentItem.children[j];
                                text += "<h3>Grup: " + groupObj.group + "</h3>";

//                                individualsModel.filters = ["\"group\"='" + groupObj.group + "'"];

                                individualsModel.filters = ["\"group\"=?"];
                                individualsModel.bindValues = [groupObj.group];
                                individualsModel.select();

                                text += "<table style=\"border: solid 1pt black\">";
                                text += "<tr>";
                                text += "<th>Data</th>";
                                console.log('individuals count', individualsModel.count);
                                for (var indiv = 0; indiv < individualsModel.count; indiv++) {
                                    var indivObj = individualsModel.getObjectInRow(indiv);
                                    text += "<th style=\"border: solid 1pt black\">" + indivObj.surname + ", " + indivObj.name + ":" + indivObj.group + "." + "</th>";
                                }
                                text += "</tr>";

                                var day = historyStartDate.selectedDate;

                                while (day <= historyEndDate.selectedDate) {
                                    text += "<tr>";
                                    text += "<td>" + day.toLongDate() + "</td>";
                                    text += "</tr>";
                                    day.setDate(day.getDate() + 1);
                                }

                                text += "</table>";
                            }
                        }
                    }

                    text += "</html>";
                    htmlList.text = text;
                }

                Rectangle {
                    id: historyListLayout

                    anchors.fill: parent
                    visible: false

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit

                        Text {
                            id: htmlList

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.fingerUnit * 2
                            text: qsTr('Envia...')
                            onClicked: {}
                        }
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: units.fingerUnit * 2
                            text: qsTr('Tanca')
                            onClicked: historyListLayout.visible = false;
                        }
                    }
                }

            }
        }

        Models.IndividualsModel {
            id: groupsModel

            fieldNames: ['group']

            sort: ['id DESC']
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

    Common.UseUnits { id: units }
}

