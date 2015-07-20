#include <QFile>
#include <QDebug>
#include "imagedata.h"

ImageData::ImageData(QObject *parent) :
    QObject(parent)
{
}

const QString &ImageData::source() {
    return innerSource;
}

const QString &ImageData::dataURL() {
    qDebug() << "C++ DataURL";
    QString *result = new QString("");
    QFile file(innerSource);
    if (file.open(QIODevice::ReadOnly)) {
        qDebug() << "inside";
        *result += QString("data:image/png;base64,") + file.readAll().toBase64();
    }
    file.close();
    dataURLChanged();
    return *result;
}

void ImageData::setSource(const QString &newSource) {
    innerSource = newSource;
    sourceChanged();
}
