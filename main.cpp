#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "fileio.h"
#include "xmlmodel.h"
#include "imagedata.h"
#include "teachingplanning.h"
#include "sqltablemodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<TeachingPlanning>("PersonalTypes", 1, 0, "TeachingPlanning");
    qmlRegisterType<XmlModel>("PersonalTypes", 1, 0, "XmlModel");
    qmlRegisterType<ImageData>("PersonalTypes", 1, 0, "ImageData");
    qRegisterMetaType<XmlModel>("XmlModel");
    // qmlRegisterType<SqlTableModel>("PersonalTypes", 1, 0, "SqlTableModel");


    QQmlApplicationEngine engine;

    QSqlDatabase db;
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(engine.offlineStoragePath() + "/Databases/ef79ea28197bfead13fcb427d2bf7d11.sqlite");

    SqlTableModel annotationsModel;
    SqlTableModel scheduleModel;
    engine.rootContext()->setContextProperty("annotationsModel",&annotationsModel);
    engine.rootContext()->setContextProperty("scheduleModel",&scheduleModel);

    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();
}
