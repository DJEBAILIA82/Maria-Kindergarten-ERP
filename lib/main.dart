import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/user.dart';
import 'pages/main_page.dart';
import 'user_service.dart';

// الألوان الرئيسية للتطبيق. أي تغيير هنا ينعكس تلقائيًا على كل الصفحات.
const Color kPrimaryPurple = Color(0xFF5E2A8C);
const Color kGoldAccent = Color(0xFFD4AF37);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserService().createDefaultDirector();

  for (final user in UserService().getAllUsers()) {
    debugPrint(
        'USER => ${user.username} | ${user.password} | ${user.section}');
  }

  runApp(const KingdomMariaApp());
}

class KingdomMariaApp extends StatelessWidget {
  const KingdomMariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مملكة ماريا',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryPurple,
          primary: kPrimaryPurple,
          secondary: kGoldAccent,
        ),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserService _userService = UserService();

  final TextEditingController _passwordController = TextEditingController();

  String _loginType = 'teacher';
  String _selectedSection = 'الرضع';

  bool _isLoading = false;
  bool _hidePassword = true;
  bool _rememberPassword = false;

  String get _username {
    if (_loginType == 'director') {
      return 'mariam';
    }

    switch (_selectedSection) {
      case 'الرضع':
        return 'الرضع';
      case 'قبل التمهيدي':
        return 'قبل التمهيدي';
      case 'التمهيدي':
        return 'التمهيدي';
      case 'التحضيري':
        return 'التحضيري';
      default:
        return 'الرضع';
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال كلمة المرور'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    debugPrint("LOGIN USERNAME = $_username");
    debugPrint("LOGIN PASSWORD = $password");

    final AppUser? user = await _userService.login(
      username: _username,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور غير صحيحة'),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainPage(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDirectorLogin = _loginType == 'director';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPrimaryPurple.withValues(alpha: 0.05),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.castle,
                        size: 78,
                        color: kPrimaryPurple,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '👑 مملكة ماريا 👑',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryPurple,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'تسجيل الدخول إلى إدارة الروضة',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'teacher',
                            icon: Icon(Icons.groups),
                            label: Text('قسم'),
                          ),
                          ButtonSegment<String>(
                            value: 'director',
                            icon: Icon(Icons.admin_panel_settings),
                            label: Text('المديرة'),
                          ),
                        ],
                        selected: {_loginType},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _loginType = selection.first;
                            _passwordController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (!isDirectorLogin)
                        DropdownButtonFormField<String>(
                          value: _selectedSection,
                          decoration: const InputDecoration(
                            labelText: 'اختر القسم',
                            prefixIcon: Icon(Icons.groups),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'الرضع',
                              child: Text('قسم الرضع'),
                            ),
                            DropdownMenuItem(
                              value: 'قبل التمهيدي',
                              child: Text('قسم قبل التمهيدي'),
                            ),
                            DropdownMenuItem(
                              value: 'التمهيدي',
                              child: Text('قسم التمهيدي'),
                            ),
                            DropdownMenuItem(
                              value: 'التحضيري',
                              child: Text('قسم التحضيري'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedSection = value;
                              _passwordController.clear();
                            });
                          },
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: kPrimaryPurple.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kPrimaryPurple.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: kPrimaryPurple,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'الدخول بصلاحية مديرة الروضة',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isDirectorLogin
                                    ? 'اسم المستخدم: mariam'
                                    : 'القسم المختار: $_selectedSection',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidePassword = !_hidePassword;
                              });
                            },
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _rememberPassword,
                        onChanged: (value) {
                          setState(() {
                            _rememberPassword = value ?? false;
                          });
                        },
                        title: const Text(
                          'حفظ كلمة المرور على هذا الجهاز',
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: const Text(
                          'لا تستخدم هذا الخيار على هاتف مشترك',
                          style: TextStyle(fontSize: 11),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _login,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: Text(
                            _isLoading ? 'جارٍ الدخول...' : 'تسجيل الدخول',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isDirectorLogin
                            ? 'المديرة تدخل بحسابها الخاص'
                            : 'اختاري القسم ثم أدخلي كلمة المرور فقط',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}