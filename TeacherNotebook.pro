QT += sql

# Add more folders to ship with the application, here
folder_01.source = qml/TeacherNotebook
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    fileio.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qml/TeacherNotebook/ArisenWidget.qml \
    qml/TeacherNotebook/AnnotationEditor.qml \
    qml/TeacherNotebook/AnnotationItem.qml \
    qml/TeacherNotebook/Storage.js \
    qml/TeacherNotebook/EvernoteLib.js \
    qml/TeacherNotebook/EditEvent.qml \
    android/AndroidManifest.xml \
    qml/TeacherNotebook/common/UseUnits.qml \
    qml/TeacherNotebook/common/BizoneButton.qml \
    qml/TeacherNotebook/AnnotationsList.qml \
    qml/TeacherNotebook/common/FormatDates.js

HEADERS += \
    fileio.h

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
