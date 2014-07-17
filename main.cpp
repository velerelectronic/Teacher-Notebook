#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "fileio.h"
#include "xmlmodel.h"
#include "teachingplanning.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<TeachingPlanning>("PersonalTypes", 1, 0, "TeachingPlanning");
    qmlRegisterType<XmlModel>("PersonalTypes", 1, 0, "XmlModel");
    qRegisterMetaType<XmlModel>("XmlModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();    
}
