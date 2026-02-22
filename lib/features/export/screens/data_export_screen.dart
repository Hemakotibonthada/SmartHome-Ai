import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  final Set<String> _selectedDataTypes = {'energy', 'sensors', 'devices'};
  String _format = 'CSV';
  String _period = 'Last 7 Days';
  bool _includeCharts = true;
  bool _autoReport = false;
  String _autoFrequency = 'Weekly';
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildDataSelection(),
                    const SizedBox(height: 16),
                    _buildFormatOptions(),
                    const SizedBox(height: 16),
                    _buildPeriodSelection(),
                    const SizedBox(height: 16),
                    _buildExportOptions(),
                    const SizedBox(height: 16),
                    _buildAutoReports(),
                    const SizedBox(height: 24),
                    _buildExportButton(),
                    const SizedBox(height: 16),
                    _buildRecentExports(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text('Data Export', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
        ],
      ),
    );
  }

  // ===== DATA TYPE SELECTION =====
  Widget _buildDataSelection() {
    final types = [
      ('energy', Icons.bolt, 'Energy', const Color(0xFF4CAF50)),
      ('sensors', Icons.sensors, 'Sensors', const Color(0xFF2196F3)),
      ('devices', Icons.devices, 'Devices', const Color(0xFFFF9800)),
      ('activity', Icons.history, 'Activity', const Color(0xFF9C27B0)),
      ('security', Icons.security, 'Security', const Color(0xFFF44336)),
      ('water', Icons.water_drop, 'Water', const Color(0xFF00BCD4)),
    ];

    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: types.map((t) {
            final selected = _selectedDataTypes.contains(t.$1);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) { _selectedDataTypes.remove(t.$1); }
                else { _selectedDataTypes.add(t.$1); }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? t.$4.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: selected ? Border.all(color: t.$4.withValues(alpha: 0.3)) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.$2, size: 16, color: selected ? t.$4 : Colors.white38),
                    const SizedBox(width: 6),
                    Text(t.$3, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? t.$4 : Colors.white38)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ));
  }

  // ===== FORMAT OPTIONS =====
  Widget _buildFormatOptions() {
    final formats = ['CSV', 'JSON', 'PDF', 'Excel'];
    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Export Format', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: formats.map((f) {
            final selected = f == _format;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _format = f),
                child: Container(
                  margin: EdgeInsets.only(right: f != formats.last ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: selected ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)) : null,
                  ),
                  child: Text(f, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: selected ? AppTheme.primaryColor : Colors.white38)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ));
  }

  // ===== PERIOD SELECTION =====
  Widget _buildPeriodSelection() {
    final periods = ['Last 24h', 'Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'Custom'];
    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Time Period', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: periods.map((p) {
            final selected = p == _period;
            return GestureDetector(
              onTap: () => setState(() => _period = p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(p, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: selected ? AppTheme.primaryColor : Colors.white38)),
              ),
            );
          }).toList(),
        ),
      ],
    ));
  }

  // ===== ADDITIONAL OPTIONS =====
  Widget _buildExportOptions() {
    return _card(child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Include Charts', style: TextStyle(color: Colors.white, fontSize: 13)),
            Switch(value: _includeCharts, onChanged: (v) => setState(() => _includeCharts = v), activeColor: AppTheme.primaryColor),
          ],
        ),
      ],
    ));
  }

  // ===== AUTOMATED REPORTS (Feature 49) =====
  Widget _buildAutoReports() {
    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Automated Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Switch(value: _autoReport, onChanged: (v) => setState(() => _autoReport = v), activeColor: const Color(0xFF4CAF50)),
          ],
        ),
        if (_autoReport) ...[
          const SizedBox(height: 12),
          Row(
            children: ['Daily', 'Weekly', 'Monthly'].map((f) {
              final selected = f == _autoFrequency;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _autoFrequency = f),
                  child: Container(
                    margin: EdgeInsets.only(right: f != 'Monthly' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF4CAF50).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: selected ? const Color(0xFF4CAF50) : Colors.white38)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text('Reports will be generated and saved automatically', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ],
    ));
  }

  // ===== EXPORT BUTTON =====
  Widget _buildExportButton() {
    return GestureDetector(
      onTap: _selectedDataTypes.isEmpty ? null : () async {
        setState(() => _exporting = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() => _exporting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Exported ${_selectedDataTypes.length} data types as $_format ($_period)'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: _selectedDataTypes.isNotEmpty
              ? const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFF00D9FF)])
              : null,
          color: _selectedDataTypes.isEmpty ? Colors.white.withValues(alpha: 0.05) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _exporting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Export $_format', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                    color: _selectedDataTypes.isNotEmpty ? Colors.white : Colors.white38)),
                ],
              ),
      ),
    );
  }

  // ===== RECENT EXPORTS =====
  Widget _buildRecentExports() {
    final exports = [
      ('energy_report_dec_2024.csv', '2.3 MB', 'Dec 15, 2024'),
      ('sensors_weekly.pdf', '1.8 MB', 'Dec 12, 2024'),
      ('full_export_nov.json', '5.1 MB', 'Nov 30, 2024'),
    ];

    return _card(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Exports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...exports.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(
                e.$1.endsWith('.csv') ? Icons.table_chart
                    : e.$1.endsWith('.pdf') ? Icons.picture_as_pdf
                    : Icons.data_object,
                color: Colors.white38, size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.$1, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                    Text('${e.$2} • ${e.$3}', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ),
              ),
              const Icon(Icons.download_for_offline, color: Colors.white24, size: 20),
            ],
          ),
        )),
      ],
    ));
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }
}
