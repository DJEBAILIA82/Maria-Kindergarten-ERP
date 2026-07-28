import '../activity_service.dart';
import '../attendance_report_service.dart';
import '../attendance_service.dart';
import '../child_service.dart';
import '../expense_service.dart';
import '../models/child.dart';
import '../models/user.dart';
import '../section_service.dart';
import '../subscription_service.dart';
import '../user_service.dart';
import 'photo_service.dart';

/// طفل واحد ضمن بطاقة "الأطفال الذين يحتاجون متابعة"، مع سبب المتابعة.
class FollowUpChild {
  final String id;
  final String fullName;
  final String section;
  final String reason;

  FollowUpChild({
    required this.id,
    required this.fullName,
    required this.section,
    required this.reason,
  });
}

/// نقطة بيانات حضور ليوم واحد (لرسم آخر 7 أيام).
class DailyAttendancePoint {
  final String date;
  final int present;
  final int absent;

  DailyAttendancePoint({
    required this.date,
    required this.present,
    required this.absent,
  });
}

/// نقطة بيانات مالية لشهر واحد (لرسم الإيرادات مقابل المصروفات).
class MonthlyFinancePoint {
  final String month;
  final double revenue;
  final double expense;

  MonthlyFinancePoint({
    required this.month,
    required this.revenue,
    required this.expense,
  });
}

/// كل بيانات لوحة القيادة، جاهزة للعرض مباشرة.
class DashboardData {
  // إحصائيات الروضة
  final int totalChildren;
  final int totalStaff;
  final int totalSections;

  // إحصائيات اليوم
  final int presentToday;
  final int absentToday;

  // المالية (الشهر الحالي)
  final double revenueThisMonth;
  final double expensesThisMonth;
  final double profitThisMonth;

  // التنبيهات
  final int pendingPhotosCount;
  final int lateSubscriptionsCount;

  // نشاط الأقسام
  final String? mostActiveSection;
  final int mostActiveSectionCount;
  final String? leastActiveSection;
  final int leastActiveSectionCount;
  final Map<String, int> activityCountBySection;

  // المتابعة
  final List<FollowUpChild> childrenNeedingFollowUp;

  // الرسوم البيانية
  final List<DailyAttendancePoint> attendanceLast7Days;
  final List<MonthlyFinancePoint> financeLast6Months;
  final Map<String, int> childrenBySection;

  const DashboardData({
    required this.totalChildren,
    required this.totalStaff,
    required this.totalSections,
    required this.presentToday,
    required this.absentToday,
    required this.revenueThisMonth,
    required this.expensesThisMonth,
    required this.profitThisMonth,
    required this.pendingPhotosCount,
    required this.lateSubscriptionsCount,
    required this.mostActiveSection,
    required this.mostActiveSectionCount,
    required this.leastActiveSection,
    required this.leastActiveSectionCount,
    required this.activityCountBySection,
    required this.childrenNeedingFollowUp,
    required this.attendanceLast7Days,
    required this.financeLast6Months,
    required this.childrenBySection,
  });

  /// اقتراح إداري واحد، مُشتق من البيانات المُجمَّعة أعلاه فقط (عرض،
  /// وليس قاعدة عمل جديدة على مستوى جدول بعينه — لذلك يبقى هنا).
  String get topSuggestion {
    if (lateSubscriptionsCount > 0) {
      return 'يوجد $lateSubscriptionsCount اشتراك متأخر — يُفضّل متابعتها اليوم.';
    }
    if (pendingPhotosCount > 0) {
      return 'يوجد $pendingPhotosCount صورة بانتظار المراجعة.';
    }
    if (childrenNeedingFollowUp.isNotEmpty) {
      return 'يوجد ${childrenNeedingFollowUp.length} طفل يحتاج متابعة — راجعي بطاقة المتابعة.';
    }
    if (leastActiveSection != null && leastActiveSectionCount == 0) {
      return 'قسم "$leastActiveSection" لم يسجّل أي نشاط بعد — قد يحتاج تحفيزًا.';
    }
    return 'لا توجد إجراءات عاجلة اليوم — كل شيء تحت السيطرة.';
  }
}

/// Facade فقط: ينسّق بين الخدمات الموجودة (ChildService, AttendanceService,
/// AttendanceReportService, SubscriptionService, ExpenseService,
/// ActivityService, SectionService, PhotoService, UserService) ليبني
/// [DashboardData] الجاهزة للعرض.
///
/// لا يحتوي هذا الملف على أي استعلام SQLite مباشر ولا أي قاعدة عمل
/// جديدة. أي منطق جديد احتاجته لوحة القيادة أُضيف داخل الخدمة المالكة
/// للبيانات نفسها:
///  - AttendanceReportService.getFrequentAbsentees()
///  - ActivityService.getPhotographedChildIds() / getActivityCountBySection() / getMostAndLeastActiveSections()
///  - SubscriptionService.getLateSubscriptionsCount()
class DashboardService {
  final ChildService _childService = ChildService();
  final AttendanceService _attendanceService = AttendanceService();
  final AttendanceReportService _attendanceReportService =
      AttendanceReportService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  final ExpenseService _expenseService = ExpenseService();
  final ActivityService _activityService = ActivityService();
  final SectionService _sectionService = SectionService();
  final PhotoService _photoService = PhotoService();
  final UserService _userService = UserService();

  String _dateText(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _monthText(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    return '$year-$month';
  }

  Future<DashboardData> loadDashboardData(AppUser user) async {
    final now = DateTime.now();
    final today = _dateText(now);
    final currentMonth = _monthText(now);
    final isDirector = user.isDirector;

    final children = isDirector
        ? await _childService.getAllChildren()
        : await _childService.getChildrenBySection(user.section);

    final sections = await _sectionService.getAllSections();

    final attendanceToday = await _attendanceService.getAttendanceForDate(
      today,
    );

    int presentToday = 0;
    int absentToday = 0;
    for (final child in children) {
      final status = attendanceToday[child.id];
      if (status == 'حاضر') {
        presentToday++;
      } else if (status == 'غائب') {
        absentToday++;
      }
    }

    // الموظفون: يُحمَّلون من SQLite (وليس فقط من الذاكرة المؤقتة) حتى
    // تعكس لوحة القيادة دائمًا آخر بيانات فعلية.
    await _userService.refreshFromDatabase();
    final staffCount = _userService
        .getAllUsers()
        .where((u) => u.isTeacher && u.isActive)
        .length;

    double revenueThisMonth = 0;
    int lateSubscriptionsCount = 0;
    int pendingPhotosCount = 0;
    Map<String, int> activityCountBySection = {};
    String? mostActiveSection;
    int mostActiveSectionCount = 0;
    String? leastActiveSection;
    int leastActiveSectionCount = 0;
    List<FollowUpChild> followUp = [];

    if (isDirector) {
      final monthSummary = await _subscriptionService.getMonthSummary(
        currentMonth,
      );
      revenueThisMonth = monthSummary['paidAmount'] ?? 0;

      lateSubscriptionsCount = await _subscriptionService
          .getLateSubscriptionsCount(currentMonth);

      final pendingPhotos = await _photoService.getPendingPhotos();
      pendingPhotosCount = pendingPhotos.length;

      final activityInsight =
          await _activityService.getMostAndLeastActiveSections();
      activityCountBySection = activityInsight.countBySection;
      mostActiveSection = activityInsight.mostActiveSection;
      mostActiveSectionCount = activityInsight.mostActiveSectionCount;
      leastActiveSection = activityInsight.leastActiveSection;
      leastActiveSectionCount = activityInsight.leastActiveSectionCount;

      followUp = await _buildFollowUpList(children, now, activityCountBySection);
    }

    final expensesThisMonth = isDirector
        ? await _expenseService.getTotalExpensesForMonth(currentMonth)
        : 0.0;

    final profitThisMonth = revenueThisMonth - expensesThisMonth;

    final attendanceLast7Days = await _loadAttendanceLast7Days(now);
    final financeLast6Months =
        isDirector ? await _loadFinanceLast6Months(now) : <MonthlyFinancePoint>[];

    final childrenBySection = <String, int>{};
    for (final child in children) {
      if (child.section.isEmpty) continue;
      childrenBySection[child.section] = (childrenBySection[child.section] ?? 0) + 1;
    }

    return DashboardData(
      totalChildren: children.length,
      totalStaff: staffCount,
      totalSections: sections.length,
      presentToday: presentToday,
      absentToday: absentToday,
      revenueThisMonth: revenueThisMonth,
      expensesThisMonth: expensesThisMonth,
      profitThisMonth: profitThisMonth,
      pendingPhotosCount: pendingPhotosCount,
      lateSubscriptionsCount: lateSubscriptionsCount,
      mostActiveSection: mostActiveSection,
      mostActiveSectionCount: mostActiveSectionCount,
      leastActiveSection: leastActiveSection,
      leastActiveSectionCount: leastActiveSectionCount,
      activityCountBySection: activityCountBySection,
      childrenNeedingFollowUp: followUp,
      attendanceLast7Days: attendanceLast7Days,
      financeLast6Months: financeLast6Months,
      childrenBySection: childrenBySection,
    );
  }

  /// آخر 7 أيام حضور/غياب — استدعاءات متكررة لـ
  /// AttendanceService.getAttendanceSummary الموجودة أصلاً (تنسيق فقط،
  /// بدون أي استعلام SQL جديد أو قاعدة عمل جديدة).
  Future<List<DailyAttendancePoint>> _loadAttendanceLast7Days(
    DateTime now,
  ) async {
    final points = <DailyAttendancePoint>[];

    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateText = _dateText(date);
      final summary = await _attendanceService.getAttendanceSummary(dateText);

      points.add(
        DailyAttendancePoint(
          date: dateText,
          present: summary['حاضر'] ?? 0,
          absent: summary['غائب'] ?? 0,
        ),
      );
    }

    return points;
  }

  /// آخر 6 أشهر: استدعاءات متكررة لـ SubscriptionService.getMonthSummary
  /// وExpenseService.getTotalExpensesForMonth الموجودتين أصلاً (تنسيق
  /// فقط، بدون أي استعلام SQL جديد أو قاعدة عمل جديدة).
  Future<List<MonthlyFinancePoint>> _loadFinanceLast6Months(
    DateTime now,
  ) async {
    final points = <MonthlyFinancePoint>[];

    for (var i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthText = _monthText(date);

      final summary = await _subscriptionService.getMonthSummary(monthText);
      final expense = await _expenseService.getTotalExpensesForMonth(monthText);

      points.add(
        MonthlyFinancePoint(
          month: monthText,
          revenue: summary['paidAmount'] ?? 0,
          expense: expense,
        ),
      );
    }

    return points;
  }

  /// الأطفال الذين يحتاجون متابعة، وفق 3 معايير فقط (بدون "غير
  /// المقيَّمين" لأن نظام التقييم غير موجود حاليًا). كل معيار مصدره
  /// دالة جاهزة من الخدمة المالكة لبياناته:
  ///  - الغياب المتكرر: AttendanceReportService.getFrequentAbsentees()
  ///  - بلا صور: ActivityService.getPhotographedChildIds()
  ///  - بلا نشاط: مفاتيح activityCountBySection (من ActivityService بالفعل)
  /// هذه الدالة تُجمِّع فقط بين النتائج الجاهزة الثلاث لكل طفل، ولا
  /// تُجري أي استعلام SQL بنفسها.
  Future<List<FollowUpChild>> _buildFollowUpList(
    List<Child> children,
    DateTime now,
    Map<String, int> activityCountBySection,
  ) async {
    if (children.isEmpty) return [];

    final frequentAbsentees = await _attendanceReportService.getFrequentAbsentees(
      year: now.year,
      month: now.month,
    );
    final absentChildIds = frequentAbsentees.map((e) => e.childId).toSet();

    final photographedChildIds = await _activityService.getPhotographedChildIds();

    final sectionsWithActivity = activityCountBySection.keys.toSet();

    final result = <FollowUpChild>[];

    for (final child in children) {
      final fullName = '${child.firstName} ${child.lastName}'.trim();
      final reasons = <String>[];

      if (absentChildIds.contains(child.id)) {
        reasons.add('غياب متكرر هذا الشهر');
      }
      if (!photographedChildIds.contains(child.id)) {
        reasons.add('لا توجد له صور');
      }
      if (!sectionsWithActivity.contains(child.section)) {
        reasons.add('لم يشارك في أي نشاط');
      }

      if (reasons.isNotEmpty) {
        result.add(
          FollowUpChild(
            id: child.id,
            fullName: fullName.isEmpty ? 'بدون اسم' : fullName,
            section: child.section,
            reason: reasons.join(' • '),
          ),
        );
      }
    }

    return result;
  }
}
