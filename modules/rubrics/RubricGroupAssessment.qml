import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import PersonalTypes 1.0
import RubricXml 1.0

import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///editors' as Editors
import 'qrc:///javascript/Debug.js' as Debug


Item {
    id: rubricRectangle

    property string rubricFile

    property int rubric: -1
    property string rubricTitle: rubricXmlModel.title
    property string rubricDesc: rubricXmlModel.description
    property string group: ''

    // color: 'gray'

    property int sectionsHeight: units.fingerUnit * 2
    property int sectionsWidth: units.fingerUnit * 3
    property int contentsHeight: units.fingerUnit * 2
    property int contentsWidth: units.fingerUnit * 2

    signal rubricAssessmentRubricEdit()
    signal rubricAssessmentDetailsEdit()
    signal rubricAssessmentAnnotationEdit()
    signal rubricAssessmentGroupEdit()
    signal rubricAssessmentCriteriumSelected(int criterium)

    Common.UseUnits {
        id: units
    }

    RubricXml {
        id: rubricXmlModel

        source: rubricFile
    }

    ColumnLayout {
        z: 2
        anchors.fill: parent

        Item {
            z: 10
            // Basic rubric info

            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            GridLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                columns: 3
                rows: 3
                columnSpacing: units.nailUnit
                rowSpacing: columnSpacing

                Text {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.preferredWidth: sectionsWidth
                    text: qsTr('Rúbrica')
                }
                Rectangle {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                    color: 'white'
                    Text {
                        anchors {
                            fill: parent
                            margins: units.nailUnit
                        }
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: units.readUnit
                        elide: Text.ElideRight
                        text: '<b>' + rubricRectangle.rubricTitle + '</b> ' + rubricRectangle.rubricDesc
                    }
                }

                Common.ImageButton {
                    image: 'edit-153612'
                    size: units.fingerUnit
                    onClicked: {
                        editRubricDetailsDialog.open();
                        // Edit rubric details
                        //editRubricDetailsMenu.showWidget();
                    }
                }


                Text {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.preferredWidth: sectionsWidth
                    text: qsTr('Avaluacions')
                }

                Rectangle {
                    Layout.preferredHeight: units.fingerUnit
                    Layout.fillWidth: true
                    color: 'white'
                    Text {
                        anchors {
                            fill: parent
                            margins: units.nailUnit
                        }
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: units.readUnit
                        elide: Text.ElideRight
                        font.italic: true
                        text: qsTr('(Avaluació única)')
                    }
                }
            }

            Common.SuperposedMenu {
                id: editRubricDetailsDialog
                title: qsTr('Detalls de rúbrica')

                standardButtons: StandardButton.Close

                Common.SuperposedMenuEntry {
                    text: qsTr('Títol')
                    onClicked: {
                        editRubricDetailsDialog.close();
                        editTitleDialog.open();
                        titleEditorItem.content = rubricTitle;
                    }
                }

                Common.SuperposedMenuEntry {
                    text: qsTr('Descripció')
                    onClicked: {
                        editRubricDetailsDialog.close();
                        editDescriptionDialog.open();
                        descriptionEditorItem.content = rubricDesc;
                    }
                }
            }

            Common.SuperposedMenu {
                id: editTitleDialog
                title: qsTr('Edita el títol')
                standardButtons: StandardButton.Save | StandardButton.Cancel

                Editors.TextLineEditor {
                    id: titleEditorItem
                    width: parent.width
                    height: units.fingerUnit * 2
                }

                onAccepted: {
                    rubricXmlModel.title = titleEditorItem.content;
                }
            }

            Common.SuperposedMenu {
                id: editDescriptionDialog
                title: qsTr('Edita la descripció')
                standardButtons: StandardButton.Save | StandardButton.Cancel

                Editors.TextAreaEditor3 {
                    id: descriptionEditorItem
                    width: parent.width
                    height: units.fingerUnit * 6
                    color: 'white'
                }

                onAccepted: {
                    rubricXmlModel.description = descriptionEditorItem.content;
                }
            }
        }

        Item {
            // Criteria and individuals grid

            Layout.fillWidth: true
            Layout.fillHeight: true

            GridLayout {
                anchors.fill: parent

                columns: 2
                rows: 3

                columnSpacing: units.nailUnit
                rowSpacing: units.nailUnit

                Rectangle {
                    id: title
                    Layout.preferredWidth: sectionsWidth
                    Layout.preferredHeight: sectionsHeight

                    border.color: 'black'
                    color: 'pink'
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        spacing: units.nailUnit
                        Text {
                            Layout.preferredHeight: parent.height / 2
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: rubricTitle
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: rubricDesc
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: rubricDetailsEdit(rubric,rubricTitle,rubricDesc,rubricsModel)
                    }
                }

                ListView {
                    id: horizontalHeading
                    Layout.fillWidth: true
                    Layout.preferredHeight: sectionsHeight

                    property real columnWidth: horizontalHeading.width / Math.max(rubricXmlModel.population.count, 1)

                    interactive: false
                    orientation: ListView.Horizontal

                    model: rubricXmlModel.population

                    delegate: Rectangle {
                        id: horizontalHeadingCell

                        property bool selectedCell: false

                        height: sectionsHeight
                        width: horizontalHeading.columnWidth
                        border.color: 'black'
                        color: 'transparent'
                        Text {
                            anchors {
                                fill: parent
                                margins: units.nailUnit
                            }

                            clip: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: units.readUnit
                            font.bold: true
                            text: model.name
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                horizontalHeading.currentIndex = model.index;
                                editRubricAssessmentByIndividual(assessment,model.id);
                            }
                        }
                    }

                    highlight: Rectangle {
                        color: 'yellow'
                    }
                    highlightFollowsCurrentItem: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            subPanelItem.load(qsTr('Població de la rúbrica'), 'rubrics/RubricPopulation', {population: rubricXmlModel.population});
                        }
                    }
                }

                ListView {
                    id: verticalHeading

                    Layout.fillHeight: true
                    Layout.preferredWidth: sectionsWidth

                    property real rowHeight: verticalHeading.height / Math.max(rubricXmlModel.criteria.count, 1)

                    interactive: false
                    orientation: ListView.Vertical

                    model: rubricXmlModel.criteria

                    delegate: Rectangle {
                        id: verticalHeadingCriterium

                        height: verticalHeading.rowHeight
                        width: verticalHeading.width
                        border.color: 'black'
                        color: 'transparent'
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            spacing: units.nailUnit
                            Text {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                clip: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: model.identifier + "-" + model.title
                            }
                            Text {
                                Layout.fillHeight: true
                                Layout.preferredWidth: contentWidth
                                text: model.weight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                verticalHeading.currentIndex = model.index;
                                rubricAssessmentCriteriumSelected(model.id);
                            }
                        }
                    }

                    highlight: Rectangle {
                        color: 'yellow'
                    }
                    highlightFollowsCurrentItem: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            subPanelItem.load(qsTr("Criteris d'avaluació"), 'rubrics/RubricCriteria', {criteria: rubricXmlModel.criteria});
                        }
                    }
                }

                Rectangle {
                    id: criteriaListForIndividuals

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Column {
                        id: criteriaListColumn

                        Repeater {
                            model: rubricXmlModel.criteria

                            Rectangle {
                                id: wholeCriteria
                                height: verticalHeading.rowHeight
                                width: criteriaListForIndividuals.width

                                property bool selectedCellVertically: false

                                border.color: 'black'
                                color: (selectedCellVertically)?'yellow':'transparent'

                                property string criterium: model.identifier

                                ListView {
                                    id: individualsList

                                    anchors.fill: parent

                                    property bool enableValues: false

                                    orientation: ListView.Horizontal
                                    interactive: false

                                    model: rubricXmlModel.population

                                    delegate: Rectangle {
                                        id: valuesForIndividual
                                        // The scores for a single individual

                                        height: wholeCriteria.height
                                        width: horizontalHeading.columnWidth
                                        border.color: 'black'
                                        color: 'transparent'

                                        property string individual: model.identifier
                                        property var incubator

                                        Connections {
                                            target: rubricXmlModel.assessment

                                            onCountChanged: {
                                                console.log('Count changed and call to fill values', valuesForIndividual.children.length);
                                                for (var i=0; i<valuesForIndividual.children.length; i++) {
                                                    var obj = valuesForIndividual.children[i];
                                                    if (obj['objectName'] == 'ValuesText') {
                                                        obj.fillValues();
                                                        console.log('Value filled');
                                                    }
                                                }
                                            }
                                        }

                                        Component.onCompleted: {
                                            valuesForIndividual.incubator = valuesTextComponent.incubateObject(valuesForIndividual, {criterium: wholeCriteria.criterium, individual: valuesForIndividual.individual});

                                            if (valuesForIndividual.incubator == null) {
                                                console.log('what happens??');
                                            } else {
                                                if (valuesForIndividual.incubator.status != Component.Ready) {
                                                    valuesForIndividual.incubator.onStatusChanged = function(status) {
                                                        if (status == Component.Ready) {
                                                            valuesForIndividual.incubator.object.fillValues();
                                                        } else {
                                                            if (status == Component.Error) {
                                                                console.log("ERROR!", valuesForIndividual.incubator.errorString());
                                                            } else {
                                                                console.log('OTHERS', status);
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    valuesForIndividual.incubator.object.fillValues();
                                                }

                                            }

                                        }
                                    }

                                    Component.onCompleted: {
                                        enableValues = true;
                                    }
                                }
                            }

                        }
                    }

                }

                Rectangle {
                    Layout.preferredWidth: sectionsWidth
                    Layout.preferredHeight: sectionsHeight
                    border.color: 'black'
                    color: 'yellow'
                    Text {
                        anchors {
                            fill: parent
                            margins: units.nailUnit
                        }
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: units.readUnit
                        text: qsTr('Total punts')
                    }
                }

                Rectangle {
                    id: footerTotalRow

                    Layout.fillWidth: true
                    Layout.preferredHeight: sectionsHeight
                    color: 'pink'

                    Row {
                        Repeater {
                            model: []

                            Rectangle {
                                height: footerTotalRow.height
                                width: footerTotalRow.width / individualsModel.count
                                border.color: 'black'
                                color: '#F5DA81'
                                Text {
                                    anchors.fill: parent
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: units.readUnit
                                    text: model.name + " " + model.surname + ": " + model.points
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: subPanelItem

        function load(title, page, args) {
            subPanelItem.title = title;
            subPanelLoader.setSource("qrc:///modules/" + page + ".qml", args);
            subPanelItem.open();
        }

        property string title: ''

        contentItem: Rectangle {
//            id: subPanelItem
            z: 3
            implicitHeight: rubricRectangle.height * 0.8
            implicitWidth: rubricRectangle.width * 0.8
//            visible: subPanelItem.enabled
//            enabled: false

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: units.nailUnit
                spacing: units.nailUnit

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.fingerUnit * 2
                    RowLayout {
                        anchors.fill: parent
                        spacing: units.nailUnit
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: subPanelItem.title
                        }
                        Common.ImageButton {
                            Layout.fillHeight: true
                            image: 'road-sign-147409'
                            onClicked: subPanelItem.close()
                        }
                    }
                }

                Loader {
                    id: subPanelLoader
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }

        }

    }


    Component {
        id: valuesTextComponent

        Text {
            id: mainItem
            anchors.fill: parent

            objectName: "ValuesText"

            property string individual
            property string criterium

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            clip: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideRight

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            function fillValues() {
                var info = "";
                for (var i=0; i<rubricXmlModel.assessment.count; i++) {
                    var values = rubricXmlModel.assessment.get(i);
                    if ((values.criterium == mainItem.criterium) && (values.individual == mainItem.individual)) {
                        info = values.descriptor + ((values.comment !='')?("\n" + values.comment):'');
                    }
                }
                mainItem.text = info;

            }
        }
    }

    Component.onCompleted: {
        // Get assessment details

        rubricXmlModel.loadXml(rubricFile);
    }

}
