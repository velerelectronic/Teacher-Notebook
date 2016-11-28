TEMPLATE = app

QT += qml quick widgets \
    xml xmlpatterns svg \
    gui \
    multimedia \
    sql \
    core

CONFIG += c++11

SOURCES += main.cpp \
    RubricXml/rubricassessmentmodel.cpp \
    RubricXml/rubriccriteria.cpp \
    RubricXml/rubricdescriptorsmodel.cpp \
    RubricXml/rubricpopulationmodel.cpp \
    RubricXml/rubricxml.cpp \
    TeachingPlanning/teachingplanning.cpp \
    TeachingPlanning/xmlmodel.cpp \
    CryptographicHash/cryptographichash.cpp \
    MarkDownParser/markdownparser.cpp \
    SqlTableModel2/sqltablemodel.cpp \
    databasebackup.cpp \
    standardpaths.cpp \
    fileio.cpp \
    imagedata.cpp

RESOURCES += qml.qrc \
    common.qrc \
    components.qrc \
    editors.qrc \
    icons.qrc \
    images.qrc \
    javascript.qrc \
    models.qrc \
    reseourcesmainbuttons.qrc \
    resourcesannotations.qrc \
    resourcesannotations2.qrc \
    resourcesbasic.qrc \
    resourcescalendar.qrc \
    resourceschecklists.qrc \
    resourcesdatabase.qrc \
    resourcesdocuments.qrc \
    resourcesfeeds.qrc \
    resourcesfiles.qrc \
    resourcespagesfolder.qrc \
    resourcesplannings.qrc \
    resourcesrelatedlists.qrc \
    resourcesrubrics.qrc \
    resourcesteachingplanning.qrc \
    resourceswhiteboard.qrc \
    showdown.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    RubricXml/rubricassessmentmodel.h \
    RubricXml/rubriccriteria.h \
    RubricXml/rubricdescriptorsmodel.h \
    RubricXml/rubricpopulationmodel.h \
    RubricXml/rubricxml.h \
    TeachingPlanning/teachingplanning.h \
    TeachingPlanning/xmlmodel.h \
    CryptographicHash/cryptographichash.h \
    MarkDownParser/markdownparser.h \
    SqlTableModel2/sqltablemodel.h \
    ClipboardAdapter/qmlclipboardadapter.h \
    databasebackup.h \
    standardpaths.h \
    fileio.h \
    imagedata.h

DISTFILES += \
    qml/DetailedScheduleModel.qml \
    modules/plannings/EditActionItem.qml \
    images/esquirol high.png \
    images/esquirol low.png \
    images/esquirol medium.png
