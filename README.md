# Event Management Application - Setup Guide

## Preparation

Ensure Docker is installed and running on your machine.

Install Visual Studio and Visual Studio Code.

Have an Android Emulator or a physical device for mobile testing.

## Backend Setup

Start Docker.

Open the folder event_management_backend.

Open event_management_backend.sln in Visual Studio.

Click on the Docker Compose button (the one with the green play icon).

Wait for Docker to download and set up the necessary dependencies.

## Frontend Setup

Open the folder event_management_frontend in Visual Studio Code.

Navigate to lib/config.dart.

Modify the configuration
If you want to run on a emulator device, change your IP to 10.0.2.2.

If it is a real device, change it to your device IP.

If it is web, change to localhost.

Open terminal and run command "flutter pub get"

Running the Application

### On Mobile

Choose your emulator device or connect a real device.

Run the application.

### On Web

Choose a browser.

Run the application.

## Notes

Ensure that the backend is fully set up before running the frontend.

If running on a mobile device, make sure your device and machine are on the same network for proper communication.

## Account in app

usernme(email): nguyenxuantrieu12082003@gmail.com
password: 123456789123456789