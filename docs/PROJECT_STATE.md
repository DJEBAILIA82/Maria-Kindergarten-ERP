# PROJECT_STATE.md

# Maria Kindergarten ERP
Current Project State

---

# Project Status

Status: Active Development

Current Version: v0.9

Platform:
- Flutter
- SQLite
- Material 3

---

# Current Goal

تحويل المشروع إلى نظام احترافي متكامل لإدارة رياض الأطفال مع الحفاظ على جميع الميزات الحالية وعدم كسر أي وظيفة تعمل.

---

# Completed

✅ إنشاء قاعدة البيانات SQLite.

✅ نظام تسجيل الدخول.

✅ إدارة الأطفال.

✅ إدارة المعلمات.

✅ إدارة الحضور.

✅ إدارة الأنشطة.

✅ معرض الصور.

✅ نظام موافقة المديرة على الصور.

✅ إدارة الاشتراكات.

✅ إدارة المصروفات.

✅ الرسائل.

✅ صفحة الإعدادات الأساسية.

✅ توثيق المشروع بالكامل.

---

# Current Known Issues

1. بطاقة المديرة في صفحة الإعدادات لا تحتوي على زر (...) لتغيير كلمة المرور.

Status:
Pending.

---

2. عند إضافة قسم جديد يظهر اسم القسم بشكل غير صحيح.

Example:

قسم قسم قبل التمهيدي

بينما القسم الذي أُدخل هو:

قسم سنة أولى

Status:
Pending Investigation.

---

3. مراجعة شاملة لـ flutter analyze.

Status:
Pending.

---

# Architecture

Current Architecture:

- Models
- Services
- Database
- Pages
- Widgets

SQLite is the only Source of Truth.

No hardcoded data should remain if it exists inside SQLite.

---

# Development Rules

Before modifying any file:

1. Read CLAUDE.md

2. Read docs/INDEX.md

3. Read only the documents related to the requested task.

4. Explain the modification plan.

5. Wait for approval.

6. Modify the minimum number of files.

7. Verify flutter analyze.

8. Update CHANGELOG.md.

---

# Current Priority

Priority 1

Full project analysis without modifications.

Priority 2

Fix flutter analyze.

Priority 3

Remove Deprecated APIs.

Priority 4

Architecture cleanup.

Priority 5

Dashboard redesign.

---

# Files Already Available

CLAUDE.md

docs/

README.md

Architecture.md

CodingRules.md

Database.md

DesignSystem.md

FeatureSpecifications.md

DevelopmentWorkflow.md

Roadmap.md

Security.md

CHANGELOG.md

KNOWN_ISSUES.md

INDEX.md

---

# Notes

The project must evolve incrementally.

No feature should be removed.

No working functionality should break.

All changes must remain compatible with the entire project.

Think long-term.

Maintainability has priority over speed.

---

Last Updated

YYYY-MM-DD