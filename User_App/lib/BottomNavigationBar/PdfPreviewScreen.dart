import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Pdfpreviewscreen extends StatefulWidget {
  final File pdfFile; // final

  const Pdfpreviewscreen({Key? key, required this.pdfFile}) : super(key: key);

  @override
  State<Pdfpreviewscreen> createState() => _PdfpreviewscreenState();
}

class _PdfpreviewscreenState extends State<Pdfpreviewscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: PDFView(
        filePath: widget.pdfFile.path,
      ),
    );
  }
}
