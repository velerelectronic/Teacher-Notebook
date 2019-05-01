#include <QTimer>
#include <QTextBlock>
#include <QMouseEvent>
#include <QPainter>
#include <QRectF>
#include <QAbstractTextDocumentLayout>
#include "markdownviewer.h"
#include "MarkDownParser/markdownparser.h"

MarkDownViewer::MarkDownViewer(QQuickItem *parent) {
    mdDocument = new QTextDocument(this);
    setFlag(QQuickItem::ItemHasContents);

    qDebug() << "MarkDownViewer connections";
    //connect(this, SIGNAL(windowChanged(QQuickWindow *)), this, SLOT(resizeEditor()));

    //connect(window(), SIGNAL(heightChanged(int)), this, SLOT(resizeEditor()));
    //connect(SIGNAL(widthC))

    connect(mdDocument->documentLayout(), SIGNAL(documentSizeChanged(QSizeF)), this, SIGNAL(textHeightChanged()));
    update();
    parseMarkDown("");
}


MarkDownViewer::~MarkDownViewer() {
    delete mdDocument;
}

void MarkDownViewer::paint(QPainter *painter) {
    QRectF r(0,0,this->width(),this->height());
    qDebug() << "Pintant" << r;
    painter->fillRect(r, QBrush(QColor("white")));
    mdDocument->setTextWidth(this->width());
    mdDocument->drawContents(painter, r);
}

void MarkDownViewer::parseMarkDown(const QString &text) {
    QTextCursor cursor(mdDocument);
    mdDocument->clear();
    MarkDownParser parser;
    parser.parseIntoCursor(text, cursor);
}

int MarkDownViewer::textHeight() {
    return mdDocument->size().height();
}

