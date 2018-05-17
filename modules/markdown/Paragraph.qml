import QtQuick 2.7
import PersonalTypes 1.0

Generic {
    id: paragraphBase

    requiredWidth: width
    requiredHeight: mainFlow.height

    Flow {
        id: mainFlow

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: childrenRect.height
        onHeightChanged: updatedHeight(height)

        spacing: paragraphBase.paragraphSpacing

        Repeater {
            model: MarkDownItemModel {
                id: mdModel
            }

            delegate: MarkDown {
                markDownType: model.type
                parameters: model.parameters
                width: requiredWidth
                height: requiredHeight
            }
        }
    }

    onParametersChanged: mdModel.parseMarkDown(parameters)

    Component.onCompleted: mdModel.parseMarkDown(parameters)
}
