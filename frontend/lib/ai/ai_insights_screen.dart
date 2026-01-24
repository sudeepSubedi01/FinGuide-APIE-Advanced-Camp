import 'package:flutter/material.dart';

class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [
    {"role": "ai", "text": "Halo! Saya asisten FinGuide. Ada yang bisa saya bantu dengan keuanganmu?"}
  ];

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    setState(() {
      messages.add({"role": "user", "text": _controller.text});
      // Simulasi AI sedang berpikir
      messages.add({"role": "ai", "text": "Berdasarkan data transaksimu, bulan ini kamu paling banyak belanja di kategori 'Makanan'. Coba kurangi jajan ya!"});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Financial Advisor'), backgroundColor: Colors.teal),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isAi = messages[index]['role'] == 'ai';
                return ListTile(
                  title: Align(
                    alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isAi ? Colors.grey[200] : Colors.teal[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(messages[index]['text']!),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Tanya AI...'))),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}