// lib/core/services/pdf_export_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/home/data/models/vehicle_model.dart';
import '../../features/home/data/models/maintenance_log_model.dart';

class PdfExportService {
  const PdfExportService();

  /// Génère et partage le carnet d'entretien PDF
  Future<void> exportMaintenanceBook({
    required Vehicle vehicle,
    required List<MaintenanceLog> logs,
    required double totalSavings,
  }) async {
    try {
      final pdf = await _generatePdf(
        vehicle: vehicle,
        logs: logs,
        totalSavings: totalSavings,
      );

      await Printing.sharePdf(
        bytes: pdf,
        filename: 'MecaGo_${vehicle.brand}_${vehicle.model}_${vehicle.plate}.pdf',
      );

      debugPrint('✅ PDF exporté avec succès');
    } catch (e) {
      debugPrint('❌ Erreur export PDF : $e');
      rethrow;
    }
  }

  /// Génère et imprime le carnet d'entretien
  Future<void> printMaintenanceBook({
    required Vehicle vehicle,
    required List<MaintenanceLog> logs,
    required double totalSavings,
  }) async {
    try {
      final pdf = await _generatePdf(
        vehicle: vehicle,
        logs: logs,
        totalSavings: totalSavings,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
        name: 'MecaGo_${vehicle.brand}_${vehicle.model}',
      );

      debugPrint('✅ PDF imprimé');
    } catch (e) {
      debugPrint('❌ Erreur impression PDF : $e');
      rethrow;
    }
  }

  /// Génère le PDF en bytes
  Future<Uint8List> _generatePdf({
    required Vehicle vehicle,
    required List<MaintenanceLog> logs,
    required double totalSavings,
  }) async {
    final pdf = pw.Document(
      title: 'Carnet d\'entretien MecaGo',
      author: 'MecaGo',
      creator: 'MecaGo Premium',
    );

    // Couleurs
    const orange = PdfColor.fromInt(0xFFFF6A00);
    const navy = PdfColor.fromInt(0xFF0F172A);
    const grey = PdfColor.fromInt(0xFF64748B);
    const lightGrey = PdfColor.fromInt(0xFFF8FAFC);
    const success = PdfColor.fromInt(0xFF10B981);

    // ============================================
    // PAGE 1 : COUVERTURE + RÉSUMÉ
    // ============================================
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // En-tête
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: navy,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MecaGo',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Carnet d\'entretien certifié',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: orange,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    '👑 PREMIUM',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          // Infos véhicule
          pw.Text(
            'Véhicule',
            style: pw.TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: lightGrey,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              children: [
                _buildInfoRow('Marque', vehicle.brand, navy, grey),
                _buildInfoRow('Modèle', vehicle.model, navy, grey),
                _buildInfoRow('Immatriculation', vehicle.plate, navy, grey),
                _buildInfoRow('Année', vehicle.year.toString(), navy, grey),
                _buildInfoRow(
                  'Kilométrage',
                  '${vehicle.mileage} km',
                  navy,
                  grey,
                ),
                _buildInfoRow(
                  'Motorisation',
                  '${vehicle.fuelType.icon} ${vehicle.fuelType.label}',
                  navy,
                  grey,
                ),
                _buildInfoRow(
                  'Transmission',
                  vehicle.transmission.label,
                  navy,
                  grey,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          // Résumé
          pw.Text(
            'Résumé',
            style: pw.TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _buildStatBox(
                'Interventions',
                '${logs.length}',
                navy,
                lightGrey,
              ),
              pw.SizedBox(width: 12),
              _buildStatBox(
                'Économies',
                '${totalSavings.toStringAsFixed(0)} €',
                success,
                lightGrey,
              ),
              pw.SizedBox(width: 12),
              _buildStatBox(
                'Santé',
                '${(vehicle.progress * 100).toInt()}%',
                orange,
                lightGrey,
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          // Historique
          pw.Text(
            'Historique des interventions',
            style: pw.TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),

          // Tableau des interventions
          if (logs.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: lightGrey,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Center(
                child: pw.Text(
                  'Aucune intervention enregistrée',
                  style: const pw.TextStyle(color: grey, fontSize: 12),
                ),
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromInt(0xFFE2E8F0),
                width: 0.5,
              ),
              children: [
                // En-tête
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: navy),
                  children: [
                    _buildTableCell('Date', isHeader: true),
                    _buildTableCell('Intervention', isHeader: true),
                    _buildTableCell('Km', isHeader: true),
                    _buildTableCell('Coût', isHeader: true),
                    _buildTableCell('Économie', isHeader: true),
                  ],
                ),
                // Lignes
                ...logs.map((log) => pw.TableRow(
                      children: [
                        _buildTableCell(_formatDate(log.date)),
                        _buildTableCell(log.title),
                        _buildTableCell('${log.mileage}'),
                        _buildTableCell('${log.cost.toStringAsFixed(2)} €'),
                        _buildTableCell(
                          '−${log.saved.toStringAsFixed(2)} €',
                          isSuccess: true,
                        ),
                      ],
                    )),
              ],
            ),

          pw.SizedBox(height: 30),

          // Pied de page
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: lightGrey,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '📄 Document certifié MecaGo',
                  style: pw.TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Ce carnet d\'entretien a été généré automatiquement par l\'application MecaGo. '
                  'Il atteste de toutes les interventions réalisées sur le véhicule.',
                  style: const pw.TextStyle(color: grey, fontSize: 10),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Généré le ${_formatDate(DateTime.now().toIso8601String())} · '
                  'mecago.fr',
                  style: const pw.TextStyle(color: grey, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ============================================
  // HELPERS
  // ============================================

  pw.Widget _buildInfoRow(
    String label,
    String value,
    PdfColor navy,
    PdfColor grey,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(color: grey, fontSize: 11),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: navy,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatBox(
    String label,
    String value,
    PdfColor color,
    PdfColor bg,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isSuccess = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: isHeader
              ? PdfColors.white
              : isSuccess
                  ? const PdfColor.fromInt(0xFF10B981)
                  : const PdfColor.fromInt(0xFF0F172A),
          fontSize: 10,
          fontWeight: isHeader || isSuccess
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      final months = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return date;
    }
  }
}
