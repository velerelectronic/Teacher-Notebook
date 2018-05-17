import QtQuick 2.7
import PersonalTypes 1.0
import 'qrc:///common' as Common

Rectangle {
    Common.UseUnits {
        id: units
    }

    property var parameters
    property MarkDownItem markDownItem: MarkDownItem {}
    property Item units: Common.UseUnits {}

    property int paragraphSpacing: units.nailUnit

    signal updatedHeight(int newHeight)
    signal updatedWidth(int newWidth)

    property int requiredHeight
    property int requiredWidth

}
