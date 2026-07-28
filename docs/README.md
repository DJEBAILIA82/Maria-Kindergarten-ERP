# Maria Kindergarten ERP

> Professional Kindergarten Management System built with Flutter & SQLite

---

# Overview

Maria Kindergarten ERP is a complete management system designed to simplify the daily operations of a kindergarten.

The application provides an integrated environment for managing children, teachers, classrooms, attendance, finances, activities, reports, notifications and administration.

The system is designed to be fast, stable, scalable and easy to maintain.

---

# Main Technologies

- Flutter
- Dart
- SQLite
- Material 3

Future technologies may include:

- Cloud Backup
- AI Assistant (Maria AI)
- Firebase Notifications
- Online Synchronization

---

# Primary Language

Current:

- Arabic (RTL)

Planned:

- French
- English

The application must fully support Right-to-Left layouts.

---

# Main Objectives

The project aims to provide a complete ERP solution for kindergarten management.

Main objectives include:

- Child management
- Teacher management
- Parent management
- Classroom management
- Attendance management
- Daily follow-up
- Activities management
- Gallery management
- Financial management
- Subscription management
- Reports
- Notifications
- Backup & Restore
- Artificial Intelligence Assistant

---

# User Roles

## Director

The Director has full permissions.

Responsibilities:

- Manage users
- Manage teachers
- Manage children
- Manage classrooms
- Manage subscriptions
- Manage expenses
- Manage revenues
- Manage reports
- Configure settings
- Approve gallery photos
- View statistics

---

## Teacher

Teachers have limited permissions.

Can:

- Record attendance
- Manage classroom activities
- Upload photos
- View children in assigned classroom
- Write daily follow-up notes

Cannot:

- Access financial data
- Modify system settings
- Manage users

---

## Parent (Future)

Parents will have access only to their own child.

Future capabilities:

- Attendance history
- Daily reports
- Notifications
- Activity photos
- Teacher messages

---

# Main Modules

The application currently includes or plans to include:

- Authentication
- Dashboard
- Children
- Teachers
- Parents
- Classrooms
- Attendance
- Activities
- Daily Follow-up
- Photo Gallery
- Notifications
- Expenses
- Revenues
- Subscriptions
- Reports
- Settings
- Backup
- Restore
- Maria AI

---

# Database

SQLite is the single source of truth.

Every page must retrieve its data from SQLite.

Hardcoded application data is not allowed.

---

# Project Structure

```
lib/

database/
models/
repositories/
services/
pages/
widgets/
utils/
```

---

# Architecture Principles

The project follows a layered architecture.

Pages

↓

Widgets

↓

Services

↓

Repositories

↓

SQLite Database

Business logic must remain inside Services.

Pages must never communicate directly with SQLite.

---

# UI Principles

The interface should always remain:

- Simple
- Modern
- Consistent
- Responsive
- RTL Friendly
- Material 3 compliant

All screens should follow the same design language.

---

# Coding Principles

The project follows these principles:

- Clean Architecture
- Reusable Components
- Small Widgets
- Maintainable Code
- No Duplicate Logic
- No Hardcoded Values

---

# Performance Goals

The application should:

- Start quickly
- Scroll smoothly
- Avoid unnecessary rebuilds
- Minimize memory usage
- Optimize database queries

---

# Security

Passwords must never be stored as plain text.

User permissions must always be respected.

Input validation is mandatory.

SQLite operations must be secure.

---

# Reports

Reports should support:

- PDF
- Excel

Reports must use real SQLite data.

---

# Notifications

Notifications should be generated dynamically.

No hardcoded notifications.

---

# Future Roadmap

Planned improvements include:

- Cloud synchronization
- Parent mobile application
- AI-powered assistant (Maria AI)
- Smart reports
- Financial analytics
- Calendar integration
- Automated backups

---

# Development Rules

Every change must:

- Improve quality
- Preserve stability
- Keep backward compatibility
- Avoid breaking existing features

Temporary fixes are not acceptable.

Always fix the root cause.

---

# Documentation

Additional documentation is available in the `/docs` directory.

Important documents include:

- Architecture.md
- CodingRules.md
- Database.md
- UI_Guidelines.md
- Security.md
- Roadmap.md
- CHANGELOG.md
- KNOWN_ISSUES.md

---

# License

Internal project.

Maria Kindergarten ERP.

All rights reserved.