#include "standardpaths.h"

StandardPaths::StandardPaths(QObject *parent) :
    QObject(parent)
{
}

QString StandardPaths::applications() {
    return QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
}

QString StandardPaths::dataLocation() {
    return QStandardPaths::writableLocation(QStandardPaths::DataLocation);
}

QString StandardPaths::desktop() {
    return QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
}

QString StandardPaths::documents() {
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
}

QString StandardPaths::downloads() {
    return QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
}

QString StandardPaths::genericDataLocation() {
    return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
}

QString StandardPaths::home() {
    return QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
}

QString StandardPaths::movies() {
    return QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
}

QString StandardPaths::music() {
    return QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
}

QString StandardPaths::pictures() {
    return QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
}
