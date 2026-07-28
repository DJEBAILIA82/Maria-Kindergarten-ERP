# Coding Rules

## Maria Kindergarten ERP

Version: 1.0

---

# Purpose

This document defines the mandatory coding rules for the Maria Kindergarten ERP project.

Every developer and every AI assistant must follow these rules.

These rules are mandatory.

---

# General Principles

Always prioritize:

- Stability
- Readability
- Maintainability
- Performance
- Scalability

Never sacrifice code quality for speed.

---

# Before Writing Code

Always:

1. Read the related files.

2. Understand existing code.

3. Identify the root cause.

4. Explain the solution.

Only then modify code.

Never guess.

---

# Root Cause Policy

Never fix symptoms.

Always fix the real cause.

Temporary fixes are forbidden.

---

# Flutter Rules

Always use:

- Material 3
- const whenever possible
- final whenever possible

Prefer:

- StatelessWidget
- reusable widgets
- composition

Avoid:

- deprecated APIs
- unnecessary StatefulWidgets

---

# File Organization

One file should have one clear responsibility.

Avoid very large files.

Split reusable widgets into separate files.

---

# Services

Business logic belongs inside Services.

Examples:

- AttendanceService

- ChildService

- ExpenseService

- GalleryService

- UserService

Never place UI code inside services.

---

# Pages

Pages are responsible for:

- displaying data

- receiving user input

- calling services

Pages must never contain business logic.

---

# Widgets

Widgets should be reusable.

Avoid duplicate widgets.

Keep widgets small.

---

# Database Rules

SQLite is the single source of truth.

Never:

- hardcode users

- hardcode children

- hardcode statistics

- hardcode settings

Every page must load data from SQLite.

---

# Naming Rules

Files:

snake_case.dart

Classes:

PascalCase

Variables:

camelCase

Methods:

camelCase

---

# UI Rules

All pages must use:

- same colors

- same typography

- same spacing

- same buttons

- same dialogs

- same border radius

---

# Error Handling

Always:

- catch exceptions

- explain errors

- log errors

- show friendly messages

Never ignore exceptions.

---

# Performance

Avoid:

- duplicate database queries

- unnecessary rebuilds

- loading unused data

Optimize SQLite queries whenever possible.

---

# Security

Never store passwords as plain text.

Validate every user input.

Respect user permissions.

---

# Code Review Checklist

Every completed task must satisfy:

- flutter analyze has no errors

- no deprecated APIs

- no duplicate code

- no unnecessary rebuilds

- no memory leaks

- SQLite remains the source of truth

---

# Commit Policy

Each commit should contain one logical change.

Avoid modifying unrelated files.

---

# Golden Rules

1. Keep code clean.

2. Keep widgets reusable.

3. Keep business logic inside services.

4. Never duplicate logic.

5. Never break existing features.

6. Fix the root cause.

7. Explain every important change.

8. Wait for approval before major refactoring.

---

# End of Coding Rules