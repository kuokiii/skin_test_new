import 'dart:io';
import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/prediction.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _history = HistoryService();
  late Future<List<Prediction>> _future;

  @override
  void initState() {
    super.initState();
    _future = _history.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<Prediction>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No history yet.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = items[i];
              return ListTile(
                leading: File(p.imagePath).existsSync() ? Image.file(File(p.imagePath), width: 54, height: 54, fit: BoxFit.cover) : const Icon(Icons.image_not_supported),
                title: Text('${p.label}  •  ${(p.confidence*100).toStringAsFixed(1)}%'),
                subtitle: Text(p.timestamp.toLocal().toString()),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _history.clear();
          if (mounted) setState(() { _future = _history.getAll(); });
        },
        icon: const Icon(Icons.delete_sweep),
        label: const Text('Clear all'),
      ),
    );
  }
}
