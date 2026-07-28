import 'package:flutter/material.dart';

import '../models/user.dart';
import '../user_service.dart';

class SettingsPage extends StatefulWidget {
const SettingsPage({super.key});

@override
State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
final UserService _userService = UserService();

List<AppUser> _users = [];
bool _isLoading = true;

@override
void initState() {
super.initState();
_loadAccounts();
}

Future<void> _loadAccounts() async {
setState(() {
_isLoading = true;
});

try {
  final users = _userService.getAllUsers();

  if (!mounted) return;

  setState(() {
    _users = users;
    _isLoading = false;
  });
} catch (error) {
  if (!mounted) return;

  setState(() {
    _isLoading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('حدث خطأ أثناء تحميل الحسابات: $error'),
    ),
  );
}

}

AppUser? get _directorUser {
for (final user in _users) {
if (user.role == UserRole.director) {
return user;
}
}
return null;
}

List<AppUser> get _teacherUsers {
return _users.where((user) => user.role == UserRole.teacher).toList();
}

Future<void> _changePassword(AppUser user) async {
final passwordController = TextEditingController();

await showDialog<void>(
  context: context,
  builder: (dialogContext) {
    bool hidePassword = true;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('تغيير كلمة مرور ${user.section}'),
            content: TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                hintText: '4 أحرف أو أرقام على الأقل',
                prefixIcon: const Icon(Icons.lock_reset),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setDialogState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final password = passwordController.text.trim();
                  final messenger = ScaffoldMessenger.of(context);

                  if (password.length < 4) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'كلمة المرور يجب أن تكون 4 أحرف أو أرقام على الأقل',
                        ),
                      ),
                    );
                    return;
                  }

                  await _userService.resetPassword(
                    userId: user.id,
                    newPassword: password,
                  );

                  if (!dialogContext.mounted) return;

                  Navigator.of(dialogContext).pop();

                  await _loadAccounts();

                  if (!mounted) return;

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم تغيير كلمة مرور ${user.section} بنجاح',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  },
);

passwordController.dispose();

}

Future<void> _addUser() async {
final fullNameController = TextEditingController();
final usernameController = TextEditingController();
final passwordController = TextEditingController();
final sectionController = TextEditingController();
UserRole selectedRole = UserRole.teacher;

await showDialog<void>(
  context: context,
  builder: (dialogContext) {
    bool hidePassword = true;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إضافة مستخدم جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: Icon(Icons.account_circle),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      hintText: '4 أحرف أو أرقام على الأقل',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    key: ValueKey(selectedRole),
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'الدور',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.teacher,
                        child: Text('معلمة'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.director,
                        child: Text('مديرة'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedRole = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sectionController,
                    decoration: const InputDecoration(
                      labelText: 'القسم',
                      prefixIcon: Icon(Icons.groups),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final fullName = fullNameController.text.trim();
                  final username = usernameController.text.trim();
                  final password = passwordController.text.trim();
                  final section = sectionController.text.trim();
                  final messenger = ScaffoldMessenger.of(context);
                  final dialogMessenger = ScaffoldMessenger.of(dialogContext);

                  if (fullName.isEmpty || username.isEmpty) {
                    dialogMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('يرجى إدخال الاسم واسم المستخدم'),
                      ),
                    );
                    return;
                  }

                  if (password.length < 4) {
                    dialogMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'كلمة المرور يجب أن تكون 4 أحرف أو أرقام على الأقل',
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    await _userService.addUser(
                      AppUser(
                        id: '',
                        fullName: fullName,
                        username: username,
                        password: password,
                        role: selectedRole,
                        section: section,
                        isActive: true,
                      ),
                    );

                    if (!dialogContext.mounted) return;

                    Navigator.of(dialogContext).pop();

                    await _loadAccounts();

                    if (!mounted) return;

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('تم إضافة المستخدم بنجاح'),
                      ),
                    );
                  } catch (error) {
                    dialogMessenger.showSnackBar(
                      SnackBar(
                        content: Text('تعذّر إضافة المستخدم: $error'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  },
);

fullNameController.dispose();
usernameController.dispose();
passwordController.dispose();
sectionController.dispose();

}

Future<void> _toggleAccount(AppUser user) async {
await _userService.setUserActive(
userId: user.id,
isActive: !user.isActive,
);

await _loadAccounts();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      user.isActive
          ? 'تم إيقاف حساب ${user.section}'
          : 'تم تفعيل حساب ${user.section}',
    ),
  ),
);

}

Widget _sectionCard(AppUser user) {
final color = user.isActive ? Colors.blue : Colors.grey;

return Card(
  elevation: 2,
  margin: const EdgeInsets.only(bottom: 10),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            Icons.groups,
            color: color,
            size: 27,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.section.isNotEmpty ? 'قسم ${user.section}' : user.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'اسم المستخدم: ${user.username}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                user.isActive ? 'الحساب مفعّل' : 'الحساب موقوف',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'password') {
              _changePassword(user);
            } else if (value == 'status') {
              _toggleAccount(user);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'password',
              child: Row(
                children: [
                  Icon(Icons.lock_reset),
                  SizedBox(width: 8),
                  Text('تغيير كلمة المرور'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                  Icon(
                    user.isActive
                        ? Icons.person_off
                        : Icons.person_add_alt_1,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.isActive ? 'إيقاف الحساب' : 'تفعيل الحساب',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);

}

@override
Widget build(BuildContext context) {
return Directionality(
textDirection: TextDirection.rtl,
child: Scaffold(
appBar: AppBar(
title: const Text('الإعدادات وحسابات الأقسام'),
backgroundColor: Colors.grey.shade800,
foregroundColor: Colors.white,
actions: [
IconButton(
onPressed: _isLoading ? null : _addUser,
icon: const Icon(Icons.person_add_alt_1),
tooltip: 'إضافة مستخدم',
),
IconButton(
onPressed: _isLoading ? null : _loadAccounts,
icon: const Icon(Icons.refresh),
tooltip: 'تحديث',
),
],
),
body: _isLoading
? const Center(
child: CircularProgressIndicator(),
)
: ListView(
padding: const EdgeInsets.all(12),
children: [
Card(
color: Colors.pink.shade50,
child: const Padding(
padding: EdgeInsets.all(14),
child: Row(
children: [
Icon(
Icons.info_outline,
color: Colors.pink,
),
SizedBox(width: 10),
Expanded(
child: Text(
'اسم المستخدم ثابت لكل قسم. عند تغيير المعلمة، يكفي تغيير كلمة المرور فقط.',
style: TextStyle(fontSize: 13),
),
),
],
),
),
),
const SizedBox(height: 16),
const Text(
'حساب المديرة',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Card(
elevation: 2,
child: ListTile(
leading: const CircleAvatar(
backgroundColor: Color(0xFFFCE4EC),
child: Icon(
Icons.admin_panel_settings,
color: Colors.pink,
),
),
title: Text(
_directorUser?.fullName ?? 'لا يوجد حساب مديرة',
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
subtitle: Text(
_directorUser != null
? 'اسم المستخدم: ${_directorUser!.username}\nصلاحية كاملة لإدارة الروضة'
: '',
),
isThreeLine: true,
),
),
const SizedBox(height: 18),
const Text(
'حسابات الأقسام',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
..._teacherUsers.map(_sectionCard),
const SizedBox(height: 20),
],
),
),
);
}
}