@echo off
set ANDROID_PREFS_ROOT=
set ANDROID_USER_HOME=C:\Users\Kawapechi GPS\.android
cd android
call gradlew.bat assembleRelease
