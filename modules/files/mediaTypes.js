
function imageForMediaType(source, mediaType) {
    if ((mediaType == null) && (typeof mediaType === 'undefined'))
        mediaType = "";
    switch(mediaType.toLowerCase()) {
    case 'bmp':
    case 'gif':
    case 'jpg':
    case 'jpeg':
    case 'png':
        return source;
    case 'csv':
    case 'doc':
    case 'ods':
    case 'odt':
    case 'pdf':
    case 'txt':
        return 'qrc:///icons/homework-152957.svg';
    case 'rubric':
        return 'qrc:///icons/checklist-154274.svg';
    default:
        return 'qrc:///icons/road-sign-147409.svg';
    }
}


