# UI Guidelines

## Maria Kindergarten ERP

Version: 1.0

---

# Purpose

This document defines the official user interface standards for Maria Kindergarten ERP.

Every new screen, dialog, widget, and component must follow these guidelines.

The objective is to maintain a consistent, modern, and professional design.

---

# Design Philosophy

The application should feel:

- Simple
- Clean
- Modern
- Fast
- Professional
- Friendly
- Easy to use

The interface is designed for kindergarten administrators and teachers.

Complex interfaces should always be avoided.

---

# Design Language

Use:

- Flutter Material 3

Avoid mixing different design styles.

Every screen should look like part of the same application.

---

# Primary Language

Arabic

RTL must be supported everywhere.

Future:

- French
- English

Every layout should be prepared for multilingual support.

---

# Color System

Use a consistent color palette across the application.

Suggested colors:

Primary

- Blue

Secondary

- Green

Success

- Green

Warning

- Orange

Error

- Red

Information

- Blue

Background

- Light Gray / White

Never use random colors.

---

# Typography

Use one font family across the application.

Recommended:

- Cairo

or

- Noto Kufi Arabic

Font sizes should remain consistent.

Example:

App Title

24

Section Title

20

Card Title

18

Body

16

Caption

14

Small Text

12

---

# Spacing

Use consistent spacing.

Recommended spacing:

4

8

12

16

20

24

32

Avoid random spacing values.

---

# Border Radius

Use rounded corners consistently.

Recommended:

12

16

20

Do not mix different corner styles.

---

# Elevation

Cards should use subtle elevation.

Avoid excessive shadows.

Modern UI should remain clean.

---

# Buttons

Buttons must be consistent.

Primary Button

- Filled

Secondary Button

- Outlined

Danger Button

- Red

Success Button

- Green

Buttons should have:

- rounded corners

- consistent padding

- consistent height

---

# Icons

Use Material Icons.

Avoid mixing icon libraries.

Icons should clearly represent their action.

---

# Cards

Every information block should be inside a Card.

Cards should contain:

- title

- optional icon

- content

- actions if necessary

Cards should have consistent padding.

---

# Forms

Forms should be easy to complete.

Every field should have:

- label

- hint

- validation

Required fields should be clearly indicated.

---

# Input Fields

Use:

OutlinedTextField style.

Avoid inconsistent field styles.

---

# Dialogs

Dialogs should contain:

- title

- description

- primary action

- cancel action

Avoid large dialogs.

---

# Navigation

Navigation should remain simple.

Drawer:

Administrative pages.

Bottom Navigation:

Frequently used pages.

Avoid deep navigation hierarchies.

---

# Dashboard

Dashboard should display:

- statistics

- quick actions

- notifications

- recent activity

Information should be easy to understand.

---

# Tables

Tables should support:

- sorting

- searching

- filtering

- pagination (future)

Avoid horizontal scrolling whenever possible.

---

# Lists

Lists should support:

- search

- filters

- refresh

- empty state

---

# Empty States

Every empty page should display:

- illustration (optional)

- explanation

- action button

Example:

"No children have been added yet."

---

# Loading States

Always display progress indicators.

Avoid frozen screens.

---

# Error States

Every error should display:

- friendly message

- retry button

Never expose technical exceptions to users.

---

# Success Messages

Display confirmation after successful operations.

Examples:

Child added successfully.

Attendance saved.

Photo uploaded.

---

# Notifications

Notifications should be:

- short

- clear

- actionable

Avoid long messages.

---

# RTL Support

Every screen must fully support RTL.

Alignment

Icons

Navigation

Tables

Forms

Everything should work correctly in Arabic.

---

# Accessibility

Support:

- readable font sizes

- sufficient color contrast

- large touch targets

- screen readers (future)

---

# Animations

Animations should be subtle.

Recommended duration:

150–300 ms

Avoid unnecessary animations.

---

# Images

Photos should use:

- rounded corners

- proper aspect ratio

- lazy loading when possible

---

# Gallery

Gallery cards should display:

- image

- child name

- activity

- upload date

- approval status

---

# Reports

Reports should use:

- charts

- summary cards

- export buttons

Avoid cluttered layouts.

---

# Consistency Rules

Every page must use:

- same colors

- same typography

- same buttons

- same cards

- same spacing

- same icons

The application should look like one unified product.

---

# Responsive Design

Support:

- Phones

- Tablets

Future:

- Desktop

Avoid fixed widths whenever possible.

---

# Golden Rules

1. Keep the interface simple.

2. Keep the interface consistent.

3. Prefer clarity over decoration.

4. Support RTL completely.

5. Follow Material 3.

6. Avoid visual clutter.

7. Every new page must follow this document.

---

# End of UI Guidelines