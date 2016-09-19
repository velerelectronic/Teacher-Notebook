
function imageForMediaType(source, mediaType) {
    if ((mediaType == null) && (typeof mediaType === 'undefined'))
        mediaType = "";
    switch(mediaType.toLowerCase()) {
    case '':
        return 'qrc:///icons/box-147574.svg';
    case 'bmp':
    case 'gif':
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'svg':
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
        return 'qrc:///icons/question-mark-40876.svg';
    }
}


