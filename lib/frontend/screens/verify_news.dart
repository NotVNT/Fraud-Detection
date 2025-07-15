import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class VerifyNews extends StatefulWidget {
  const VerifyNews({super.key});

  @override
  State<VerifyNews> createState() => _VerifyNewsState();
}

class _VerifyNewsState extends State<VerifyNews> {
  File? _imageFile;
  String _result = '';
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _checkFakeNews() async {
    if (_imageFile == null) return;
    setState(() => _loading = true);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2:5000"),
    );
    request.files.add(
      await http.MultipartFile.fromPath('image', _imageFile!.path),
    );
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    setState(() {
      _loading = false;
      _result = responseBody;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra tin giả từ ảnh')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : const Text('Chưa chọn ảnh nào'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Chọn ảnh'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_imageFile == null || _loading)
                  ? null
                  : _checkFakeNews,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Kiểm tra'),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Text('Kết quả: $_result', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
