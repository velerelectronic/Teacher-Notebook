import QtQuick 2.7
import QtQuick.Layouts 1.1
import PersonalTypes 1.0
import 'qrc:///common' as Common
import 'qrc:///models' as Models
import 'qrc:///modules/basic' as Basic

Item {
    property string groupName: ''

    Common.UseUnits {
        id: units
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.nailUnit

        Rectangle {
            id: mainOptionsSelector

            property var magnitudesList: []
            property var individualsList: []
        }

        ListView {
            id: valuesList

            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: units.nailUnit

            model: ListModel {
                id: individualsModel
            }

            ListModel {
                id: magnitudesModel
            }

            delegate: Rectangle {
                height: childrenRect.height
                width: valuesList.width

                RowLayout {
                    anchors.fill: parent
                    spacing: units.nailUnit

                    Text {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width / (magnitudesModel.count+1)

                        font.pixelSize: units.readUnit
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: model.individual
                    }
                    Repeater {
                        model: magnitudesModel
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            color: 'green'

                            ListView {
                                anchors.fill: parent

                            }
                        }
                    }
                }
            }
        }
    }
}
