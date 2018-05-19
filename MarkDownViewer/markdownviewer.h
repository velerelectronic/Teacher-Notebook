#ifndef MARKDOWNVIEWER_H
#define MARKDOWNVIEWER_H

#include <QObject>
#include <QQuickItem>
#include <QQuickPaintedItem>
#include <QTextDocument>
#include <QTextEdit>
#include <QWidget>

class MarkDownViewer: public QQuickPaintedItem
{
    Q_OBJECT

public:
    explicit MarkDownViewer(QQuickItem *parent = 0);
    ~MarkDownViewer();

    Q_INVOKABLE void parseMarkDown(const QString &text);
    void paint(QPainter *painter);

    void update(const QRect &rect = QRect());

protected slots:
    void    resizeEditor();

protected:
    QTextDocument *mdDocument;
    QTextEdit *textEditor;
};

#endif // MARKDOWNVIEWER_H
