@echo off
set ANDROID_PREFS_ROOT=
set ANDROID_USER_HOME=C:\Users\Kawapechi GPS\.android
cd android
call gradlew.bat assembleCalculatorRelease -Ptarget=lib/main_calculator.dart
call gradlew.bat assembleFinanceRelease -Ptarget=lib/main_finance.dart
call gradlew.bat assembleImageRelease -Ptarget=lib/main_image.dart
call gradlew.bat assembleFullRelease -Ptarget=lib/main.dart
