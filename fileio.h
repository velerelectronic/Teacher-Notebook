// Source:
// http://www.developer.nokia.com/community/wiki/Reading_and_writing_files_in_QML

#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>

class FileIO : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString source
               READ source
               WRITE setSource
               NOTIFY sourceChanged)
    Q_PROPERTY(QString filePath READ filePath NOTIFY filePathChanged)

public:

    explicit FileIO(QObject *parent = 0);

    Q_INVOKABLE bool create();
    Q_INVOKABLE QString read();
    Q_INVOKABLE QString readBinary();
    Q_INVOKABLE QString readBase64Image();
    Q_INVOKABLE bool write(const QString& data);
    Q_INVOKABLE bool writePngImage(const QString &data);
    Q_INVOKABLE bool append(const QString& data);
    Q_INVOKABLE bool addExtension(const QString& extension);
    Q_INVOKABLE bool removeSource();

    QString source();
    QString filePath();

public slots:
    void setSource(const QString& source);

signals:
    void sourceChanged();
    void error(const QString& msg);
    void filePathChanged();

private:
    QString mSource;
};

#endif // FILEIO_H

