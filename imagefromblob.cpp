#include "imagefromblob.h"

QString QImageItem::data() const {
    return innerData;
}

void QImageItem::paint(QPainter *painter) {
    if (m_image.isNull()) return;

    painter->drawImage(0, 0, m_image.scaled(width(), height()));
}

void QImageItem::setData(const QString &data) {
    innerData = QByteArray::fromBase64(data.toUtf8());

    emit dataChanged();

    QImage newImage;

    newImage.loadFromData(innerData);
    QImageItem::setImage(newImage);
}

void QImageItem::setImage(const QImage &image) {
    m_image = image;
    emit imageChanged();
    update();

    setImplicitWidth(m_image.width());
    setImplicitHeight(m_image.height());
}

