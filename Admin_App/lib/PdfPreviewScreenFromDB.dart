import 'dart:io';

import 'package:adminlikhwao/Toast/ToastHelper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_scanner/media_scanner.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:permission_handler/permission_handler.dart';

class Pdfpreviewscreenfromdb extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const Pdfpreviewscreenfromdb({
    Key? key,
    required this.fileUrl,
    required this.fileName,
  }) : super(key: key);

  @override
  State<Pdfpreviewscreenfromdb> createState() =>
      _PdfpreviewscreenfromdbState();
}

class _PdfpreviewscreenfromdbState extends State<Pdfpreviewscreenfromdb> {
  PdfController? controller;

  bool isLoading = true;
  bool isDownloading = false;
  double downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        title: const Text(
          "PDF Preview",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0B164A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : PdfView(
        controller: controller!,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isDownloading
              ? null
              : () async {
            setState(() {
              isDownloading = true;
              downloadProgress = 0.0;
            });

            await downloadPdf(
              signedUrl: widget.fileUrl,
              fileName: widget.fileName,
              context: context,
            );

            if (mounted) {
              setState(() {
                isDownloading = false;
                downloadProgress = 0.0;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDownloading
                  ? Colors.deepOrange.withOpacity(0.65)
                  : Colors.deepOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isDownloading
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: downloadProgress == 0.0
                      ? null
                      : downloadProgress,
                  backgroundColor: Colors.white30,
                  color: Colors.white,
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Text(
                  downloadProgress == 0.0
                      ? "Saving..."
                      : "${(downloadProgress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Download",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.fileUrl));

      print("PDF STATUS: ${response.statusCode}");
      print("PDF URL: ${widget.fileUrl}");

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        controller = PdfController(
          document: PdfDocument.openData(response.bodyBytes),
        );

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception("Not a PDF or unauthorized");
      }
    } catch (e) {
      print("PDF Load Error: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      ToastHelper.show("Unable to load PDF", context);
    }
  }

  Future<void> downloadPdf({
    required String signedUrl,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      ToastHelper.show("Download started", context);

      String cleanFileName = fileName.trim();

      if (cleanFileName.isEmpty || cleanFileName == "Uploaded work file") {
        cleanFileName = "writer_submission.pdf";
      }

      cleanFileName = cleanFileName.replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        "_",
      );

      if (!cleanFileName.toLowerCase().endsWith(".pdf")) {
        cleanFileName = "$cleanFileName.pdf";
      }

      final client = http.Client();
      final request = http.Request(
        "GET",
        Uri.parse(signedUrl),
      );

      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception("Download failed");
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      List<int> bytes = [];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;

        if (totalBytes > 0 && mounted) {
          setState(() {
            downloadProgress = receivedBytes / totalBytes;
          });
        }
      }

      print("DOWNLOAD BYTES: ${bytes.length}");

      if (bytes.isEmpty) {
        throw Exception("Empty file");
      }

      if (Platform.isAndroid) {
        await MediaStore.ensureInitialized();
        MediaStore.appFolder = "Likho";

        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdk = androidInfo.version.sdkInt;

        if (sdk <= 28) {
          final permission = await Permission.storage.request();

          if (!permission.isGranted) {
            ToastHelper.show("Storage permission denied", context);
            return;
          }
        }

        final tempDir = await getTemporaryDirectory();
        final tempFile = File("${tempDir.path}/$cleanFileName");

        await tempFile.writeAsBytes(
          bytes,
          flush: true,
        );

        print("TEMP FILE PATH: ${tempFile.path}");
        print("TEMP FILE EXISTS: ${await tempFile.exists()}");
        print("TEMP FILE SIZE: ${await tempFile.length()}");

        final mediaStore = MediaStore();

        final saveInfo = await mediaStore.saveFile(
          tempFilePath: tempFile.path,
          dirType: DirType.download,
          dirName: DirName.download,
        );

        print("MEDIA STORE SAVE INFO: $saveInfo");

        try {
          await MediaScanner.loadMedia(path: tempFile.path);
        } catch (e) {
          print("Media scanner error: $e");
        }

        ToastHelper.show("PDF saved in Downloads", context);
      } else if (Platform.isIOS) {
        ToastHelper.show("iOS download handling pending", context);
      } else {
        ToastHelper.show("Unsupported platform", context);
      }
    } catch (e) {
      print("Download Error: $e");
      ToastHelper.show("Download failed", context);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}