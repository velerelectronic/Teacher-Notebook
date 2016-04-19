import QtQuick 2.5
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import 'qrc:///models' as Models

Rectangle {
    id: relatedAnnotations

    property int requiredHeight
    property string labelBase: ''
    property string labels

    property string mainIdentifier: ''
    property string initialState: ''

    signal selectAnnotation(string identifier)

    color: 'grey'

    Common.UseUnits {
        id: units
    }

    Component.onCompleted: {
//        refreshAnnotationsList();

        switch(selectedIndex) {
        case 0:
            relatedAnnotationsModel.sort = 'title ASC, start ASC, end ASC';
            relatedAnnotationsModel.filters = ["title != ''"];
            relatedAnnotationsModel.bindValues = [];
            relatedAnnotationsModel.select();
            break;
        case 1:
            break;
        case 2:
            relatedAnnotationsModel.sort = 'start ASC, end ASC, title ASC';
            relatedAnnotationsModel.filters = ["(title = ?) OR ((title != '') AND (state != '-1'))"];
            relatedAnnotationsModel.bindValues = [relatedAnnotations.mainIdentifier];
            relatedAnnotationsModel.select();
            break;
        default:
            break;
        }
        getMainIndex();
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.preferredHeight: units.fingerUnit * 1
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth
                    font.pixelSize: units.readUnit
                    text: qsTr('Etiquetes:')
                }
                Flow {
                    id: labelsGrid
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    spacing: units.nailUnit

                    Repeater {
                        Component.onCompleted: {
                            model = relatedAnnotations.labels.split(/\s+/g);
                            refreshAnnotationsList();
                        }

                        delegate: Rectangle {
                            id: labelRect
                            objectName: 'labelItem'
                            width: labelText.width + units.fingerUnit
                            height: labelsGrid.height
                            radius: height / 2
                            color: (selected)?'#AAFFAA':'#AAAAAA'
                            property bool selected: true
                            property string labelText: modelData

                            Text {
                                id: labelText
                                anchors {
                                    top: parent.top
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                }
                                width: contentWidth
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: units.readUnit
                                text: modelData
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    labelRect.selected = !labelRect.selected;
                                    refreshAnnotationsList();
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: units.fingerUnit
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth
                    font.pixelSize: units.readUnit
                    text: qsTr('Estats:')
                }
                Flow {
                    id: statesGrid
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    spacing: units.nailUnit

                    Repeater {
                        Component.onCompleted: {
                            model = [0,1,-1]
                            refreshAnnotationsList();
                        }

                        delegate: Rectangle {
                            id: stateRect
                            objectName: 'stateItem'
                            width: stateText.width + units.fingerUnit
                            height: statesGrid.height
                            radius: height / 2
                            color: (selected)?'#AAAAFF':'#AAAAAA'
                            property bool selected: modelData != -1
                            property int stateValue: modelData

                            Text {
                                id: stateText
                                anchors {
                                    top: parent.top
                                    horizontalCenter: parent.horizontalCenter
                                    bottom: parent.bottom
                                }
                                width: contentWidth + 2 * units.nailUnit
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: units.readUnit
                                text: {
                                    switch(modelData) {
                                    case 1:
                                        return qsTr('A mig fer');
                                    case -1:
                                        return qsTr('Finalitzats');
                                    case 0:
                                    default:
                                        return qsTr('Actius');
                                    }
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    stateRect.selected = !stateRect.selected;
                                    refreshAnnotationsList();
                                }
                            }
                        }
                    }
                }
            }
        }

        Common.SearchBox {
            id: searchBox
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit * 1.5
            onPerformSearch: {
                refreshAnnotationsList();
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: 'gray'

            ListView {
                id: relatedAnnotationsView

                anchors.fill: parent
                clip: true

                property int listIndex

                model: Models.ExtendedAnnotations {
                    id: relatedAnnotationsModel
                }

                spacing: units.nailUnit

                header: Text {
                    width: relatedAnnotationsView.width
                    height: units.fingerUnit
                    font.pixelSize: units.readUnit
                    text: qsTr("Anotacions amb etiqueta #") + relatedAnnotations.labelBase
                }

                delegate: Rectangle {
                    width: relatedAnnotationsView.width
                    height: units.fingerUnit * 2
                    color: (model.title == mainIdentifier)?'yellow':'white'
                    RowLayout {
                        anchors.fill: parent
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 3
                            font.pixelSize: units.readUnit
                            color: 'green'
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: (model.labels)?model.labels:''
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            font.pixelSize: units.readUnit
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: model.title
                        }

                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width / 5
                            font.pixelSize: units.readUnit
                            color: 'red'
                            text: model.start + "\n" + model.end
                        }

                        StateComponent {
                            Layout.fillHeight: true
                            Layout.preferredWidth: units.fingerUnit * 3

                            stateValue: model.state
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectAnnotation(model.title);
                        }
                    }
                }

                onListIndexChanged: {
                    if (relatedAnnotationsView.listIndex > -1)
                        relatedAnnotationsView.positionViewAtIndex(listIndex,ListView.Center);
                }
            }
        }

    }

    function refreshAnnotationsList() {
        var filters = [];
        var labelsArray = [];
        labelsArray.push(relatedAnnotations.mainIdentifier);

        for (var i=0; i<labelsGrid.children.length; i++) {
            var obj = labelsGrid.children[i];
            if (obj.objectName == 'labelItem') {
                if (obj.selected) {
                    labelsArray.push(obj.labelText);
                    filters.push("(INSTR(' '||labels||' ',?))");
                }
            }
        }

        var statesFilter = [];
        for (var i=0; i<statesGrid.children.length; i++) {
            var obj = statesGrid.children[i];
            if (obj.objectName == 'stateItem') {
                if (obj.selected) {
                    switch(obj.stateValue) {
                    case 0:
                        statesFilter.push("state != '10' AND state != '-1'");
                        break;
                    case 1:
                        statesFilter.push("state = '10'");
                        break;
                    case -1:
                        statesFilter.push("state = '-1'");
                        break;
                    }
                }
            }
        }

        relatedAnnotationsModel.sort = 'start ASC, end ASC, title ASC';
        relatedAnnotationsModel.searchFields = ['title', 'desc'];
        relatedAnnotationsModel.searchString = searchBox.text;
        relatedAnnotationsModel.filters = ["title = ? OR ((" + ((filters.length>0)?filters.join(" AND "):"1=1") + ") AND (" + statesFilter.join(" OR ") + "))"];
        relatedAnnotationsModel.bindValues = labelsArray;
        relatedAnnotationsModel.select();

        getMainIndex();
    }

    function getMainIndex() {
        for (var i=0; i<relatedAnnotationsModel.count; i++) {
            var obj = relatedAnnotationsModel.getObjectInRow(i);
            if (obj['title'] == mainIdentifier) {
                relatedAnnotationsView.listIndex = i;
                break;
            }
        }
        console.log('main index', relatedAnnotationsView.listIndex);
    }
}
