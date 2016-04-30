import QtQuick 2.5

Item {
    id: wheelClock
    property real clockRadius: Math.min(width, height) / 2 - 2 * units.fingerUnit
    property int from: 1
    property int to: 12
    property int count: to-from+1
    property int step: 1
    property real angleStepOffset: 1

    property int selectedIndex: -1

    Repeater {
        model: wheelClock.count

        Rectangle {
            id: numberText
            width: units.fingerUnit * 2
            height: numberText.width
            radius: width / 2

            property int number: (from + modelData) * step
            property real angle: -Math.PI/2 + 2*Math.PI * (modelData + angleStepOffset) / wheelClock.count

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: clockRadius * Math.sin(angle)
            anchors.horizontalCenterOffset: clockRadius * Math.cos(angle)

            color: (selectedIndex == model.index)?'yellow':'transparent'

            Text {
                anchors.centerIn: parent
                text: numberText.number
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    selectedIndex = model.index;
                    console.log(numberText.number);
                }
            }
        }
    }
}
