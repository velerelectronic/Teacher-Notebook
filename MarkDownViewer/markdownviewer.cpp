#include <QTimer>
#include <QTextBlock>
#include "markdownviewer.h"
#include "MarkDownParser/markdownparser.h"

MarkDownViewer::MarkDownViewer(QQuickItem *parent) {
    mdDocument = new QTextDocument(this);
    textEditor = new QTextEdit();
    setFlag(QQuickItem::ItemHasContents);
    //textEditor->resize(this->width(), this->height());
    textEditor->setDocument(mdDocument);
    resizeEditor();

    QTimer *timer = new QTimer(this);
    timer->setInterval(1000);
    timer->connect(timer, SIGNAL(timeout()), this, SLOT(resizeEditor()));
    timer->start();

    connect(this, SIGNAL(windowChanged(QQuickWindow)), this, SLOT(resizeEditor()));
    //connect(window(), SIGNAL(heightChanged(int)), this, SLOT(resizeEditor()));
    //connect(SIGNAL(widthC))

    update();
    parseMarkDown("");
}


MarkDownViewer::~MarkDownViewer() {
    delete textEditor;
    delete mdDocument;
}

void MarkDownViewer::parseMarkDown(const QString &text) {
    //mdDocument->setHtml("<h1>Un encapçalament</h1><p>Com estam?</p><p>Molt bé!</p><p>...</p><table border=\"1\"><tr><td>1<td>2<td>3<tr><td>a<td>b<td>c</table>");
    QTextCursor cursor(mdDocument);
    mdDocument->clear();
    MarkDownParser parser;
    //cursor.insertBlock();
    parser.parseIntoCursor(text, cursor);
}

void MarkDownViewer::paint(QPainter *painter) {
    //textEditor->resize(this->width(), this->height());
    //textEditor->render(painter);
    qDebug() << "PAINT";
    //textEditor->setUpdatesEnabled(true);
    //textEditor->resize(this->width(), this->height());
    textEditor->repaint();
    textEditor->render(painter, QPoint(0,0), QRegion(0, 0, this->width(), this->height()));
}

void MarkDownViewer::resizeEditor() {
    qreal w = this->width();
    qreal h = this->height();
    if ((textEditor->width() != w) || (textEditor->height() != h)) {
        textEditor->resize(w, h);
        update();
    }
}

void MarkDownViewer::update(const QRect &rect) {
    qDebug() << "NOW update";
    textEditor->resize(rect.width(), rect.height());
    textEditor->window()->resize(this->width(), this->height());
    QQuickPaintedItem::update(rect);
}
