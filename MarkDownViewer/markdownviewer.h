#ifndef MARKDOWNVIEWER_H
#define MARKDOWNVIEWER_H

#include <QObject>
#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QTextDocument>
#include <QTextEdit>
#include <QWidget>
#include <QWheelEvent>

class MarkDownViewer: public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(int textHeight READ textHeight NOTIFY textHeightChanged)

public:
    explicit MarkDownViewer(QQuickItem *parent = 0);
    ~MarkDownViewer();

    Q_INVOKABLE void parseMarkDown(const QString &text);

    void    paint(QPainter *painter);
    int     textHeight();

signals:
    void textHeightChanged();

protected:
    QTextDocument *mdDocument;
};

#endif // MARKDOWNVIEWER_H
