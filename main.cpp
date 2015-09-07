#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "fileio.h"
#include "xmlmodel.h"
#include "imagedata.h"
#include "teachingplanning.h"
#include "sqltablemodel.h"
#include "databasebackup.h"
#include "standardpaths.h"
#include "MarkDownParser/markdownparser.h"

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
    qmlRegisterType<XmlModel>("PersonalTypes", 1, 0, "XmlModel");
    qmlRegisterType<TeachingPlanning>("PersonalTypes", 1, 0, "TeachingPlanning");
    qmlRegisterType<ImageData>("PersonalTypes", 1, 0, "ImageData");
    qRegisterMetaType<XmlModel>("XmlModel");
    qmlRegisterType<DatabaseBackup>("PersonalTypes", 1, 0, "DatabaseBackup");
    qmlRegisterType<SqlTableModel>("PersonalTypes", 1, 0, "SqlTableModel");
    qmlRegisterType<StandardPaths>("PersonalTypes", 1, 0, "StandardPaths");
    qmlRegisterType<MarkDownParser>("PersonalTypes", 1, 0, "MarkDownParser");

    QStringList list;
    list << QString("A1") << QString("B2") << QString("B3");

    XmlModel model2;
    model2.setStringList(list);

    QQmlApplicationEngine engine;

    QSqlDatabase db;
    if (dir.cd(specificPath)) {
        db = QSqlDatabase::addDatabase("QSQLITE");
        db.setDatabaseName(dir.absolutePath() + "/mainDatabase.sqlite");
    }

    SqlTableModel annotationsModel;
    SqlTableModel scheduleModel;
    SqlTableModel projectsModel;
    SqlTableModel resourcesModel;
    SqlTableModel resourcesAnnotationsModel;

    annotationsModel.setTableName("annotations");
    scheduleModel.setTableName("schedule");
    projectsModel.setTableName("projects");
    resourcesModel.setTableName("resources");
    resourcesAnnotationsModel.setTableName("resourcesAnnotations");

    annotationsModel.select();
    scheduleModel.select();
    projectsModel.select();
    resourcesModel.select();
    resourcesAnnotationsModel.select();

    engine.rootContext()->setContextProperty("globalAnnotationsModel",&annotationsModel);
    engine.rootContext()->setContextProperty("globalScheduleModel",&scheduleModel);
    engine.rootContext()->setContextProperty("globalProjectsModel",&projectsModel);
    engine.rootContext()->setContextProperty("globalResourcesModel",&resourcesModel);
    engine.rootContext()->setContextProperty("globalResourcesAnnotationsModel",&resourcesAnnotationsModel);

    engine.rootContext()->setContextProperty("tmp",&model2);

    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();
}
