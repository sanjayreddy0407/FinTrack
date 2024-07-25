
import 'package:flutter/material.dart';
class SetPinPage extends StatefulWidget {
  final ValueChanged<String> onPinSet;
  const SetPinPage({super.key, required this.onPinSet});
  @override
  // ignore: library_private_types_in_public_api
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {

     return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
           children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final pin = _pinController.text;
                if (pin.isNotEmpty) {
                  widget.onPinSet(pin);
                }
              },
              child: const Text('Set PIN'),
            ),
          ],
        ),
      ),
    );
  
  
  
  }
}
