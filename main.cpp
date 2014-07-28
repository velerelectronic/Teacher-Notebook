#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "fileio.h"
#include "xmlmodel.h"
#include "imagedata.h"
#include "teachingplanning.h"
#include "sqltablemodel.h"
#include "databasebackup.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("developerjmpc");
    app.setApplicationVersion("1.0");
    QString specificPath("TeacherNotebook");
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
    if (!dir.exists(specificPath)) {
        dir.mkdir(specificPath);
    }

    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<TeachingPlanning>("PersonalTypes", 1, 0, "TeachingPlanning");
    qmlRegisterType<XmlModel>("PersonalTypes", 1, 0, "XmlModel");
    qmlRegisterType<ImageData>("PersonalTypes", 1, 0, "ImageData");
    qRegisterMetaType<XmlModel>("XmlModel");
    qmlRegisterType<DatabaseBackup>("PersonalTypes", 1, 0, "DatabaseBackup");
    qmlRegisterType<SqlTableModel>("PersonalTypes", 1, 0, "SqlTableModel");


    QQmlApplicationEngine engine;

    QSqlDatabase db;
    if (dir.cd(specificPath)) {
        db = QSqlDatabase::addDatabase("QSQLITE");
        db.setDatabaseName(dir.absolutePath() + "/mainDatabase.sqlite");
    }

    SqlTableModel annotationsModel;
    SqlTableModel scheduleModel;
    engine.rootContext()->setContextProperty("annotationsModel",&annotationsModel);
    engine.rootContext()->setContextProperty("scheduleModel",&scheduleModel);

    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();
}
