TEMPLATE = app

QT += qml quick sql xml xmlpatterns svg

SOURCES += main.cpp \
    fileio.cpp \
    xmlmodel.cpp \
    teachingplanning.cpp

RESOURCES += qml.qrc \
    icons.qrc \
    editors.qrc \
    images.qrc \
    javascript.qrc \
    common.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    fileio.h \
    xmlmodel.h \
    teachingplanning.h
