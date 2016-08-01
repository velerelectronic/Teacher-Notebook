import QtQuick 2.3
import QtQuick.Layouts 1.1
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates
import FileIO 1.0

Rectangle {
    id: planningAula

    property string document: ''
    property var jsonModel
    property string pageTitle: qsTr("Programació d'aula per sessions")
    signal openDocument(string page, string document)

    Common.UseUnits { id: units }

    ListModel {
        id: groupsModel
    }

    ListModel {
        id: sessionsModel
    }

    ColumnLayout {
        anchors.fill: parent
        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            font.pixelSize: units.readUnit
            text: planningAula.document
        }
        ListView {
            id: groupListView
            Layout.fillWidth: true
            Layout.preferredHeight: units.fingerUnit
            clip: true
            model: groupsModel
            spacing: units.nailUnit
            orientation: ListView.Horizontal
            delegate: Rectangle {
                radius: height / 2
                width: Math.max(units.fingerUnit * 2, groupName.contentWidth) + radius * 2
                height: groupListView.height
                color: 'yellow'
                Text {
                    id: groupName
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: parent.radius
                    }
                    font.pixelSize: units.readUnit
                    text: model.name
                }
            }
        }

        ListView {
            id: sessionsListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: sessionsModel
            property int commonDisplacement: 0

            delegate: Rectangle {
                id: sessionRectangle

                border.color: 'black'
                color: '#55ff55'
                property var sessionsGroupModel: model.groups
                property int sessionNumber: model.index + 1

                width: sessionsListView.width
                height: Math.max(units.fingerUnit * 2, contentsMdViewer.height + 2 * units.nailUnit, sessionGroupsList.maximumHeight) + border.width * 2
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: parent.border.width
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: units.fingerUnit
                        color: '#ddffdd'
                        Text {
                            anchors.fill: parent
                            anchors.margins: units.nailUnit
                            font.pixelSize: units.glanceUnit
                            font.bold: true
                            text: model.id
                        }
                    }

                    Rectangle {
                        id: sessionContentsRect
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / 3
                        MarkDownViewer {
                            id: contentsMdViewer
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: units.nailUnit
                            }

                            state: 'showContentsOnly'
                            document: planningAula.document + '/Session ALL-' + model.id + '.md'
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: planningAula.openDocument('MarkDownViewer',contentsMdViewer.document)
                        }
/*
                        Text {
                            anchors.fill: parent
                            font.pixelSize: units.readUnit
                            text: model.contents
                        }
                        */
                    }
                    ListView {
                        id: sessionGroupsList
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        orientation: ListView.Horizontal
                        model: sessionRectangle.sessionsGroupModel
                        spacing: units.nailUnit
                        clip: true
                        property int maximumHeight: 0

                        function recalculateMaximumHeight() {
                            var max = 0;
                            var items = sessionGroupsList.contentItem.children;
                            console.log('Number children ' + items.length);
                            for (var i=0; i<items.length; i++) {
                                var newHeight = items[i].markDownHeight;
                                if (typeof (newHeight) !== 'undefined') {
                                    console.log("i: " + i + "---" + newHeight);
                                    if (newHeight > max)
                                        max = newHeight;
                                }

                            }
                            maximumHeight = max;
                            console.log('Max: ' + maximumHeight);
                        }

                        onContentXChanged: {
                            if (movingHorizontally) {
                                sessionsListView.commonDisplacement = contentX;
                            }
                        }

                        Connections {
                            target: sessionsListView
                            onCommonDisplacementChanged: {
                                if (!sessionGroupsList.movingHorizontally) {
                                    sessionGroupsList.contentX = sessionsListView.commonDisplacement;
                                }
                            }
                        }

                        delegate: Rectangle {
                            width: units.fingerUnit * 6 // sessionGroupsList.width / model.count
                            height: sessionGroupsList.height
                            property real markDownHeight: dateText.contentHeight + units.nailUnit + mdViewer.height + 2 * mdViewer.anchors.margins
                            color: 'white'

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0
                                Rectangle {
                                    id: dateRectangle
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: dateText.contentHeight + 2 * dateText.anchors.margins

                                    Text {
                                        id: dateText
                                        anchors.fill: parent
                                        anchors.margins: units.nailUnit
                                        font.pixelSize: units.readUnit
                                        font.bold: true
                                    }
                                    Component.onCompleted: {
                                        var today = new Date();
                                        var date = new Date();
                                        date.fromYYYYMMDDFormat(model.date.toString());
                                        dateRectangle.color = ((date <= today) && (date >= today))?'yellow':'#cccccc';
                                        dateText.text = date.toShortReadableDate();
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    MarkDownViewer {
                                        id: mdViewer
                                        anchors {
                                            top: parent.top
                                            left: parent.left
                                            right: parent.right
                                            margins: units.nailUnit
                                        }

                                        state: 'showContentsOnly'
                                        document: planningAula.document + '/Session ' + groupsModel.get(model.index)['id'] + '-' + sessionRectangle.sessionNumber + '.md'
                                        onHeightChanged: {
                                            console.log('Recalculating maximum height...' + height);
                                            sessionGroupsList.recalculateMaximumHeight();
                                        }
                                        /*{
                                            if (sessionGroupsList.maximumHeight < height) {
                                                sessionGroupsList.maximumHeight = height;
                                            }
                                        }*/
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: planningAula.openDocument('MarkDownViewer',mdViewer.document)
                                    }
                                }
                            }
                        }
                        Component.onCompleted: {
                            console.log(sessionGroupsList.width / model.count);
                            console.log('Model.groups: ' + model.count);
                            sessionGroupsList.recalculateMaximumHeight();
                            sessionGroupsList.contentX = sessionsListView.commonDisplacement;
                        }
                    }
                }
            }
        }
    }

    FileIO {
        id: file
        source: planningAula.document + '/manifest.json'
        onSourceChanged: {
            console.log(source);
            var contents = file.read();
            jsonModel = JSON.parse(contents);
            readContentsFromJsonModel();
        }
    }

    function readContentsFromJsonModel() {
        var groups = jsonModel.planning.groups;
        groupsModel.clear();
        for (var i=0; i<groups.length; i++) {
            groupsModel.append(groups[i]);
        }
        var sessions = jsonModel.planning.sessions;
        sessionsModel.clear();
        for (var i=0; i<sessions.length; i++) {
            sessionsModel.append(sessions[i]);
        }
    }

    function getDocumentBase(doc) {
        var pos = doc.lastIndexOf('/');
        if (pos>-1) {
            return doc.substr(0,pos);
        } else {
            return doc;
        }
    }

    Component.onCompleted: {
        console.log("document base: " + getDocumentBase(document));
    }
}

