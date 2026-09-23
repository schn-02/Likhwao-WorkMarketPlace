# Likhwao-WorkMarketPlace

A handwritten work marketplace where **users** post writing jobs, **writers** complete them, and **admins** manage the platform.

## Tech Stack
Flutter | Spring Boot | MySQL | Firebase (Auth, Firestore, Storage) | Razorpay | JWT

## Structure
| Folder | Description |
| --- | --- |
| `Backend/` | Spring Boot REST API for User, Writer and Admin |
| `User_App/` | Flutter app for users |
| `Writer_App/` | Flutter app for writers |
| `Admin_App/` | Flutter app for admins |

## Highlights
- Role-based access with JWT authentication
- Job posting, assignment and order tracking
- Razorpay payments and Firebase file storage
- Admin panel for users, writers and orders

## Run Locally
```bash
# Backend
cd Backend && ./mvnw spring-boot:run

# Any Flutter app
cd User_App && flutter pub get && flutter run
```
> Secrets (DB credentials, JWT secret, Razorpay keys, Firebase config files) are not included. Add your own to run the project.

**Author:** Sachin ([@schn-02](https://github.com/schn-02))
