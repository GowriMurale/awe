import 'package:awe_project/Components/helper_class.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
class Termscreen extends StatelessWidget {
  const Termscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: SfPdfViewer.asset('assets/pdf/Leave Form.pdf'), // Display the PDF
    );
  }
}
