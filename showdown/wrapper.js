function mdtohtml(mdtext) {
    Qt.include('qrc:///showdown/showdown.js');
    var converter = new Showdown.converter();
    console.log(mdtext);
    var html = converter.makeHtml(mdtext);
    console.log(html);
    return html;
}
