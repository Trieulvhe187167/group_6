@echo off
echo Starting Hotel Management System...
echo.

:: Start Spring Boot in background
start /B mvn spring-boot:run

:: Wait for application to start (adjust time if needed)
echo Waiting for application to start...
timeout /t 5 /nobreak >nul

:: Open browser
echo Opening browser...
start http://localhost:8080

echo.
echo Application is running at http://localhost:8080
echo Press Ctrl+C to stop the application
echo.

:: Keep window open to see logs
mvn spring-boot:run