import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/prescription_model.dart';
import '../models/doctor_model.dart';
import '../models/hospital_model.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';

class PdfService {
  static Future<void> generatePrescriptionPdf({
    required PrescriptionModel prescription,
    required DoctorModel doctor,
    required HospitalModel? hospital,
    required UserModel patientUser,
    required AppointmentModel? appointment,
    String? patientName,
    String? patientAge,
    String? patientGender,
    String? patientAddress,
    String? guardianName,
    String? relationship,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - Hospital/Clinic Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        hospital?.hospitalName ?? doctor.clinicName ?? "Medical Center",
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(hospital?.address ?? doctor.clinicName ?? ""),
                      pw.Text("${hospital?.city ?? ""}, ${hospital?.state ?? ""}"),
                      pw.Text("Contact: ${hospital?.contactNumber ?? doctor.mobileNumber}"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Date: ${DateFormat('dd MMM yyyy').format(prescription.createdAt)}"),
                      pw.Text(
                        "ID: ${prescription.prescriptionId.length > 8 ? prescription.prescriptionId.substring(0, 8).toUpperCase() : prescription.prescriptionId.toUpperCase()}",
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.blue900),
              pw.SizedBox(height: 10),

              // Doctor Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(doctor.doctorName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text(doctor.qualification.join(", ")),
                      pw.Text(doctor.specialization.join(", "), style: const pw.TextStyle(color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [pw.Text("Mob: ${doctor.mobileNumber}"), pw.Text("Email: ${doctor.email}")],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Patient Info Section
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Patient Name: ${patientName ?? patientUser.name}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text("Relation: ${relationship ?? 'Self'}"),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Age: ${patientAge ?? 'N/A'} | Gender: ${patientGender ?? 'N/A'}"),
                        if (guardianName != null && guardianName.isNotEmpty) pw.Text("Guardian: $guardianName"),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text("Address: ${patientAddress ?? 'N/A'}"),
                    if (appointment?.symptoms != null && appointment!.symptoms.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text("Symptoms: ${appointment.symptoms}", style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Prescription Body
              pw.Text(
                "Rx (Prescription)",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
              ),
              pw.SizedBox(height: 10),

              // Medicines Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                    children: [_tableHeader("Medicine Name"), _tableHeader("Dosage"), _tableHeader("Frequency"), _tableHeader("Duration")],
                  ),
                  ...prescription.medicines.map(
                    (m) =>
                        pw.TableRow(children: [_tableCell(m.name), _tableCell(m.dosage), _tableCell(m.frequency), _tableCell(m.duration)]),
                  ),
                ],
              ),

              if (prescription.tests.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text("Recommended Tests:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: prescription.tests.join(", ")),
              ],

              pw.SizedBox(height: 20),
              pw.Text("Remarks:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(prescription.doctorRemarks),

              if (prescription.referredHospitalName != null && prescription.referredHospitalName!.isNotEmpty) ...[
                pw.SizedBox(height: 15),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue800, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "HOSPITAL REFERRAL / APPOINTMENT LETTER",
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                      ),
                      pw.SizedBox(height: 4),
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: "Referred To Hospital: ",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.TextSpan(text: prescription.referredHospitalName!),
                          ],
                        ),
                      ),
                      if (prescription.referralNotes != null && prescription.referralNotes!.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.RichText(
                          text: pw.TextSpan(
                            children: [
                              pw.TextSpan(
                                text: "Referral Reason / Dept: ",
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              pw.TextSpan(text: prescription.referralNotes!),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              pw.Spacer(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (prescription.followUpDate != null)
                        pw.Text(
                          "Follow-up Date: ${prescription.followUpDate}",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.orange),
                        ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.SizedBox(height: 40),
                      pw.Container(
                        width: 120,
                        decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide())),
                      ),
                      pw.Text("Doctor's Signature"),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Display PDF for print/sharing
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  // ── Print Doctor QR Code Poster ──
  static Future<void> printDoctorQrPoster({required String doctorName, required String specialization, required String uid}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(32),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue800, width: 4),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "Ayu Veda Care",
                    style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "SCAN TO BOOK APPOINTMENT",
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700, letterSpacing: 1.5),
                  ),
                  pw.SizedBox(height: 30),

                  // QR Container
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 2)),
                    child: pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: uid, width: 240, height: 240),
                  ),
                  pw.SizedBox(height: 30),

                  pw.Text(
                    doctorName,
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(specialization, style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                  pw.SizedBox(height: 40),
                  pw.Divider(thickness: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "Powered by Ayu Veda Care App",
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(name: 'Doctor_QR_Poster', onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
