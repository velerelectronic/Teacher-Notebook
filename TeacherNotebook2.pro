TEMPLATE = app

QT += qml quick sql

SOURCES += main.cpp \
    fileio.cpp

RESOURCES += qml.qrc \
    icons.qrc \
    common.qrc \
    editors.qrc \
    images.qrc \
    javascript.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    fileio.h
