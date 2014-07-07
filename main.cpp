#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "fileio.h"
#include "XmlReader.h"
#include "xmlmodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<XmlReader, 1>("XmlReader", 1, 0, "XmlReader");
    qmlRegisterType<XmlModel, 1>("XmlModel", 1, 0, "XmlModel");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();    
}
