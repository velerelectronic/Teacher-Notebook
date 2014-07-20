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

    Q_INVOKABLE QString read();
    Q_INVOKABLE bool write(const QString& data);

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

