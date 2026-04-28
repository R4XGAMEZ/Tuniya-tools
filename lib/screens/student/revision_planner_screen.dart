import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class RevisionPlannerScreen extends StatefulWidget {
  const RevisionPlannerScreen({super.key});
  @override
  State<RevisionPlannerScreen> createState() => _RevisionPlannerScreenState();
}

class _RevisionPlannerScreenState extends State<RevisionPlannerScreen> {
  final List<Map<String, dynamic>> _topics = [];
  final _topicCtrl = TextEditingController();
  String _priority = 'Medium';
  String _reviseIn = '1 Day';
  bool _showForm = false;

  final _priorities = ['High', 'Medium', 'Low'];
  final _reviseInOptions = ['Today', '1 Day', '2 Days', '3 Days', '1 Week'];

  void _addTopic() {
    if (_topicCtrl.text.trim().isEmpty) return;
    final now = DateTime.now();
    int addDays = 0;
    switch (_reviseIn) {
      case '1 Day': addDays = 1; break;
      case '2 Days': addDays = 2; break;
      case '3 Days': addDays = 3; break;
      case '1 Week': addDays = 7; break;
    }
    setState(() {
      _topics.add({
        'topic': _topicCtrl.text.trim(),
        'priority': _priority,
        'reviseOn': now.add(Duration(days: addDays)),
        'done': false,
        'addedOn': now,
        'reviseIn': _reviseIn,
      });
      _topics.sort((a, b) => (a['reviseOn'] as DateTime).compareTo(b['reviseOn'] as DateTime));
      _topicCtrl.clear();
      _priority = 'Medium';
      _reviseIn = '1 Day';
      _showForm = false;
    });
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High': return AppTheme.red;
      case 'Medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  String _revisionStatus(DateTime reviseOn) {
    final now = DateTime.now();
    final diff = reviseOn.difference(now);
    if (diff.isNegative) return 'Overdue! ⚠️';
    if (diff.inDays == 0) return 'Today 🔔';
    if (diff.inDays == 1) return 'Tomorrow';
    return 'In ${diff.inDays} days';
  }

  Color _statusColor(DateTime reviseOn) {
    final diff = reviseOn.difference(DateTime.now());
    if (diff.isNegative) return AppTheme.red;
    if (diff.inDays == 0) return Colors.orange;
    if (diff.inDays <= 2) return Colors.yellow;
    return Colors.green;
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  int get _todayCount => _topics.where((t) {
    final diff = (t['reviseOn'] as DateTime).difference(DateTime.now());
    return diff.inDays == 0 && !diff.isNegative && !(t['done'] as bool);
  }).length;

  int get _overdueCount => _topics.where((t) {
    return (t['reviseOn'] as DateTime).difference(DateTime.now()).isNegative && !(t['done'] as bool);
  }).length;

  @override
  void dispose() { _topicCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Revision Planner', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 13)),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add, color: AppTheme.purple),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row
            Row(
              children: [
                Expanded(child: _statCard('📋 Total', '${_topics.length}', AppTheme.purple)),
                const SizedBox(width: 8),
                Expanded(child: _statCard('🔔 Today', '$_todayCount', Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _statCard('⚠️ Overdue', '$_overdueCount', AppTheme.red)),
              ],
            ),
            const SizedBox(height: 16),

            // Add form
            if (_showForm) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Topic for Revision', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 12)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.borderColor)),
                      child: TextField(
                        controller: _topicCtrl,
                        style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Topic name (e.g. Thermodynamics Ch3)',
                          hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary),
                          contentPadding: const EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Priority', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(children: _priorities.map((p) {
                      final sel = p == _priority;
                      return Expanded(child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? _priorityColor(p).withOpacity(0.25) : AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: sel ? _priorityColor(p) : AppTheme.borderColor),
                          ),
                          child: Center(child: Text(p, style: GoogleFonts.rajdhani(color: sel ? _priorityColor(p) : AppTheme.textSecondary, fontSize: 13, fontWeight: sel ? FontWeight.bold : FontWeight.normal))),
                        ),
                      ));
                    }).toList()),
                    const SizedBox(height: 12),
                    Text('Revise In', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, runSpacing: 6, children: _reviseInOptions.map((r) {
                      final sel = r == _reviseIn;
                      return GestureDetector(
                        onTap: () => setState(() => _reviseIn = r),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel ? AppTheme.purple : AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor),
                          ),
                          child: Text(r, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 12)),
                        ),
                      );
                    }).toList()),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addTopic,
                        icon: const Icon(Icons.add_alarm_outlined, size: 16),
                        label: Text('Add to Planner', style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.purple, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Topics list
            if (_topics.isEmpty && !_showForm)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.alarm_outlined, color: AppTheme.textSecondary, size: 50),
                      const SizedBox(height: 12),
                      Text('Koi topic nahi add kiya abhi', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text('+ button se topic add karo', style: GoogleFonts.rajdhani(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 12)),
                    ],
                  ),
                ),
              )
            else ...[
              // Overdue section
              if (_overdueCount > 0) ...[
                _sectionHeader('⚠️ Overdue', AppTheme.red),
                ..._topics.where((t) =>
                  (t['reviseOn'] as DateTime).difference(DateTime.now()).isNegative && !(t['done'] as bool)
                ).map((t) => _topicCard(t)),
                const SizedBox(height: 10),
              ],
              // Today
              if (_todayCount > 0) ...[
                _sectionHeader('🔔 Today\'s Revision', Colors.orange),
                ..._topics.where((t) {
                  final diff = (t['reviseOn'] as DateTime).difference(DateTime.now());
                  return diff.inDays == 0 && !diff.isNegative && !(t['done'] as bool);
                }).map((t) => _topicCard(t)),
                const SizedBox(height: 10),
              ],
              // Upcoming
              ...() {
                final upcoming = _topics.where((t) {
                  final diff = (t['reviseOn'] as DateTime).difference(DateTime.now());
                  return diff.inDays > 0 && !(t['done'] as bool);
                }).toList();
                return upcoming.isNotEmpty ? [
                  _sectionHeader('📅 Upcoming', AppTheme.purple),
                  ...upcoming.map((t) => _topicCard(t)),
                  const SizedBox(height: 10),
                ] : <Widget>[];
              }(),
              ...() {
                final done = _topics.where((t) => t['done'] as bool).toList();
                return done.isNotEmpty ? [
                  _sectionHeader('✅ Completed', Colors.green),
                  ...done.map((t) => _topicCard(t)),
                ] : <Widget>[];
              }(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.orbitron(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: GoogleFonts.orbitron(color: color, fontSize: 11)),
    );
  }

  Widget _topicCard(Map<String, dynamic> t) {
    final isDone = t['done'] as bool;
    final reviseOn = t['reviseOn'] as DateTime;
    final priority = t['priority'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone ? AppTheme.cardBg.withOpacity(0.4) : AppTheme.cardBg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDone ? AppTheme.borderColor.withOpacity(0.3) : AppTheme.borderColor),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => t['done'] = !isDone),
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? Colors.green.withOpacity(0.2) : Colors.transparent,
                border: Border.all(color: isDone ? Colors.green : AppTheme.borderColor),
              ),
              child: isDone ? const Icon(Icons.check, size: 14, color: Colors.green) : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['topic'] as String,
                    style: GoogleFonts.rajdhani(
                      color: isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    )),
                const SizedBox(height: 2),
                Text('Revise: ${_formatDate(reviseOn)}',
                    style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _priorityColor(priority).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(priority, style: GoogleFonts.rajdhani(color: _priorityColor(priority), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(_revisionStatus(reviseOn),
                  style: GoogleFonts.rajdhani(color: _statusColor(reviseOn), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _topics.remove(t)),
            child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }
}
