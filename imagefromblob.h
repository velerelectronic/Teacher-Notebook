#include <QQuickPaintedItem>
#include <QImage>
#include <QPainter>

#ifndef IMAGEFROMBLOB_H
#define IMAGEFROMBLOB_H

// Source code from:
// https://stackoverflow.com/questions/40358387/how-to-show-on-qml-qt-from-sqlite-blob-data-as-image#40359236

class QImageItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QImage image READ image WRITE setImage NOTIFY imageChanged)
    Q_PROPERTY(QString data READ data WRITE setData NOTIFY dataChanged)

public:
    explicit QImageItem(QQuickItem *parent = Q_NULLPTR) : QQuickPaintedItem(parent) {}

    QString data() const;
    QImage image() const { return m_image; }

    void setData(const QString &data);
    void setImage(const QImage &image);

    void paint(QPainter *painter) Q_DECL_OVERRIDE;

private:
    QImage m_image;
    QByteArray innerData;

signals:
    void dataChanged();
    void imageChanged();
};

#endif // IMAGEFROMBLOB_H
