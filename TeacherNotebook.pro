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
    databasebackup.cpp \
    standardpaths.cpp \
    XmlGrid/xmlgrid.cpp \
    MarkDownParser/markdownparser.cpp \
    SqlTableModel2/sqltablemodel.cpp \
    CryptographicHash/cryptographichash.cpp \
    RubricXml/rubricxml.cpp \
    RubricXml/rubriccriteria.cpp \
    RubricXml/rubricdescriptorsmodel.cpp \
    RubricXml/rubricassessmentmodel.cpp \
    RubricXml/rubricpopulationmodel.cpp

RESOURCES += qml.qrc \
    icons.qrc \
    editors.qrc \
    images.qrc \
    javascript.qrc \
    common.qrc \
    showdown.qrc \
    models.qrc \
    resourcesannotations.qrc \
    resourcesdocuments.qrc \
    resourcesfiles.qrc \
    resourcesrubrics.qrc \
    reseourcesmainbuttons.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    fileio.h \
    xmlmodel.h \
    teachingplanning.h \
    imagedata.h \
    databasebackup.h \
    standardpaths.h \
    XmlGrid/xmlgrid.h \
    MarkDownParser/markdownparser.h \
    ClipboardAdapter/qmlclipboardadapter.h \
    SqlTableModel2/sqltablemodel.h \
    CryptographicHash/cryptographichash.h \
    RubricXml/rubricxml.h \
    RubricXml/rubriccriteria.h \
    RubricXml/rubricdescriptorsmodel.h \
    RubricXml/rubricassessmentmodel.h \
    RubricXml/rubricpopulationmodel.h

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

OTHER_FILES += \
    android/AndroidManifest.xml

DISTFILES += \
    Versions/TeacherNotebook 69.apk \
    Versions/TeacherNotebook 70.apk
