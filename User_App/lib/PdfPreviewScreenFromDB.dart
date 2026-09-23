import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

class Pdfpreviewscreenfromdb extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const Pdfpreviewscreenfromdb({
    Key? key,
    required this.fileUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  State<Pdfpreviewscreenfromdb> createState() => _PdfpreviewscreenfromdbState();
}

class _PdfpreviewscreenfromdbState extends State<Pdfpreviewscreenfromdb> {
  PdfController? controller;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      final url = widget.fileUrl.trim();

      print("PDF URL: $url");

      final response = await http.get(Uri.parse(url));

      print("Status: ${response.statusCode}");
      print("Type: ${response.headers['content-type']}");
      print("Bytes length: ${response.bodyBytes.length}");

      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;

        if (bytes.length < 4) {
          throw Exception("File empty hai");
        }

        final header = String.fromCharCodes(bytes.take(4));

        print("PDF Header: $header");

        if (header != "%PDF") {
          throw Exception("Ye actual PDF nahi hai. Server HTML/Error return kar raha hai.");
        }

        controller = PdfController(
          document: PdfDocument.openData(bytes),
        );

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception("Unauthorized ya expired URL. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("PDF Load Error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName.isEmpty ? "PDF Preview" : widget.fileName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            errorMsg!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      )
          : PdfView(controller: controller!),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}