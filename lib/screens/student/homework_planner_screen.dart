import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class HomeworkPlannerScreen extends StatefulWidget {
  const HomeworkPlannerScreen({super.key});
  @override
  State<HomeworkPlannerScreen> createState() => _HomeworkPlannerScreenState();
}

class _HomeworkPlannerScreenState extends State<HomeworkPlannerScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  final _taskCtrl = TextEditingController();
  final _subCtrl = TextEditingController();
  String _priority = 'Medium';
  String _filter = 'All';
  final _priorities = ['High', 'Medium', 'Low'];
  final _filters = ['All', 'Pending', 'Done'];

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'Pending') return _tasks.where((t) => !(t['done'] as bool)).toList();
    if (_filter == 'Done') return _tasks.where((t) => t['done'] as bool).toList();
    return _tasks;
  }

  void _add() {
    if (_taskCtrl.text.trim().isEmpty) return;
    setState(() {
      _tasks.add({'task': _taskCtrl.text.trim(), 'subject': _subCtrl.text.trim(), 'priority': _priority, 'done': false, 'added': DateTime.now()});
      _tasks.sort((a, b) {
        const order = {'High': 0, 'Medium': 1, 'Low': 2};
        return order[a['priority']]!.compareTo(order[b['priority']]!);
      });
      _taskCtrl.clear(); _subCtrl.clear();
    });
    Navigator.pop(context);
  }

  Color _priorityColor(String p) {
    if (p == 'High') return AppTheme.red;
    if (p == 'Medium') return Colors.orange;
    return Colors.green;
  }

  void _showAdd() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Homework', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
              const SizedBox(height: 14),
              TextField(
                controller: _taskCtrl,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
                decoration: InputDecoration(hintText: 'Task (e.g. Chapter 5 complete karo)', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), filled: true, fillColor: AppTheme.cardBg2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _subCtrl,
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
                decoration: InputDecoration(hintText: 'Subject (optional)', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), filled: true, fillColor: AppTheme.cardBg2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              Text('Priority', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Row(children: _priorities.map((p) {
                final sel = _priority == p;
                return Expanded(child: GestureDetector(
                  onTap: () { setS(() => _priority = p); setState(() => _priority = p); },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: sel ? _priorityColor(p).withOpacity(0.2) : AppTheme.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? _priorityColor(p) : AppTheme.borderColor)),
                    child: Center(child: Text(p, style: GoogleFonts.rajdhani(color: sel ? _priorityColor(p) : AppTheme.textPrimary, fontWeight: FontWeight.bold))),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _add, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)), child: Text('Add Task', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _taskCtrl.dispose(); _subCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final done = _tasks.where((t) => t['done'] as bool).length;
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Homework Planner', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
        actions: [Text('$done/${_tasks.length} done', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 13)), const SizedBox(width: 12)],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAdd, backgroundColor: AppTheme.purple, child: const Icon(Icons.add, color: Colors.white)),
      body: Column(
        children: [
          // Filter bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: _filters.map((f) {
              final sel = f == _filter;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)),
                  child: Text(f, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 13)),
                ),
              );
            }).toList()),
          ),
          if (_tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(value: _tasks.isEmpty ? 0 : done / _tasks.length, backgroundColor: AppTheme.cardBg2, color: Colors.green),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('Koi task nahi', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final t = _filtered[i];
                      final done = t['done'] as bool;
                      final color = _priorityColor(t['priority'] as String);
                      return Dismissible(
                        key: Key('${t['task']}$i'),
                        onDismissed: (_) => setState(() => _tasks.remove(t)),
                        background: Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete, color: Colors.white)),
                        child: GestureDetector(
                          onTap: () => setState(() => t['done'] = !done),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: done ? AppTheme.borderColor : color.withOpacity(0.4))),
                            child: Row(
                              children: [
                                Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.green : color, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(t['task'] as String, style: GoogleFonts.rajdhani(color: done ? AppTheme.textSecondary : AppTheme.textPrimary, fontSize: 14, decoration: done ? TextDecoration.lineThrough : null)),
                                    if ((t['subject'] as String).isNotEmpty)
                                      Text(t['subject'] as String, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                                  ]),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Text(t['priority'] as String, style: GoogleFonts.rajdhani(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
