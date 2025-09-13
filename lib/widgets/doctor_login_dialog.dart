import 'package:flutter/material.dart';

class DoctorLoginDialog extends StatefulWidget {
  const DoctorLoginDialog({super.key});
  @override State<DoctorLoginDialog> createState() => _DoctorLoginDialogState();
}

class _DoctorLoginDialogState extends State<DoctorLoginDialog> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _err = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Doctor Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _user, decoration: const InputDecoration(labelText: 'Username')),
          TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          if (_err) const Padding(padding: EdgeInsets.only(top:8), child: Text('Invalid credentials', style: TextStyle(color: Colors.red)))
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        FilledButton(
          onPressed: () {
            if (_user.text == 'doctor1' && _pass.text == 'password123') {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Welcome, Dr. ${_user.text}')));
            } else {
              setState(() { _err = true; });
            }
          },
          child: const Text('Login'),
        )
      ],
    );
  }
}
