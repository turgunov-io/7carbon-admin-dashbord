@echo off
setlocal

echo [1/7] Cleaning project...
call flutter clean
if ERRORLEVEL 1 (
  echo Clean failed - folder may be locked. Continuing...
)

echo [2/7] Getting dependencies...
call flutter pub get
if ERRORLEVEL 1 (
  echo Failed to get dependencies. Check your connection or run 'flutter pub get' manually.
  exit /b %ERRORLEVEL%
)

echo [3/7] Formatting code...
call dart format .

echo [4/7] Analyzing code...
call flutter analyze

echo [5/7] Running tests...
if exist test (
  call flutter test
) else (
  echo No test directory found, skipping tests.
)

echo [6/7] Building web...
call flutter build web
if ERRORLEVEL 1 (
  echo APK build failed. Fix issues above and retry.
  exit /b %ERRORLEVEL%
)

echo [7/7] Done!
endlocalw