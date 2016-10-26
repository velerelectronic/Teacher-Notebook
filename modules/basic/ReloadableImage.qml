import QtQuick 2.7

Loader {
    id: loaderItem

    property string imageSource
    property int fillMode
    property int implicitImageWidth
    property int implicitImageHeight

    function reloadImage() {
        loaderItem.sourceComponent = undefined;
    }

    function transferSource() {
        if (item !== null)
            loaderItem.item.source = loaderItem.imageSource;
    }

    function setImageComponent() {
        loaderItem.sourceComponent = imageComponent;
    }

    onStatusChanged: {
        switch(status) {
        case Loader.Null:
            console.log('NULL');
            setImageComponent();
            break;
        case Loader.Ready:
            console.log('Ready');
            transferSource();
            break;
        default:
            break;
        }
    }

    Component {
        id: imageComponent

        Image {
            id: innerImage

            cache: false

            Connections {
                target: loaderItem

                onFillModeChanged: innerImage.fillMode = loaderItem.fillMode
                onImageSourceChanged: innerImage.source = loaderItem.imageSource
            }

            onImplicitWidthChanged: loaderItem.implicitImageWidth = innerImage.implicitWidth
            onImplicitHeightChanged: loaderItem.implicitImageHeight = innerImage.implicitHeight
            onStatusChanged: {
                if (status == Image.Ready) {
                    loaderItem.implicitImageWidth = innerImage.implicitWidth;
                    loaderItem.implicitImageHeight = innerImage.implicitHeight;
                    innerImage.fillMode = loaderItem.fillMode;
                }
            }
        }
    }

    onImageSourceChanged: {
        transferSource();
    }

    Component.onCompleted: {
        setImageComponent();
    }
}
