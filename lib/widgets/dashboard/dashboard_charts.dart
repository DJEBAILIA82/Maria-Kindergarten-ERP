import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/dashboard_service.dart';
import '../app_theme.dart';

/// لوحة الرسوم البيانية الأربعة المطلوبة للوحة القيادة:
/// الحضور آخر 7 أيام، الإيرادات مقابل المصروفات، توزيع الأطفال حسب
/// الأقسام، وتوزيع الأنشطة. كل الرسوم تُبنى من [DashboardData] الجاهزة
/// (لا يوجد أي استعلام أو منطق بيانات داخل هذا الملف).
class DashboardCharts extends StatelessWidget {
  final DashboardData data;

  const DashboardCharts({super.key, required this.data});

  static const List<Color> _sectionPalette = [
    AppTheme.primaryPurple,
    AppTheme.secondaryTurquoise,
    AppTheme.goldAccent,
    AppTheme.attendanceBlue,
    AppTheme.financeExpense,
    AppTheme.alertUrgent,
  ];

  String _shortDay(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}/${parts[1]}';
  }

  String _shortMonth(String isoMonth) {
    final parts = isoMonth.split('-');
    if (parts.length != 2) return isoMonth;
    return '${parts[1]}/${parts[0].substring(2)}';
  }

  Widget _chartCard({required String title, required Widget chart}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spaceLg),
      margin: EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.headingMedium),
          SizedBox(height: AppTheme.spaceMd),
          SizedBox(height: 190, child: chart),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppTheme.spaceXs),
        Text(label, style: AppTheme.caption),
      ],
    );
  }

  Widget _attendanceChart() {
    final points = data.attendanceLast7Days;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _shortDay(points[index].date),
                          style: AppTheme.caption,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < points.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: points[i].present.toDouble(),
                        color: AppTheme.attendanceBlue,
                        width: 8,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: points[i].absent.toDouble(),
                        color: AppTheme.alertPending,
                        width: 8,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppTheme.spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(AppTheme.attendanceBlue, 'حاضر'),
            SizedBox(width: AppTheme.spaceMd),
            _legendDot(AppTheme.alertPending, 'غائب'),
          ],
        ),
      ],
    );
  }

  Widget _financeChart() {
    final points = data.financeLast6Months;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _shortMonth(points[index].month),
                          style: AppTheme.caption,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < points.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: points[i].revenue,
                        color: AppTheme.financeRevenue,
                        width: 8,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: points[i].expense,
                        color: AppTheme.financeExpense,
                        width: 8,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppTheme.spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(AppTheme.financeRevenue, 'إيرادات'),
            SizedBox(width: AppTheme.spaceMd),
            _legendDot(AppTheme.financeExpense, 'مصروفات'),
          ],
        ),
      ],
    );
  }

  Widget _childrenBySectionChart() {
    final entries = data.childrenBySection.entries.toList();

    if (entries.isEmpty) {
      return Center(
        child: Text('لا توجد بيانات كافية بعد', style: AppTheme.bodyText),
      );
    }

    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 34,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value.toDouble(),
                    color: _sectionPalette[i % _sectionPalette.length],
                    radius: 46,
                    title: total == 0
                        ? ''
                        : '${((entries[i].value / total) * 100).round()}%',
                    titleStyle: AppTheme.caption.copyWith(
                      color: AppTheme.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppTheme.spaceSm),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: _legendDot(
                      _sectionPalette[i % _sectionPalette.length],
                      '${entries[i].key} (${entries[i].value})',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _activityDistributionChart() {
    final entries = data.activityCountBySection.entries.toList();

    if (entries.isEmpty) {
      return Center(
        child: Text('لا توجد أنشطة مسجّلة بعد', style: AppTheme.bodyText),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    entries[index].key,
                    style: AppTheme.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < entries.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value.toDouble(),
                  color: _sectionPalette[i % _sectionPalette.length],
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chartCard(title: 'الحضور خلال آخر 7 أيام', chart: _attendanceChart()),
        if (data.financeLast6Months.isNotEmpty)
          _chartCard(
            title: 'الإيرادات مقابل المصروفات (آخر 6 أشهر)',
            chart: _financeChart(),
          ),
        _chartCard(
          title: 'توزيع الأطفال حسب الأقسام',
          chart: _childrenBySectionChart(),
        ),
        if (data.activityCountBySection.isNotEmpty)
          _chartCard(
            title: 'توزيع الأنشطة حسب الأقسام',
            chart: _activityDistributionChart(),
          ),
      ],
    );
  }
}
