
#include "fileio.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QString>
#include <QPixmap>
#include <QImage>
#include <QBuffer>
#include <QDebug>

FileIO::FileIO(QObject *parent) :
    QObject(parent)
{

}

bool FileIO::addExtension(const QString &extension) {
    QString newExtension = "." + extension;
    if (!mSource.toLower().endsWith(newExtension.toLower())) {
        mSource = mSource + newExtension;
        sourceChanged();
    }
}

bool FileIO::append(const QString &data) {
    if (mSource.isEmpty()) {
        qDebug() << "Empty";
        return false;
    }

    QFile file(mSource);
    if (!file.open(QFile::WriteOnly | QFile::Append)) {
        qDebug() << "No file";
        return false;
    }

    QTextStream out(&file);
    out << data;

    file.close();

    return true;
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

QString FileIO::filePath() {
    // Change this
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
            fileContent += line + '\n';
         } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        return QString();
    }
    return fileContent;
}

QString FileIO::readBinary() {
    if (mSource.isEmpty()){
        emit error("Source is empty");
        return QString();
    }

    QFile file(mSource);
    if ( file.open(QIODevice::ReadOnly) ) {
        QByteArray binaryData = file.readAll();
        file.close();
        return QString(binaryData.toBase64());
    } else {
        emit error("Unable to open the file");
        return QString();
    }
}

QString FileIO::readBase64Image() {
    if (mSource.isEmpty()){
        emit error("Source is empty");
        return QString();
    }

    QByteArray imageContents;
    QFile file(mSource);
    if (file.open(QIODevice::ReadOnly)) {
        QImage image;
        if (image.load(&file,0)) {
            QBuffer buffer(&imageContents);
            buffer.open(QIODevice::WriteOnly);
            image.save(&buffer, "PNG");
        }
    }
    return QString("data:image/png;base64,") + QString(imageContents.toBase64());
}

bool FileIO::removeSource() {
    QFile file(mSource);
    return file.remove();
}

void FileIO::setSource(const QString& source) {
    mSource = source;
    if (mSource.startsWith("file://")) {
        mSource.remove(0,6);
    }
    sourceChanged();
}

QString FileIO::source() {
    return mSource;
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

bool FileIO::writePngImage(const QString &data) {
    if (mSource.isEmpty()) {
        return false;
    }
    QFile file(mSource);
    if (!file.open(QFile::WriteOnly | QFile::Truncate)) {
        return false;
    }

    QString suffix;
    QString prefix("data:image/png;base64,");
    if (data.startsWith(prefix)) {
        suffix = data.mid(prefix.length());
    }

    QImage image;
    image.loadFromData(QByteArray::fromBase64(suffix.toLatin1()), "PNG");
    image.save(&file, "PNG");

    file.close();
    sourceChanged();
    return true;
}

