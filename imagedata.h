#ifndef IMAGEDATA_H
#define IMAGEDATA_H

#include <QObject>

class ImageData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString dataURL READ dataURL NOTIFY dataURLChanged)

public:
    explicit ImageData(QObject *parent = 0);

    const QString &source();
    const QString &dataURL();

    void setSource(const QString &);

signals:
    void sourceChanged();
    void dataURLChanged();

public slots:

private:
    QString innerSource;
};

#endif // IMAGEDATA_H
