#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "fileio.h"
#include "XmlReader.h"
#include "xmlmodel.h"
#include "programacioaulamodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<XmlModel, 1>("PersonalTypes", 1, 0, "XmlModel");
    qRegisterMetaType<XmlModel>("XmlModel");
    qmlRegisterType<ProgramacioAulaModel, 1>("PersonalTypes", 1, 0, "ProgramacioAulaModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();    
}
