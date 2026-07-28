# Database Documentation

## Maria Kindergarten ERP

Version: 1.0

---

# Database Engine

SQLite

SQLite is the official and only source of truth.

No page should contain hardcoded application data.

---

# Database Principles

The database must remain:

- Fast

- Stable

- Consistent

- Extensible

---

# Main Tables

## users

Stores system users.

Examples:

- Director

- Teacher

Fields:

- id

- fullName

- username

- passwordHash

- role

- sectionId

- isActive

- createdAt

- updatedAt

---

## children

Stores registered children.

Fields:

- id

- fullName

- gender

- birthDate

- address

- parentId

- sectionId

- notes

- createdAt

---

## parents

Stores parents.

Fields:

- id

- fatherName

- motherName

- phone

- email

- address

---

## sections

Stores classrooms.

Fields:

- id

- name

- teacherId

- capacity

---

## attendance

Stores attendance history.

Fields:

- id

- childId

- date

- status

- checkIn

- checkOut

- notes

---

## activities

Stores classroom activities.

Fields:

- id

- title

- description

- date

- teacherId

---

## photos

Stores gallery photos.

Fields:

- id

- imagePath

- childId

- activityId

- uploadedBy

- approvalStatus

- createdAt

Approval Status:

- Pending

- Approved

- Rejected

---

## expenses

Stores expenses.

Fields:

- id

- title

- amount

- category

- date

- notes

---

## revenues

Stores revenues.

Fields:

- id

- title

- amount

- date

- notes

---

## subscriptions

Stores subscriptions.

Fields:

- id

- childId

- amount

- dueDate

- paymentDate

- status

- notes

---

## notifications

Stores notifications.

Fields:

- id

- title

- message

- createdAt

- isRead

---

## settings

Stores application settings.

Examples:

- kindergarten name

- phone number

- logo

- address

- theme

---

# Relationships

users

↓

sections

↓

children

↓

attendance

children

↓

subscriptions

children

↓

photos

activities

↓

photos

---

# Rules

Never hardcode users.

Never hardcode sections.

Never hardcode children.

Never duplicate data.

Always use IDs as relationships.

---

# Future Tables

Planned:

- backups

- audit_logs

- AI_history

- cloud_sync

---

# Migration Policy

Database changes must:

- preserve existing data

- include migration scripts

- avoid breaking compatibility

---

# Backup Policy

Future versions should support:

- Export SQLite

- Import SQLite

- Automatic Backup

---

# Golden Rules

1. SQLite is the source of truth.

2. Use IDs for relationships.

3. Never duplicate records.

4. Never hardcode data.

5. Preserve compatibility.

6. Design for future expansion.

---

# End of Database Documentation