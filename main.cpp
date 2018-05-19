#include <QApplication>
#include <Qt>
#include <QtCore>
#include <QWidget>
#include <QStandardPaths>
#include <QtWebView>

#include <QGuiApplication>
#include <QtQml/QtQml>
#include <QtQml/QQmlApplicationEngine>

#include <QXmlQuery>
//#include <QtQml>


#include "fileio.h"
#include "imagedata.h"
#include "TeachingPlanning/teachingplanning.h"
#include "SqlTableModel2/sqltablemodel.h"
#include "databasebackup.h"
#include "standardpaths.h"

#include "ClipboardAdapter/qmlclipboardadapter.h"
#include "CryptographicHash/cryptographichash.h"
#include "MarkDownParser/markdownparser.h"
#include "RubricXml/rubricxml.h"
#include "RubricXml/rubriccriteria.h"
#include "RubricXml/rubricdescriptorsmodel.h"
#include "RubricXml/rubricpopulationmodel.h"
#include "MarkDownViewer/markdownviewer.h"

#include "markdownitemmodel.h"

#include "imagefromblob.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QtWebView::initialize();

    app.setOrganizationName("developerjmpc");
    app.setApplicationVersion("1.0");
    QString specificPath("TeacherNotebook");
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation));
    if (!dir.exists(specificPath)) {
        dir.mkdir(specificPath);
    }

    // Register rubric classes and types
    qmlRegisterType<RubricXml>("RubricXml", 1, 0, "RubricXml");
    qmlRegisterType<RubricCriteria>("RubricXml", 1, 0, "RubricCriteriaModel");
    qmlRegisterType<RubricDescriptorsModel>("RubricXml", 1, 0, "RubricDescriptorsModel");
    qmlRegisterType<RubricPopulationModel>("RubricXml", 1, 0, "RubricPopulationModel");
    qmlRegisterType<QImageItem>("ImageItem", 1, 0, "ImageFromBlob");

    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<QmlClipboardAdapter, 1>("ClipboardAdapter", 1, 0, "QClipboard");
    qmlRegisterType<XmlModel>("PersonalTypes", 1, 0, "XmlModel");
    qmlRegisterType<TeachingPlanning>("PersonalTypes", 1, 0, "TeachingPlanning");
    qmlRegisterType<ImageData>("PersonalTypes", 1, 0, "ImageData");
    qmlRegisterType<CryptographicHash, 1>("CryptographicHash", 1, 0, "CryptographicHash");
    qRegisterMetaType<XmlModel>("XmlModel");
    qmlRegisterType<DatabaseBackup>("PersonalTypes", 1, 0, "DatabaseBackup");
    qmlRegisterType<SqlTableModel2>("PersonalTypes", 1, 0, "SqlTableModel");
    qmlRegisterType<StandardPaths>("PersonalTypes", 1, 0, "StandardPaths");
    qmlRegisterType<MarkDownParser>("PersonalTypes", 1, 0, "MarkDownParser");
    qmlRegisterType<MarkDownItem>("PersonalTypes", 1, 0, "MarkDownItem");
    qmlRegisterType<MarkDownItemModel>("PersonalTypes", 1, 0, "MarkDownItemModel");
    qmlRegisterType<MarkDownViewer>("PersonalTypes", 1, 0, "MarkDownViewer");

    qRegisterMetaType<RubricDescriptorsModel>();

    QQmlApplicationEngine engine;

    QSqlDatabase db;

    DatabaseBackup back;

    if (dir.cd(specificPath)) {
        db = QSqlDatabase::addDatabase("QSQLITE");
        db.setDatabaseName(dir.absolutePath() + "/mainDatabase.sqlite");
        if (db.open()) {
            qDebug() << "Database opened!";
        }
    }

    SqlTableModel2 annotationsModel;
    SqlTableModel2 scheduleModel;
    SqlTableModel2 projectsModel;
    SqlTableModel2 resourcesModel;
    SqlTableModel2 resourcesAnnotationsModel;

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

    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    QXmlQuery query;
    QStringList result;
    QBuffer buffer;
    buffer.setData(QString("<planning><basicdata>hola</basicdata><basicdata>dos</basicdata></planning>").toUtf8());
    qDebug() << buffer.data();
    buffer.open(QIODevice::ReadOnly);

    query.bindVariable("myDoc", &buffer);
    query.setQuery("doc($myDoc)/planning/basicdata[1=1]/string()");
    query.evaluateTo(&result);
    qDebug() << "RESULT " << result;

    return app.exec();
}
