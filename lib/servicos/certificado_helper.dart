import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CertificadoHelper {
  static Future<void> gerarEVisualizar({
    required String nomeAluno,
    required String nomeEvento,
    required String matricula,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(30),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.red900, width: 5),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text("CERTIFICADO DE PARTICIPAÇÃO", 
                      style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 30),
                  pw.Text("Certificamos que o(a) aluno(a)", style: const pw.TextStyle(fontSize: 20)),
                  pw.SizedBox(height: 10),
                  pw.Text(nomeAluno, 
                      style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                  pw.Text("Matrícula: $matricula", style: const pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 20),
                  pw.Text("participou com êxito do evento", style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(nomeEvento, 
                      style: pw.TextStyle(fontSize: 25, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 40),
                  pw.Text("Gerado automaticamente pelo SECOMP App em 2026", style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}