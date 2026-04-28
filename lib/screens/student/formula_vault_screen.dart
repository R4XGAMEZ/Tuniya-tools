import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class FormulaVaultScreen extends StatefulWidget {
  const FormulaVaultScreen({super.key});
  @override
  State<FormulaVaultScreen> createState() => _FormulaVaultScreenState();
}

class _FormulaVaultScreenState extends State<FormulaVaultScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedSubject = 'All';
  String _query = '';

  final List<Map<String, String>> _formulas = [
    {'subject': 'Math', 'name': 'Area of Circle', 'formula': 'A = πr²', 'desc': 'r = radius'},
    {'subject': 'Math', 'name': 'Circumference', 'formula': 'C = 2πr', 'desc': 'r = radius'},
    {'subject': 'Math', 'name': 'Quadratic Formula', 'formula': 'x = (-b ± √(b²-4ac)) / 2a', 'desc': 'For ax² + bx + c = 0'},
    {'subject': 'Math', 'name': 'Pythagoras Theorem', 'formula': 'a² + b² = c²', 'desc': 'c = hypotenuse'},
    {'subject': 'Math', 'name': 'Simple Interest', 'formula': 'SI = (P × R × T) / 100', 'desc': 'P=Principal, R=Rate, T=Time'},
    {'subject': 'Math', 'name': 'Compound Interest', 'formula': 'A = P(1 + R/100)ⁿ', 'desc': 'n = years'},
    {'subject': 'Math', 'name': 'Slope of Line', 'formula': 'm = (y₂-y₁) / (x₂-x₁)', 'desc': 'Gradient between two points'},
    {'subject': 'Math', 'name': 'Distance Formula', 'formula': 'd = √((x₂-x₁)² + (y₂-y₁)²)', 'desc': 'Between two points'},
    {'subject': 'Physics', 'name': "Newton's 2nd Law", 'formula': 'F = ma', 'desc': 'F=Force, m=mass, a=acceleration'},
    {'subject': 'Physics', 'name': 'Kinetic Energy', 'formula': 'KE = ½mv²', 'desc': 'm=mass, v=velocity'},
    {'subject': 'Physics', 'name': 'Potential Energy', 'formula': 'PE = mgh', 'desc': 'm=mass, g=9.8m/s², h=height'},
    {'subject': 'Physics', 'name': 'Ohm\'s Law', 'formula': 'V = IR', 'desc': 'V=Voltage, I=Current, R=Resistance'},
    {'subject': 'Physics', 'name': 'Power', 'formula': 'P = VI = I²R = V²/R', 'desc': 'Electrical power formulas'},
    {'subject': 'Physics', 'name': 'Wave Speed', 'formula': 'v = fλ', 'desc': 'f=frequency, λ=wavelength'},
    {'subject': 'Physics', 'name': 'Density', 'formula': 'ρ = m/V', 'desc': 'm=mass, V=volume'},
    {'subject': 'Physics', 'name': 'Speed', 'formula': 'v = d/t', 'desc': 'd=distance, t=time'},
    {'subject': 'Chemistry', 'name': 'Ideal Gas Law', 'formula': 'PV = nRT', 'desc': 'P=Pressure, V=Volume, n=moles, R=8.314, T=Temp(K)'},
    {'subject': 'Chemistry', 'name': 'Molarity', 'formula': 'M = n/V', 'desc': 'n=moles, V=volume in litres'},
    {'subject': 'Chemistry', 'name': 'pH Formula', 'formula': 'pH = -log[H⁺]', 'desc': 'H⁺ = hydrogen ion concentration'},
    {'subject': 'Chemistry', 'name': 'Mole Concept', 'formula': 'n = m/M', 'desc': 'm=mass, M=molar mass'},
    {'subject': 'Biology', 'name': 'Photosynthesis', 'formula': '6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂', 'desc': 'Light energy converts CO₂ to glucose'},
    {'subject': 'Biology', 'name': 'Respiration', 'formula': 'C₆H₁₂O₆ + 6O₂ → 6CO₂ + 6H₂O + ATP', 'desc': 'Cellular respiration'},
    {'subject': 'Trigonometry', 'name': 'sin²θ + cos²θ', 'formula': 'sin²θ + cos²θ = 1', 'desc': 'Pythagorean identity'},
    {'subject': 'Trigonometry', 'name': 'tan θ', 'formula': 'tan θ = sin θ / cos θ', 'desc': 'Tangent definition'},
    {'subject': 'Trigonometry', 'name': 'Area of Triangle', 'formula': 'A = ½ × base × height', 'desc': 'Or A = ½absinC'},
  ];

  final _nameCtrl = TextEditingController();
  final _formulaCtrl = TextEditingController();
  final _descCtrl2 = TextEditingController();
  String _newSubject = 'Math';

  List<Map<String, String>> get _filtered {
    return _formulas.where((f) {
      final matchSubject = _selectedSubject == 'All' || f['subject'] == _selectedSubject;
      final matchQuery = _query.isEmpty ||
          f['name']!.toLowerCase().contains(_query.toLowerCase()) ||
          f['formula']!.toLowerCase().contains(_query.toLowerCase());
      return matchSubject && matchQuery;
    }).toList();
  }

  List<String> get _subjects {
    final s = {'All', ..._formulas.map((f) => f['subject']!)};
    return s.toList();
  }

  void _addFormula() {
    if (_nameCtrl.text.trim().isEmpty || _formulaCtrl.text.trim().isEmpty) return;
    setState(() {
      _formulas.add({'subject': _newSubject, 'name': _nameCtrl.text.trim(), 'formula': _formulaCtrl.text.trim(), 'desc': _descCtrl2.text.trim()});
      _nameCtrl.clear(); _formulaCtrl.clear(); _descCtrl2.clear();
    });
    Navigator.pop(context);
  }

  void _showAdd() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add Formula', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(controller: _nameCtrl, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary), decoration: InputDecoration(hintText: 'Formula Name', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), filled: true, fillColor: AppTheme.cardBg2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
          const SizedBox(height: 8),
          TextField(controller: _formulaCtrl, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary), decoration: InputDecoration(hintText: 'Formula (e.g. F = ma)', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), filled: true, fillColor: AppTheme.cardBg2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
          const SizedBox(height: 8),
          TextField(controller: _descCtrl2, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary), decoration: InputDecoration(hintText: 'Description (optional)', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), filled: true, fillColor: AppTheme.cardBg2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _addFormula, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)), child: Text('Save Formula', style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.bold)))),
        ]),
      ),
    );
  }

  @override
  void dispose() { _searchCtrl.dispose(); _nameCtrl.dispose(); _formulaCtrl.dispose(); _descCtrl2.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Formula Vault', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 15)),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAdd, backgroundColor: AppTheme.purple, child: const Icon(Icons.add, color: Colors.white)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.rajdhani(color: AppTheme.textPrimary),
                decoration: InputDecoration(hintText: 'Search formulas...', hintStyle: GoogleFonts.rajdhani(color: AppTheme.textSecondary), contentPadding: const EdgeInsets.all(12), border: InputBorder.none, prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary)),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _subjects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final sel = _subjects[i] == _selectedSubject;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSubject = _subjects[i]),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: sel ? AppTheme.purple : AppTheme.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.purple : AppTheme.borderColor)), child: Text(_subjects[i], style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 12))),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final f = _filtered[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.purple.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)), child: Text(f['subject']!, style: GoogleFonts.rajdhani(color: AppTheme.purple, fontSize: 10, fontWeight: FontWeight.bold))),
                            const SizedBox(width: 8),
                            Text(f['name']!, style: GoogleFonts.rajdhani(color: AppTheme.textSecondary, fontSize: 12)),
                          ]),
                          const SizedBox(height: 6),
                          Text(f['formula']!, style: GoogleFonts.rajdhani(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                          if (f['desc']!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(f['desc']!, style: GoogleFonts.rajdhani(color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_outlined, color: AppTheme.textSecondary, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '${f['name']}: ${f['formula']}'));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied!', style: GoogleFonts.rajdhani()), backgroundColor: AppTheme.purple, duration: const Duration(seconds: 1)));
                        },
                      ),
                    ],
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
