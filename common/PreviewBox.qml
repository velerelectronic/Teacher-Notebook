import QtQuick 2.0
import '../common' as Common

// Show a single line of the first 5 elements

Rectangle {
    id: previewBox
    width: 100
    height: list.height
    anchors.margins: units.nailUnit
    clip: true

    property int maxItems: 5
    property alias delegate: list.delegate
    property int totalCount: 0
    property string caption: 'Heading'
    property string prefixTotal: 'There are'
    property string suffixTotal: 'items'
    property string captionBackgroundColor: '#CEF6CE'
    property string totalBackgroundColor: ''
    signal totalCountClicked()
    signal captionClicked()

    Common.UseUnits { id: units }

    border.color: 'black'

    ListView {
        id: list
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: contentItem.height

        interactive: false
        model: ListModel { id: internalModel }

        header: Rectangle {
            id: listHeader
            width: parent.width
            border.width: 0
            height: textHeader.height + units.nailUnit * 2
            color: previewBox.captionBackgroundColor

            Text {
                id: textHeader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: units.nailUnit
                font.bold: true
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: previewBox.caption
                MouseArea {
                    anchors.fill: parent
                    onClicked: previewBox.captionClicked()
                }
            }
        }

        footer: Rectangle {
            id: listFooter
            width: parent.width
            height: textFooter.height + units.nailUnit * 2
            border.width: 0
            color: previewBox.totalBackgroundColor

            Text {
                id: textFooter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: units.nailUnit
                font.pixelSize: units.readUnit
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: previewBox.prefixTotal + ' ' + totalCount + ' ' + previewBox.suffixTotal
                MouseArea {
                    anchors.fill: parent
                    onClicked: previewBox.totalCountClicked()
                }
            }
        }

    }
    function makeSummary (model) {
        var idxModel=0;
        var idxItem=0;
        while ((idxItem<maxItems) && (idxModel<model.count)) {
            var data = model.get(idxModel);
            if ((!data.state) || (data.state!='done')) {
                internalModel.append(data);
                idxItem++;
            }
            idxModel++;
        }

        totalCount = model.count;
    }
}
