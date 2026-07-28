# Feature Specifications

## Maria Kindergarten ERP

Version: 1.0

---

# Purpose

This document defines the functional specifications of every module in Maria Kindergarten ERP.

This document is the official functional reference.

Whenever implementation differs from this document, this document takes priority unless explicitly updated.

---

# General Rules

Every feature must:

- Use SQLite
- Support RTL
- Follow Material 3
- Respect user permissions
- Be responsive
- Validate user input
- Display friendly error messages

---

# Authentication

## Login

Users can log in using:

- Username
- Password

After login:

Director → Dashboard

Teacher → Teacher Dashboard

Parent → Parent Dashboard (Future)

---

# Dashboard

## Director Dashboard

Displays:

- Total Children
- Total Teachers
- Total Sections
- Today's Attendance
- Pending Subscriptions
- Monthly Revenue
- Monthly Expenses
- Notifications
- Quick Actions

Quick Actions:

- Add Child
- Add Teacher
- Record Attendance
- Create Activity
- Add Expense
- Add Revenue

---

## Teacher Dashboard

Displays:

- Assigned Section
- Today's Attendance
- Today's Activities
- Daily Follow-up
- Notifications

---

# Children Module

Functions:

- Add Child
- Edit Child
- Delete Child
- Search
- Filter
- View Details

Child Information:

- Full Name
- Gender
- Birth Date
- Section
- Parent
- Medical Notes
- Allergies
- Registration Date
- Status

Validation:

Required:

- Name
- Birth Date
- Section

---

# Teachers Module

Functions:

- Add Teacher
- Edit Teacher
- Delete Teacher
- Search

Information:

- Full Name
- Username
- Phone
- Assigned Section
- Status

---

# Parents Module

Future implementation.

Functions:

- View Child
- Receive Notifications
- Receive Reports
- View Attendance
- View Photos

---

# Sections Module

Functions:

- Create Section
- Edit Section
- Delete Section

Information:

- Name
- Teacher
- Capacity
- Number of Children

---

# Attendance Module

Functions:

- Record Attendance
- Record Absence
- Check In
- Check Out

Attendance Status:

- Present
- Absent
- Late

Director:

Can edit all records.

Teacher:

Can edit only assigned classroom.

---

# Activities Module

Functions:

- Create Activity
- Edit Activity
- Delete Activity

Information:

- Title
- Description
- Date
- Classroom
- Teacher

---

# Daily Follow-up

Functions:

Create daily notes.

Examples:

- Behavior
- Learning
- Meals
- Sleep
- Health

Parents will receive these notes in future versions.

---

# Gallery Module

Functions:

- Upload Photos
- Delete Photos
- Approve Photos

Photo Status:

Pending

Approved

Rejected

Only approved photos are visible to parents.

---

# Expenses Module

Functions:

- Add Expense
- Edit Expense
- Delete Expense

Information:

- Title
- Category
- Amount
- Date
- Notes

Dashboard must update automatically.

---

# Revenue Module

Functions:

- Add Revenue
- Edit Revenue
- Delete Revenue

Dashboard statistics must update automatically.

---

# Subscription Module

Functions:

- Register Subscription
- Record Payment
- Search
- Filter

Information:

- Child
- Amount
- Due Date
- Payment Date
- Status

Statuses:

Paid

Pending

Overdue

Automatic alerts should appear for overdue subscriptions.

---

# Notifications Module

Notifications include:

- Attendance reminders
- Subscription reminders
- Activities
- Announcements

Future:

Push Notifications

---

# Reports Module

Generate reports for:

Children

Teachers

Attendance

Activities

Expenses

Revenue

Subscriptions

Reports support:

PDF

Excel

Printing

---

# Settings Module

Settings include:

Kindergarten Name

Logo

Address

Phone Number

Email

Language

Theme (Future)

Backup

Restore

---

# User Roles

## Director

Full permissions.

Can access every module.

---

## Teacher

Can access:

Attendance

Activities

Daily Follow-up

Gallery

Assigned Children

Cannot access:

Financial data

System Settings

User Management

---

## Parent

Future.

Can access only their child.

---

# Backup

Future:

Export SQLite

Import SQLite

Automatic Backup

Cloud Backup

---

# Maria AI

Future AI Assistant.

Capabilities:

Analyze attendance

Generate reports

Generate announcements

Suggest activities

Summarize financial data

Detect anomalies

Answer management questions

---

# Search

Every module should support:

Search

Sorting

Filtering

---

# Performance

Large lists should support:

Pagination (Future)

Lazy Loading

Optimized SQLite Queries

---

# Validation

Every form must validate:

Required fields

Date formats

Numeric values

Phone numbers

Duplicate records

---

# Error Handling

Every error should display:

Friendly Message

Retry Option

Logging

Never expose technical errors directly to users.

---

# Success Messages

Every successful action should display confirmation.

Examples:

Child Added Successfully

Attendance Saved

Expense Added

Subscription Updated

---

# Future Modules

- Parent Mobile App
- Online Synchronization
- Cloud Storage
- Multi-Kindergarten
- AI Analytics
- Calendar Integration
- SMS Integration
- WhatsApp Integration (where technically and legally supported)

---

# Acceptance Criteria

A feature is considered complete only if:

- Works correctly
- Uses SQLite
- Respects permissions
- Supports RTL
- Follows Material 3
- Passes flutter analyze
- Has no deprecated APIs
- Does not break existing functionality

---

# End of Feature Specifications