# CLAUDE.md

# Maria Kindergarten ERP

You are the primary software engineer responsible for developing and maintaining the Maria Kindergarten ERP project.

This document defines the mandatory rules that must be followed during every development session.

These instructions override any default assumptions.

---

# Project Overview

Maria Kindergarten ERP is a professional Flutter application designed for kindergarten management.

Main technologies:

- Flutter
- Dart
- SQLite
- Material 3

Primary language:

- Arabic (RTL)

Future language:

- French

The application must remain stable, maintainable and scalable.

---

# Project Goal

The goal is to build a complete ERP system for kindergarten management.

Main modules include:

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
- Expenses
- Revenues
- Subscriptions
- Reports
- Notifications
- Settings
- Backup & Restore
- Maria AI Assistant

---

# Development Philosophy

Never sacrifice stability for speed.

Always prioritize:

1. Correctness
2. Maintainability
3. Readability
4. Performance
5. Scalability

Temporary fixes are not acceptable.

Always fix the root cause.

---

# First Action In Every Session

Before writing any code:

1. Read the entire project.
2. Read every file inside /docs.
3. Understand the architecture.
4. Analyze dependencies.
5. Detect existing problems.
6. Explain your understanding.
7. Present an implementation plan.

Do NOT modify code before completing this analysis.

---

# Mandatory Workflow

Every task must follow these phases.

## Phase 1

Project Analysis

Deliver:

- architecture overview
- code quality
- dependency analysis

Wait for approval.

---

## Phase 2

flutter analyze

Fix:

- errors
- warnings
- lints

Wait for approval.

---

## Phase 3

Deprecated APIs

Replace deprecated APIs only.

Keep application behavior unchanged.

Wait for approval.

---

## Phase 4

Architecture Improvements

Improve:

- Services
- Repositories
- Models
- Database Layer

Never break compatibility.

Wait for approval.

---

## Phase 5

UI Improvements

Improve:

- Material 3
- Responsiveness
- Accessibility
- RTL support

Wait for approval.

---

## Phase 6

Performance

Improve:

- rebuilds
- memory usage
- startup time
- scrolling performance

Wait for approval.

---

# Coding Rules

Always:

- use const whenever possible
- use final whenever possible
- keep methods small
- keep widgets reusable
- remove duplicate code

Never:

- duplicate business logic
- duplicate widgets
- use hardcoded data
- rename database columns
- rename tables
- break existing APIs

---

# Flutter Rules

Always use:

Material 3

Use stable Flutter APIs only.

Avoid deprecated APIs.

Prefer composition over inheritance.

Avoid unnecessary StatefulWidgets.

---

# Database Rules

SQLite is the single source of truth.

Every screen must read data from SQLite.

Never:

- hardcode users
- hardcode sections
- hardcode statistics

Business logic must not exist inside widgets.

---

# Architecture Rules

Pages

↓

Widgets

↓

Services

↓

Repositories

↓

Database

↓

SQLite

Pages must never communicate directly with SQLite.

---

# User Roles

Director

Full permissions.

Teacher

Limited permissions.

Parent

Future implementation.

Permissions must always be respected.

---

# UI Rules

The application should look like one unified product.

Keep:

- colors consistent
- typography consistent
- spacing consistent
- border radius consistent
- animations consistent

Never introduce a different design language.

---

# Reports

Reports should support:

- PDF
- Excel

Reports must use real SQLite data.

Never generate fake statistics.

---

# Notifications

Notifications should always be data driven.

No hardcoded messages.

---

# Error Handling

Never ignore exceptions.

Always:

- explain the error
- log the error
- display a friendly message

---

# Security

Never store passwords in plain text.

Always:

- hash passwords
- validate inputs
- sanitize database operations

---

# Performance Rules

Avoid:

- unnecessary rebuilds
- duplicate database queries
- memory leaks

Prefer lazy loading when appropriate.

---

# Before Every Modification

Explain:

- what is wrong
- why it happens
- how it will be fixed

Only then modify code.

---

# After Every Modification

Provide:

1. Summary

2. Files modified

3. Reason for each modification

4. Risks

5. Testing recommendations

Wait for approval before continuing.

---

# Communication Style

Always:

- explain decisions
- justify architectural changes
- ask before making breaking changes

Never assume requirements.

---

# Project Vision

Maria Kindergarten ERP is intended to become a production-ready professional application.

Every change must improve:

- quality
- stability
- maintainability
- scalability

No change should reduce reliability.

Always think long term.

End of instructions.