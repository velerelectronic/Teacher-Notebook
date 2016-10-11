TEMPLATE = app

QT += qml quick widgets \
    xml xmlpatterns \
    sql
CONFIG += c++11

SOURCES += main.cpp \
    databasebackup.cpp \
    fileio.cpp \
    imagedata.cpp \
    standardpaths.cpp \
    CryptographicHash/cryptographichash.cpp \
    MarkDownParser/markdownparser.cpp \
    RubricXml/rubricassessmentmodel.cpp \
    RubricXml/rubriccriteria.cpp \
    RubricXml/rubricdescriptorsmodel.cpp \
    RubricXml/rubricpopulationmodel.cpp \
    RubricXml/rubricxml.cpp \
    SqlTableModel2/sqltablemodel.cpp \
    TeachingPlanning/teachingplanning.cpp \
    TeachingPlanning/xmlmodel.cpp

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
    resourcesdatabase.qrc \
    resourcesdocuments.qrc \
    resourcesfeeds.qrc \
    resourcesfiles.qrc \
    resourcespagesfolder.qrc \
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

DISTFILES += \
    deployment.pri \
    TeacherNotebook.config \
    TeacherNotebook.files \
    TeacherNotebook.includes \
    MainForm.ui.qml \
    TeacherNotebook.creator.user \
    TeacherNotebook.pro.user \
    TeacherNotebook.pro.user.2.7pre1 \
    TeacherNotebook.creator \
    README.md \
    main.qml

HEADERS += \
    databasebackup.h \
    fileio.h \
    imagedata.h \
    standardpaths.h \
    ClipboardAdapter/qmlclipboardadapter.h \
    CryptographicHash/cryptographichash.h \
    MarkDownParser/markdownparser.h \
    RubricXml/rubricassessmentmodel.h \
    RubricXml/rubriccriteria.h \
    RubricXml/rubricdescriptorsmodel.h \
    RubricXml/rubricpopulationmodel.h \
    RubricXml/rubricxml.h \
    SqlTableModel2/sqltablemodel.h \
    TeachingPlanning/teachingplanning.h \
    TeachingPlanning/xmlmodel.h
