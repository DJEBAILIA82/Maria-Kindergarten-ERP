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

final List<_SectionAccount> _sectionAccounts = const [
_SectionAccount(
section: 'قسم الرضع',
username: 'الرضع',
),
_SectionAccount(
section: 'قسم قبل التمهيدي',
username: 'قبل_التمهيدي',
),
_SectionAccount(
section: 'قسم التمهيدي',
username: 'التمهيدي',
),
_SectionAccount(
section: 'قسم التحضيري',
username: 'التحضيري',
),
];

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
  for (final account in _sectionAccounts) {
    final exists = _userService.getAllUsers().any(
      (user) => user.username == account.username,
    );

    if (!exists) {
      await _userService.addUser(
        AppUser(
          id: 'section_${account.username}',
          fullName: account.section,
          username: account.username,
          password: '1234',
          role: UserRole.teacher,
          section: account.section,
          isActive: true,
        ),
      );
    }
  }

  if (!mounted) return;

  setState(() {
    _users = _userService.getAllUsers();
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

AppUser? _getSectionUser(_SectionAccount account) {
for (final user in _users) {
if (user.username == account.username) {
return user;
}
}

return null;

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

                  ScaffoldMessenger.of(context).showSnackBar(
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

Widget _sectionCard(_SectionAccount account) {
final user = _getSectionUser(account);

if (user == null) {
  return const SizedBox.shrink();
}

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
                account.section,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'اسم المستخدم: ${account.username}',
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
title: const Text(
'مريم جبايلية',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
subtitle: const Text(
'اسم المستخدم: mariam\nصلاحية كاملة لإدارة الروضة',
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
..._sectionAccounts.map(_sectionCard),
const SizedBox(height: 20),
],
),
),
);
}
}

class _SectionAccount {
final String section;
final String username;

const _SectionAccount({
required this.section,
required this.username,
});
}
