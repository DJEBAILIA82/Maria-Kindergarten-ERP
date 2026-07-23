import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../child_service.dart';
import '../models/child.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final ChildService _childService = ChildService();
  final TextEditingController _messageController = TextEditingController();

  List<Child> _children = [];
  bool _isLoading = true;

  String _selectedType = 'رسالة عامة';
  String _selectedChildId = '';
  String _selectedSection = '';
  String _sendMode = 'child';

  List<Child> _sendingChildren = [];
  int _sendingIndex = 0;
  bool _isSendingList = false;

  final List<String> _messageTypes = [
    'رسالة عامة',
    'إشعار غياب',
    'تذكير بالاشتراك',
    'عطلة',
    'اجتماع',
    'نشاط أو حفلة',
  ];

  @override
  void initState() {
    super.initState();
    _loadChildren();
    _setTemplate('رسالة عامة');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final children = await _childService.getAllChildren();

      if (!mounted) return;

      setState(() {
        _children = children;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تحميل قائمة الأطفال: $error'),
        ),
      );
    }
  }

  String _todayText() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Child? get _selectedChild {
    if (_selectedChildId.isEmpty) return null;

    for (final child in _children) {
      if (child.id == _selectedChildId) {
        return child;
      }
    }

    return null;
  }

  List<String> get _sections {
    final sections = <String>{};

    for (final child in _children) {
      final section = child.section.trim();

      if (section.isNotEmpty) {
        sections.add(section);
      }
    }

    final result = sections.toList();
    result.sort();

    return result;
  }

  List<Child> get _selectedRecipients {
    if (_sendMode == 'child') {
      final child = _selectedChild;

      if (child == null) return [];

      return [child];
    }

    if (_sendMode == 'section') {
      if (_selectedSection.isEmpty) return [];

      return _children.where((child) {
        return child.section.trim() == _selectedSection;
      }).toList();
    }

    return List<Child>.from(_children);
  }

  List<Child> get _validRecipients {
    return _selectedRecipients.where((child) {
      return _phoneForChild(child).isNotEmpty;
    }).toList();
  }

  String _childName(Child child) {
    return '${child.firstName} ${child.lastName}'.trim();
  }

  void _setTemplate(String type) {
    final child = _selectedChild;
    final childName = child == null ? '[اسم الطفل]' : _childName(child);

    String message = '';

    if (type == 'إشعار غياب') {
      message = '''
السلام عليكم،

نحيطكم علمًا أن الطفل/ة: $childName
كان/ت غائبًا/ة اليوم ${_todayText()}.

يرجى إعلام إدارة روضة مملكة ماريا بسبب الغياب عند الإمكان.

شكرًا لتعاونكم.
''';
    } else if (type == 'تذكير بالاشتراك') {
      message = '''
السلام عليكم،

تذكير بخصوص تسديد رسوم اشتراك الطفل/ة: $childName.

يرجى التقرب من إدارة روضة مملكة ماريا لتسوية الوضعية في أقرب وقت.

شكرًا لتفهمكم.
''';
    } else if (type == 'عطلة') {
      message = '''
السلام عليكم أولياء الأمور الكرام،

تعلمكم إدارة روضة مملكة ماريا أن الروضة ستكون في عطلة.

سيتم إعلامكم بتاريخ استئناف الدراسة لاحقًا.

شكرًا لتفهمكم.
''';
    } else if (type == 'اجتماع') {
      message = '''
السلام عليكم أولياء الأمور الكرام،

تدعوكم إدارة روضة مملكة ماريا لحضور اجتماع خاص بالأولياء.

يرجى متابعة الرسالة لمعرفة التاريخ والساعة المحددين.

شكرًا لتعاونكم.
''';
    } else if (type == 'نشاط أو حفلة') {
      message = '''
السلام عليكم أولياء الأمور الكرام،

يسر إدارة روضة مملكة ماريا إعلامكم بتنظيم نشاط أو حفلة للأطفال.

سيتم إرسال التفاصيل الخاصة بالتاريخ والبرنامج قريبًا.

شكرًا لتعاونكم.
''';
    } else {
      message = '''
السلام عليكم أولياء الأمور الكرام،

هذه رسالة من إدارة روضة مملكة ماريا.

''';
    }

    _messageController.text = message;
  }

  String _cleanPhone(String phone) {
    var result = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (result.startsWith('+213')) {
      result = '213${result.substring(4)}';
    } else if (result.startsWith('00213')) {
      result = '213${result.substring(5)}';
    } else if (result.startsWith('0')) {
      result = '213${result.substring(1)}';
    }

    return result.replaceAll('+', '');
  }

  String _phoneForChild(Child child) {
    final phone1 = child.phone1.trim();

    if (phone1.isNotEmpty) return phone1;

    return child.phone2.trim();
  }

  Future<bool> _openWhatsAppForChild(
    Child child, {
    bool showErrors = true,
  }) async {
    final phone = _phoneForChild(child);

    if (phone.isEmpty) {
      if (showErrors && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يوجد رقم هاتف مسجل للطفل ${_childName(child)}',
            ),
          ),
        );
      }

      return false;
    }

    final cleanPhone = _cleanPhone(phone);

    if (cleanPhone.length < 10) {
      if (showErrors && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'رقم الهاتف غير صحيح للطفل ${_childName(child)}',
            ),
          ),
        );
      }

      return false;
    }

    final message = _messageController.text.trim();

    if (message.isEmpty) {
      if (showErrors && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اكتب الرسالة أولًا'),
          ),
        );
      }

      return false;
    }

    final uri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
    );

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && showErrors && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر فتح واتساب. تأكد من تثبيت تطبيق واتساب على الهاتف.',
            ),
          ),
        );
      }

      return opened;
    } catch (_) {
      if (showErrors && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر فتح واتساب. تأكد من تثبيت تطبيق واتساب على الهاتف.',
            ),
          ),
        );
      }

      return false;
    }
  }

  Future<void> _sendToSelectedChild() async {
    final child = _selectedChild;

    if (child == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختر طفلًا أولًا'),
        ),
      );
      return;
    }

    await _openWhatsAppForChild(child);
  }

  Future<void> _startSendingList() async {
    final recipients = _validRecipients;

    if (recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد أولياء لديهم أرقام هاتف صالحة للإرسال'),
        ),
      );
      return;
    }

    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتب الرسالة أولًا'),
        ),
      );
      return;
    }

    final modeText =
        _sendMode == 'section' ? 'القسم: $_selectedSection' : 'جميع الأولياء';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأكيد بدء الإرسال'),
            content: Text(
              'سيتم تجهيز الرسالة لـ ${recipients.length} ولي أمر ($modeText).\n\n'
              'سيفتح واتساب لولي واحد في كل مرة. بعد الإرسال والعودة للتطبيق اضغط زر "التالي".',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('بدء الإرسال'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _sendingChildren = recipients;
      _sendingIndex = 0;
      _isSendingList = true;
    });

    await _openCurrentRecipient();
  }

  Future<void> _openCurrentRecipient() async {
    if (!_isSendingList || _sendingIndex >= _sendingChildren.length) {
      return;
    }

    final child = _sendingChildren[_sendingIndex];

    await _openWhatsAppForChild(child, showErrors: false);
  }

  Future<void> _openNextRecipient() async {
    if (!_isSendingList) return;

    if (_sendingIndex + 1 >= _sendingChildren.length) {
      if (!mounted) return;

      setState(() {
        _isSendingList = false;
        _sendingChildren = [];
        _sendingIndex = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الوصول إلى آخر ولي في قائمة الإرسال'),
        ),
      );

      return;
    }

    setState(() {
      _sendingIndex++;
    });

    await _openCurrentRecipient();
  }

  void _stopSendingList() {
    setState(() {
      _isSendingList = false;
      _sendingChildren = [];
      _sendingIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إيقاف قائمة الإرسال'),
      ),
    );
  }

  Widget _messageTypeChip(String type) {
    final selected = _selectedType == type;

    return ChoiceChip(
      label: Text(type),
      selected: selected,
      selectedColor: Colors.green.shade100,
      onSelected: (_) {
        setState(() {
          _selectedType = type;
          _setTemplate(type);
        });
      },
    );
  }

  Widget _sendModeCard({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final selected = _sendMode == value;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _sendMode = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? color : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _sendMode,
              activeColor: color,
              onChanged: (newValue) {
                if (newValue == null) return;

                setState(() {
                  _sendMode = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientSelector() {
    if (_sendMode == 'child') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إرسال لطفل محدد',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedChildId.isEmpty ? null : _selectedChildId,
            decoration: const InputDecoration(
              labelText: 'اختر الطفل',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.child_care),
            ),
            items: _children.map((child) {
              return DropdownMenuItem<String>(
                value: child.id,
                child: Text(
                  '${_childName(child)} — ${child.section}',
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedChildId = value ?? '';
                _setTemplate(_selectedType);
              });
            },
          ),
        ],
      );
    }

    if (_sendMode == 'section') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إرسال إلى قسم محدد',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedSection.isEmpty ? null : _selectedSection,
            decoration: const InputDecoration(
              labelText: 'اختر القسم',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.groups),
            ),
            items: _sections.map((section) {
              return DropdownMenuItem<String>(
                value: section,
                child: Text(section),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSection = value ?? '';
              });
            },
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange.shade200,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.groups_2,
            color: Colors.orange,
            size: 30,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'سيتم تجهيز الرسالة لجميع الأولياء الذين لديهم أرقام هاتف مسجلة.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendingProgress() {
    if (!_isSendingList || _sendingChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentChild = _sendingChildren[_sendingIndex];
    final currentNumber = _sendingIndex + 1;
    final total = _sendingChildren.length;

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            'قائمة الإرسال: $currentNumber من $total',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الولي الحالي: ${_childName(currentChild)}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: currentNumber / total,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _stopSendingList,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('إيقاف'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openNextRecipient,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    currentNumber == total ? 'إنهاء' : 'التالي',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipientCount = _validRecipients.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الرسائل والإشعارات'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _loadChildren,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث قائمة الأطفال',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'يتم تجهيز الرسالة وفتح واتساب. الإرسال النهائي يتم من تطبيق واتساب.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'نوع الرسالة',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _messageTypes.map(_messageTypeChip).toList(),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'إرسال الرسالة إلى',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _sendModeCard(
                    value: 'child',
                    icon: Icons.child_care,
                    title: 'طفل محدد',
                    subtitle: 'فتح واتساب لولي طفل واحد',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _sendModeCard(
                    value: 'section',
                    icon: Icons.groups,
                    title: 'قسم محدد',
                    subtitle: 'إرسال منظم لأولياء قسم واحد',
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 8),
                  _sendModeCard(
                    value: 'all',
                    icon: Icons.groups_2,
                    title: 'جميع الأولياء',
                    subtitle: 'إرسال منظم لجميع الأرقام المسجلة',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 18),
                  _buildRecipientSelector(),
                  const SizedBox(height: 16),
                  if (_sendMode != 'child')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt_outlined,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'عدد الأولياء الذين لديهم رقم هاتف: $recipientCount',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_sendMode != 'child') const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    minLines: 8,
                    maxLines: 12,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'نص الرسالة',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_sendMode == 'child')
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _sendToSelectedChild,
                        icon: const Icon(Icons.send),
                        label: const Text(
                          'فتح واتساب وإرسال للطفل المحدد',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSendingList ? null : _startSendingList,
                        icon: const Icon(Icons.send),
                        label: Text(
                          _sendMode == 'section'
                              ? 'بدء الإرسال للقسم'
                              : 'بدء الإرسال لجميع الأولياء',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  _buildSendingProgress(),
                  const SizedBox(height: 18),
                  const Text(
                    'ملاحظة: عند الإرسال إلى قسم أو إلى الجميع، يفتح التطبيق واتساب لولي واحد في كل مرة. بعد الإرسال والعودة للتطبيق اضغط “التالي” لفتح الولي التالي.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}