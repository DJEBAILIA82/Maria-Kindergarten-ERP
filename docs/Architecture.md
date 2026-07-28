# Project Architecture

## Maria Kindergarten ERP

Version: 1.0

---

# Purpose

This document defines the official software architecture of Maria Kindergarten ERP.

Every contributor and every AI assistant must follow this architecture.

The objective is to keep the project:

- Stable
- Scalable
- Easy to maintain
- Easy to test
- Ready for future expansion

---

# Architecture Overview

The project follows a layered architecture.

```
UI (Pages)

↓

Widgets

↓

Services

↓

Repositories

↓

Database Layer

↓

SQLite
```

Each layer has one responsibility.

No layer should bypass another layer.

---

# Project Structure

```
lib/

├── database/
│
├── models/
│
├── repositories/
│
├── services/
│
├── pages/
│
├── widgets/
│
├── utils/
│
├── constants/
│
├── theme/
│
└── main.dart
```

---

# Layer Responsibilities

## 1. Models

Purpose:

Represent application data only.

Examples:

- Child
- Teacher
- Parent
- Section
- Attendance
- Activity
- Expense
- Revenue
- Subscription
- User
- Notification

Rules:

Models must never contain UI code.

Models should contain only:

- fields
- constructors
- copyWith()
- fromMap()
- toMap()

Business logic belongs elsewhere.

---

## 2. Database Layer

Responsible for:

- SQLite connection
- table creation
- migrations
- insert
- update
- delete
- query

Rules:

Never place business logic here.

Never place UI logic here.

---

## 3. Repositories

Repositories provide a clean interface between Services and SQLite.

Responsibilities:

- fetch data
- save data
- update data
- delete data

Repositories hide database implementation details.

---

## 4. Services

Services contain all business logic.

Examples:

AttendanceService

ExpenseService

TeacherService

ChildService

SubscriptionService

GalleryService

UserService

Rules:

Services may call repositories.

Services must never build widgets.

Services must never contain UI code.

---

## 5. Widgets

Reusable UI components.

Examples:

Cards

Buttons

Dialogs

Charts

Tables

Navigation widgets

Widgets should be reusable across multiple pages.

---

## 6. Pages

Pages display information.

Responsibilities:

- build UI
- receive user input
- call Services
- display results

Pages must never communicate directly with SQLite.

---

# Data Flow

Correct flow:

```
User

↓

Page

↓

Service

↓

Repository

↓

SQLite

↓

Repository

↓

Service

↓

Page

↓

User
```

Any shortcut is prohibited.

---

# State Management

The project should centralize business logic inside Services.

Avoid placing application state directly inside pages whenever possible.

Future state management libraries can be introduced without changing the architecture.

---

# Database Principle

SQLite is the only source of truth.

Never duplicate data inside widgets.

Never hardcode application data.

Cache may be used only for performance improvements.

---

# Dependency Rules

Allowed:

Page

↓

Service

↓

Repository

↓

Database

Not allowed:

Page → Database

Widget → Database

Widget → Repository

---

# Feature Organization

Each feature should be independent.

Example:

```
Children

- page
- service
- repository
- model
```

Avoid mixing unrelated features.

---

# Folder Responsibilities

## database/

SQLite helper

Database initialization

Database migrations

---

## models/

Application entities

No business logic

---

## repositories/

Database abstraction

CRUD operations

---

## services/

Business logic

Validation

Calculations

Permissions

---

## pages/

Application screens

Presentation layer

---

## widgets/

Reusable UI

Shared components

---

## utils/

Helper functions

Extensions

Utilities

Formatting

---

## constants/

Application constants

Never hardcode repeated values.

---

## theme/

Material 3

Colors

Typography

Spacing

Dark mode (future)

---

# Naming Convention

Files:

snake_case.dart

Classes:

PascalCase

Variables:

camelCase

Methods:

camelCase

Constants:

lowerCamelCase or static const

---

# Error Handling

Every layer should report meaningful errors.

Never silently ignore exceptions.

Log unexpected failures.

Show friendly messages to users.

---

# Performance Guidelines

Avoid:

- duplicate queries
- rebuilding entire pages
- loading unnecessary data

Prefer:

- lazy loading
- pagination (future)
- reusable widgets
- optimized SQLite queries

---

# Security Principles

Never store passwords as plain text.

Validate all user inputs.

Respect user permissions.

Never expose sensitive information.

---

# Testing Strategy

Every feature should be testable independently.

Business logic should remain inside Services to simplify testing.

---

# Scalability

The architecture should support future modules including:

- Parent Portal
- Cloud Sync
- Firebase Notifications
- AI Assistant (Maria AI)
- Online Database
- Multi-Kindergarten Support

These additions should not require major architectural changes.

---

# Golden Rules

1. Pages never access SQLite directly.

2. Widgets never contain business logic.

3. Services never contain UI.

4. Repositories isolate database access.

5. SQLite is the single source of truth.

6. No duplicated business logic.

7. No hardcoded data.

8. Prefer reusable components.

9. Keep every layer independent.

10. Every new feature must follow this architecture.

---

# End of Architecture Document