#include <QtGui/QGuiApplication>
#include <QtQml>
#include "qtquick2applicationviewer.h"


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QtQuick2ApplicationViewer viewer;
    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");

    viewer.setMainQmlFile(QStringLiteral("qml/TeacherNotebook/main.qml"));
    viewer.showExpanded();

    return app.exec();
}
