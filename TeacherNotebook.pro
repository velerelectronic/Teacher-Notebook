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
    imagedata.cpp \
    imagefromblob.cpp

RESOURCES += qml.qrc \
    common.qrc \
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
    showdown.qrc \
    resourcescards.qrc \
    resourcesconnections.qrc \
    resourcesworkflow.qrc \
    structure.qrc \
    structure.qrc \
    resourcessuggestions.qrc \
    resourcessimpleannotations.qrc

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
    TeacherNotebook.creator.user \
    TeacherNotebook.pro.user \
    TeacherNotebook.pro.user.2.7pre1 \
    TeacherNotebook.creator \
    README.md \
    android/AndroidManifest.xml \
    android/build.xml \
    android/version.xml \
    android/local.properties \
    android/proguard-project.txt \
    android/project.properties \
    android/res/drawable-hdpi/icon.png \
    android/res/drawable-ldpi/icon.png \
    android/res/drawable-mdpi/icon.png \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    resourcessuggestions.qml

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
    imagedata.h \
    TeachingPlanning/xmlmodel.h \
    imagefromblob.h

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

DISTFILES += \
    qml/DetailedScheduleModel.qml \
    modules/plannings/EditActionItem.qml \
    images/esquirol high.png \
    images/esquirol low.png \
    images/esquirol medium.png
