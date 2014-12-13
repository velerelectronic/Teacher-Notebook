TEMPLATE = app

QT += qml \
    quick \
    sql \
    xml xmlpatterns svg \
    multimedia

SOURCES += main.cpp \
    fileio.cpp \
    xmlmodel.cpp \
    teachingplanning.cpp \
    imagedata.cpp \
    sqltablemodel.cpp \
    databasebackup.cpp \
    standardpaths.cpp \
    XmlGrid/xmlgrid.cpp \
    MarkDownParser/markdownparser.cpp

RESOURCES += qml.qrc \
    icons.qrc \
    editors.qrc \
    images.qrc \
    javascript.qrc \
    common.qrc \
    showdown.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    fileio.h \
    xmlmodel.h \
    teachingplanning.h \
    imagedata.h \
    sqltablemodel.h \
    databasebackup.h \
    standardpaths.h \
    XmlGrid/xmlgrid.h \
    MarkDownParser/markdownparser.h

OTHER_FILES += \
    android/AndroidManifest.xml
