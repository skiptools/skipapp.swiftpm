#!/bin/bash -ve
MODULE="AppDemo"
PACKAGE="app.demo"

cd Packages/Skip/skipapp.swiftpm.output/${MODULE}Kt/skip-transpiler
gradle --console=plain assembleDebug
adb install -r ${MODULE}/build/outputs/apk/debug/${MODULE}-debug.apk
adb shell am start-activity -S -W -n ${PACKAGE}/.MainActivity
# Stop the app when this process is killed
stopApp() {
    adb shell am force-stop ${PACKAGE}
}
trap stopApp EXIT INT

# stream the app log to the console
adb logcat "${PACKAGE}:V" "*:S"
