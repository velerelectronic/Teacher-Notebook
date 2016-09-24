TEMPLATE = app

QT += core \
    gui \
    sql \
    xml xmlpatterns svg \
    multimedia \
    qml

SOURCES += main.cpp \
    fileio.cpp \
    imagedata.cpp \
    databasebackup.cpp \
    standardpaths.cpp \
    MarkDownParser/markdownparser.cpp \
    SqlTableModel2/sqltablemodel.cpp \
    CryptographicHash/cryptographichash.cpp \
    RubricXml/rubricxml.cpp \
    RubricXml/rubriccriteria.cpp \
    RubricXml/rubricdescriptorsmodel.cpp \
    RubricXml/rubricassessmentmodel.cpp \
    RubricXml/rubricpopulationmodel.cpp \
    TeachingPlanning/teachingplanning.cpp \
    TeachingPlanning/xmlmodel.cpp

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
    reseourcesmainbuttons.qrc \
    resourcesbasic.qrc \
    resourcesteachingplanning.qrc \
    resourcesfeeds.qrc \
    resourcesdatabase.qrc \
    resourcesannotations2.qrc \
    resourcesrelatedlists.qrc \
    resourcespagesfolder.qrc \
    resourcescalendar.qrc \
    resourceswhiteboard.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    fileio.h \
    imagedata.h \
    databasebackup.h \
    standardpaths.h \
    MarkDownParser/markdownparser.h \
    ClipboardAdapter/qmlclipboardadapter.h \
    SqlTableModel2/sqltablemodel.h \
    CryptographicHash/cryptographichash.h \
    RubricXml/rubricxml.h \
    RubricXml/rubriccriteria.h \
    RubricXml/rubricdescriptorsmodel.h \
    RubricXml/rubricassessmentmodel.h \
    RubricXml/rubricpopulationmodel.h \
    TeachingPlanning/teachingplanning.h \
    TeachingPlanning/xmlmodel.h

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

OTHER_FILES += \
    android/AndroidManifest.xml

DISTFILES += \
    Versions/TeacherNotebook 69.apk \
    Versions/TeacherNotebook 70.apk
