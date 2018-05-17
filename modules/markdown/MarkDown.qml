import QtQuick 2.7
import PersonalTypes 1.0

Item {
    id: genericMarkDownItem

    property int markDownType: mdValues.Body
    property var parameters

    property int requiredHeight: units.readUnit
    property int requiredWidth: width

    onMarkDownTypeChanged: setMarkDownType()

    MarkDownItem {
        id: mdValues
    }

    Loader {
        id: mdLoader

        anchors.fill: parent

        Connections {
            target: mdLoader
            ignoreUnknownSignals: true

            onUpdatedHeight: genericMarkDownItem.requiredHeight = mdLoader.item.requiredHeight
            onUpdatedWidth: genericMarkDownItem.requiredWidth = newWidth
        }

        onLoaded: {
            genericMarkDownItem.requiredHeight = mdLoader.item.requiredHeight
        }
    }

    function setMarkDownType() {
        var page = '';
        var param = {};

        console.log('md type', markDownType);

        switch(markDownType) {
        case mdValues.Paragraph:
            page = 'Paragraph';
            param['text'] = parameters[0];
            break;
        case mdValues.Text:
            page = 'Text';
            param['text'] = parameters[0];
            break;
        case mdValues.Table:
            page = 'Table';
            param['body'] = parameters;
            break;
        case mdValues.Body:
            page = 'Body';
            param['text'] = parameters;
            break;
        case mdValues.CheckList:
            page = 'CheckList';
            param['option'] = parameters[0];
            param['text'] = parameters[1];
            break;
        case mdValues.Link:
            page = 'Link';
            param['text']=parameters[1];
            param['address']=parameters[2];
            break;
        case mdValues.Heading:
            page = 'Heading';
            param['text'] = parameters;
            break;
        default:
            page = 'WholeWord';
            param['text'] = parameters
            break;
        }
        if (page != "") {
            mdLoader.setSource('qrc:///modules/markdown/' + page + ".qml", param);
        }
    }
}
