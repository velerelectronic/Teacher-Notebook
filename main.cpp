#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "fileio.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();    
}
