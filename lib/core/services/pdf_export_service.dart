// lib/core/services/pdf_export_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/home/data/models/vehicle_model.dart';

class PdfExportService {
  const PdfExportService();

  Future<void> exportMaintenanceBook({
    required Vehicle vehicle,
    required double totalSavings,
  }) async {
    try {
      final pdf = await _generatePdf(
        vehicle: vehicle,
        totalSavings: totalSavings,
      );

      await Printing.sharePdf(
        bytes: pdf,
        filename:
            'MecaGo_${vehicle.brand}_${vehicle.model}_${vehicle.plate}.pdf',
      );

      debugPrint('✅ PDF exporté avec succès');
    } catch (e) {
      debugPrint('❌ Erreur export PDF : $e');
      rethrow;
    }
  }

  Future<void> printMaintenanceBook({
    required Vehicle vehicle,
    required double totalSavings,
  }) async {
    try {
      final pdf = await _generatePdf(
        vehicle: vehicle,
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

  Future<Uint8List> _generatePdf({
    required Vehicle vehicle,
    required double totalSavings,
  }) async {
    final pdf = pw.Document(
      title: 'Carnet d\'entretien MecaGo',
      author: 'MecaGo',
      creator: 'MecaGo Premium',
    );

    const orange = PdfColor.fromInt(0xFFFF6A00);
    const navy = PdfColor.fromInt(0xFF0A0F1C);
    const grey = PdfColor.fromInt(0xFF64748B);
    const lightGrey = PdfColor.fromInt(0xFFF8FAFC);
    const success = PdfColor.fromInt(0xFF10B981);

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
                    'PREMIUM',
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
                  vehicle.fuelType.label,
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
                'Économies',
                '${totalSavings.toStringAsFixed(0)} EUR',
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
                  'Document certifié MecaGo',
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
                  'Généré le ${_formatDate(DateTime.now().toIso8601String())} - mecago.fr',
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

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      final months = [
        'Janvier',
        'Février',
        'Mars',
        'Avril',
        'Mai',
        'Juin',
        'Juillet',
        'Août',
        'Septembre',
        'Octobre',
        'Novembre',
        'Décembre'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return date;
    }
  }
}