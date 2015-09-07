import QtQuick 2.5
import QtQuick.Layouts 1.1
import PersonalTypes 1.0

import 'qrc:///common' as Common
import 'qrc:///editors' as Editors

Rectangle {
    property string pageTitle: (importData)?qsTr('Importador de dades'):qsTr('Exportador de dades')
    property var fieldNames: []
    property SqlTableModel writeModel
    property var fieldConstants: []

    property bool importData: true

    Common.UseUnits { id: units }

    ListModel {
        id: partialModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: units.nailUnit

        Editors.TextAreaEditor2 {
            id: textImport
            Layout.preferredHeight: units.fingerUnit * 4
            Layout.fillWidth: true
        }

        ListView {
            id: dataList
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            model: partialModel

            headerPositioning: ListView.OverlayHeader
            header: Item {
                height: units.fingerUnit
                width: dataList.width
                z: 2

                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Repeater {
                        model: fieldNames.length
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: 'yellow'
                            Text {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                font.pixelSize: units.readUnit
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight
                                text: fieldNames[modelData]
                            }
                        }
                    }
                }
            }

            delegate: Rectangle {
                id: rowDelegate
                width: dataList.width
                height: units.fingerUnit * 2
                color: (model.selected)?'green':'white'

                z: 1

                property var vectorData: model.data

                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    Repeater {
                        model: fieldNames.length
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            border.color: 'black'
                            color: 'transparent'
                            Text {
                                anchors.fill: parent
                                anchors.margins: units.nailUnit
                                font.pixelSize: units.readUnit
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight
                                text: rowDelegate.vectorData[fieldNames[modelData]]
                            }
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        partialModel.setProperty(model.index,'selected',!model.selected)
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: units.fingerUnit * 2
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent

                visible: !importData
                Common.Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Llegeix')
                    onClicked: readDataFromModel()
                }
                Common.Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Converteix')
                    onClicked: textImport.text = writeSeparatedByNewlines()
                }
                Common.Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Al portaretalls')
                    onClicked: textImport.copyAll()
                }
            }

            RowLayout {
                anchors.fill: parent

                visible: importData
                Common.Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Importa')
                    onClicked: importSeparatedByNewlines(textImport.text)
                }
                Common.Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Desa')
                    onClicked: saveSelectedItems()
                }
                Common.Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr('Esborra')
                }
            }
        }
    }

    // Import functions

    function importSeparatedByNewlines(text) {
        var obj = text.split('\n');
        var l = fieldNames.length;
        for (var i=0; i<=obj.length-l; i=i+l) {
            console.log(obj[i] + "--" + obj[i+1]);

            var newObj = {};
            for (var j=0; j<l; j++) {
                newObj[fieldNames[j]] = obj[i+j];
            }
            for (var j=0; j<fieldConstants.length; j++) {
                newObj[fieldConstants[j].name] = fieldConstants[j].value;
            }

            partialModel.append({data: newObj, selected: false});
        }
    }

    function saveSelectedItems() {
        for (var i=0; i<partialModel.count; i++) {
            var object = partialModel.get(i);
            if (object['selected']) {
                console.log(object['data'])
                writeModel.insertObject(object['data']);
                partialModel.setProperty(i,'selected',false);
            }
        }
    }

    // Export functions

    function readDataFromModel() {
        // Attention: It converts newline into spaces

        for (var i=0; i<writeModel.count; i++) {
            var newObj = {};
            var obj = writeModel.getObjectInRow(i);

            var l = fieldNames.length;

            newObj = obj;

            for (var j=0; j<fieldNames.length; j++) {
                newObj[fieldNames[j]] = obj[fieldNames[j]].replace(/\n/g,' ');
            }

            for (var j=0; j<fieldConstants.length; j++) {
                newObj[fieldConstants[j].name] = fieldConstants[j].value;
            }

            partialModel.append({data: newObj, selected: false});
        }
    }

    function writeSeparatedByNewlines() {
        var result = "";
        for (var i=0; i<partialModel.count; i++) {
            var object = partialModel.get(i);
            if (object['selected']) {
                for (var j=0; j<fieldNames.length; j++) {
                    console.log(fieldNames[j]);
                    result += object['data'][fieldNames[j]] + "\n";
                }
            }
        }
        return result;
    }
}

