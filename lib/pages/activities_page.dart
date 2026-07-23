import 'package:flutter/material.dart';

import '../activity_service.dart';
import '../database/database_helper.dart';
import 'activity_details_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final ActivityService _service = ActivityService();

  static const String _otherOption = 'أخرى...';
  static const String _allSectionsOption = 'جميع الأقسام';

  static const List<String> _presetActivityTitles = [
    'حفلة عيد ميلاد',
    'نشاط تلوين',
    'رحلة',
    'نشاط رياضي',
    'نشاط موسيقي',
    'نشاط رسم',
    'نشاط حفظ القرآن',
    'نشاط تعليمي',
    'احتفال',
    _otherOption,
  ];

  List<Map<String, dynamic>> _activities = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _loading = true;
    });

    final data = await _service.getActivities();

    if (!mounted) return;

    setState(() {
      _activities = data;
      _loading = false;
    });
  }

  Future<List<String>> _loadSectionNames() async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'sections',
      orderBy: 'name ASC',
    );

    final names = rows
        .map((row) => (row['name'] as String?)?.trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    return [_allSectionsOption, ...names];
  }

  Future<Map<String, dynamic>?> _findLatestActivity() async {
    final data = await _service.getActivities();

    if (data.isEmpty) return null;

    Map<String, dynamic>? latest;
    num latestId = -1;

    for (final activity in data) {
      final rawId = activity['id'];
      final id = rawId is num
          ? rawId
          : num.tryParse(rawId?.toString() ?? '') ?? -1;

      if (id > latestId) {
        latestId = id;
        latest = activity;
      }
    }

    return latest;
  }

  Future<void> _newActivity() async {
    final descriptionController = TextEditingController();
    final customTitleController = TextEditingController();

    final sectionNames = await _loadSectionNames();

    if (!mounted) return;

    String selectedTitle = _presetActivityTitles.first;
    String selectedSection = sectionNames.first;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isOtherTitle = selectedTitle == _otherOption;

            return AlertDialog(
              title: const Text("نشاط جديد"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedTitle,
                      decoration: const InputDecoration(
                        labelText: "اسم النشاط",
                      ),
                      items: _presetActivityTitles.map((title) {
                        return DropdownMenuItem<String>(
                          value: title,
                          child: Text(title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedTitle = value;
                        });
                      },
                    ),
                    if (isOtherTitle) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: customTitleController,
                        decoration: const InputDecoration(
                          labelText: "اكتب اسم النشاط",
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "الوصف",
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedSection,
                      decoration: const InputDecoration(
                        labelText: "القسم",
                      ),
                      items: sectionNames.map((name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedSection = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text("حفظ"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    final finalTitle = selectedTitle == _otherOption
        ? customTitleController.text.trim()
        : selectedTitle;

    if (finalTitle.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم النشاط'),
        ),
      );
      return;
    }

    await _service.createActivity(
      title: finalTitle,
      description: descriptionController.text.trim(),
      section: selectedSection,
      date: DateTime.now(),
    );

    await _loadActivities();

    if (!mounted) return;

    final createdActivity = await _findLatestActivity();

    if (!mounted) return;

    if (createdActivity != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivityDetailsPage(
            activity: createdActivity,
          ),
        ),
      );

      _loadActivities();
    }
  }

  Future<void> _deleteActivity(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: Text(
            "هل تريد حذف النشاط:\n\n${item["title"]} ؟",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("حذف"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _service.deleteActivity(item["id"]);
    _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("أنشطة الروضة"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _newActivity,
          child: const Icon(Icons.add),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _activities.isEmpty
                ? const Center(
                    child: Text(
                      "لا توجد أنشطة",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: _activities.length,
                    itemBuilder: (_, index) {
                      final item = _activities[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActivityDetailsPage(
                                  activity: item,
                                ),
                              ),
                            );

                            _loadActivities();
                          },
                          leading: const CircleAvatar(
                            child: Icon(Icons.celebration),
                          ),
                          title: Text(item["title"]),
                          subtitle: Text(
                            "${item["section"]}\n${item["description"]}",
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteActivity(item),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}