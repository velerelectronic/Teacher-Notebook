
#include "fileio.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QString>

FileIO::FileIO(QObject *parent) :
    QObject(parent)
{

}

bool FileIO::create() {
    if (mSource.isEmpty()) {
        return false;
    }

    QFile file(mSource);
    if (file.open(QIODevice::ReadOnly)) {
        file.close();
        return false;
    }
    file.open(QIODevice::WriteOnly);
    file.close();
    return true;
}

QString FileIO::source() {
    return mSource;
}

void FileIO::setSource(const QString& source) {
    mSource = source;
    if (mSource.startsWith("file://")) {
        mSource.remove(0,6);
    }
    sourceChanged();
}

QString FileIO::read()
{
    if (mSource.isEmpty()){
        emit error("Source is empty");
        return QString();
    }

    QFile file(mSource);
    QString fileContent;
    if ( file.open(QIODevice::ReadOnly) ) {
        QString line;
        QTextStream t( &file );
        do {
            line = t.readLine();
            fileContent += line;
         } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        return QString();
    }
    return fileContent;
}

bool FileIO::write(const QString& data)
{
    if (mSource.isEmpty()) {
        qDebug() << "Empty";
        return false;
    }

    QFile file(mSource);
    if (!file.open(QFile::WriteOnly | QFile::Truncate)) {
        qDebug() << "No file";
        return false;
    }

    QTextStream out(&file);
    out << data;

    file.close();

    return true;
}

QString FileIO::filePath() {
    // Change this
}
