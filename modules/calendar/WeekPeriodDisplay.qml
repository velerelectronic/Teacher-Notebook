import QtQuick 2.5
import 'qrc:///common' as Common
import "qrc:///common/FormatDates.js" as FormatDates

Item {
    id: weekPeriodDisplay

    property int daysNumber: 0
    property int requiredHeight: flowLayout.height

    Common.UseUnits {
        id: units
    }

    Flow {
        id: flowLayout

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height

        spacing: units.nailUnit

        Repeater {
            model: daysNumber

            Rectangle {
                width: Math.floor((weekPeriodDisplay.width - flowLayout.spacing * 6) / 7)
                height: units.fingerUnit
                color: 'orange'
            }
        }
    }

    function setPeriod(start, end) {
        var startDate = new Date();
        startDate.fromYYYYMMDDFormat(start);
        var endDate = new Date();
        endDate.fromYYYYMMDDFormat(end);

        var days = startDate.differenceInDays(endDate) + 1;
        daysNumber = (days >= 1)?days:0;
    }
}
