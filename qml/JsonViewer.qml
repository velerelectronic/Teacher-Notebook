import QtQuick 2.2
import QtQuick.Layouts 1.1
import FileIO 1.0
import QtQuick.Dialogs 1.1
import PersonalTypes 1.0

import 'qrc:///common' as Common


Rectangle {
    id: jsonViewer

    Common.UseUnits { id: units }

    property alias document: file.source
    property string pageTitle: qsTr('Visor de JSON')

    FileIO {
        id: file
        onSourceChanged: {
            var contents = file.read();
            var object = JSON.parse(contents);
            jsonModel.clear();
            traverseObject(0, object);
        }

        function traverseObject(level, object) {
            for (var prop in object) {
                var type = typeof object[prop];
                if ((type == 'string') || (type == 'number')) {
                    jsonModel.append({level: level, propertyName: prop, propertyValue: object[prop].toString()});
                } else {
                    jsonModel.append({level: level, propertyName: prop, propertyValue: ''});
                    traverseObject(level + 1, object[prop]);
                }
            }
        }
    }
    ListModel {
        id: jsonModel
    }

    ListView {
        id: propertiesList
        anchors.fill: parent
        anchors.margins: units.fingerUnit
        model: jsonModel
        delegate: showObject
        clip: true
    }

    Component {
        id: showObject
        Rectangle {
            width: propertiesList.width
            height: Math.max(units.fingerUnit,propertyName.contentHeight,propertyValue.contentHeight) + units.nailUnit * 2
            RowLayout {
                anchors.fill: parent
                spacing: 0
                Rectangle {
                    Layout.preferredWidth: parent.width / 2
                    Layout.fillHeight: true
                    border.color: 'black'
                    color: '#55ff55'
                    Text {
                        id: propertyName
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        anchors.leftMargin: units.nailUnit + model.level * units.fingerUnit
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.propertyName
                    }
                }
                Rectangle {
                    Layout.preferredWidth: parent.width / 2
                    Layout.fillHeight: true
                    border.color: 'black'
                    Text {
                        id: propertyValue
                        anchors.fill: parent
                        anchors.margins: units.nailUnit
                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.propertyValue
                    }
                }
            }
        }
    }
}
