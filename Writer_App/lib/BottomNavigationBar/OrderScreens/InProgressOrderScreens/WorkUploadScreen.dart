import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:likho/ApiConfig/apiConfig.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/InProgressOrderScreens/InProgressOrderScreen.dart';
import 'package:likho/BottomNavigationBar/OrderScreens/ReviewScreen/reviewScreen.dart';
import 'package:likho/Model/OrdersDetailsModel.dart';
import 'package:likho/Model/WriterWorkModel.dart';
import 'package:likho/PdfPreviewScreen.dart';
import 'package:likho/Toast/ToastHelper.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';

class Workuploadscreen extends StatefulWidget {
  final Ordersdetailsmodel orders;

  const Workuploadscreen({super.key, required this.orders});

  @override
  State<Workuploadscreen> createState() => _WorkuploadscreenState();
}

class _WorkuploadscreenState extends State<Workuploadscreen> {


  bool isPdfView = false;
  File? selectedPdfFile;

  String? fileName;
  int? fileSize;
  int? filePageCount;
  bool? isPickingPdf = false;
  bool isUploading = false ;

  bool isChecked = false;

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    } else if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
  }

  final TextEditingController writerSuggestionController =
      TextEditingController();
  final pdftextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom, // 🔥 IMPORTANT
      ),
      child: SingleChildScrollView(
        child: Card(
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          shadowColor: Colors.yellow,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
              children: [
                Text(
                  "UPLOAD WORK",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),

                SizedBox(height: 15),

                TextInputs(widget.orders),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget TextInputs(Ordersdetailsmodel order) {
    late final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: pdftextController,
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w900,
              overflow: TextOverflow.ellipsis,
              fontSize: 14,
            ),
            readOnly: true,
            onTap: () {
              pickSinglePdf();
            },
            decoration: InputDecoration(
              hintText: "UPLOAD YOUR WORK",
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.deepOrange, width: 3),
              ),
              prefixIcon: Padding(
                padding: EdgeInsetsGeometry.all(10),
                child: Image.asset(
                  "assets/images/files.png",
                  width: 24,
                  height: 24,
                ),
              ),

              suffixIcon: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        showInfoDialog(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Image.asset(
                          "assets/images/questionmark.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            textAlign: TextAlign.start,
            maxLines: 1,
          ),

          SizedBox(height: 5),

          if (isPickingPdf == true)
            Padding(
              padding: EdgeInsets.all(10),
              child: Center(child: CircularProgressIndicator()),
            ),

          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                if (isPdfView && selectedPdfFile != null)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Pdfpreviewscreen(pdfFile: selectedPdfFile!),
                        ),
                      );
                    },

                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Text(
                            "VIEW",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          Image.asset(
                            "assets/images/view.png",
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(width: 20),

                if (isPdfView)
                  InkWell(
                    onTap: () {
                      setState(() {
                        isPdfView = false;
                        selectedPdfFile = null;
                        fileName = null;

                        pdftextController.clear();
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Text(
                            "REMOVE ",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          Image.asset(
                            "assets/images/cross.png",
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (pdftextController.text == "File Uploaded Successfully")
            Row(
              children: [
                Image.asset("assets/images/pdf.png", width: 20, height: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName ?? "",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          SizedBox(height: 5),

          if (pdftextController.text == "File Uploaded Successfully")
            Row(
              children: [
                Image.asset("assets/images/page.png", width: 20, height: 20),
                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "${filePageCount ?? 0} Pages , ${formatFileSize(fileSize!)}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          SizedBox(height: 5),
          Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: double.infinity),
                  Text(
                    "Notes for User ?(Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 10),

                  // Description / Feedback Box
                  TextField(
                    controller: writerSuggestionController,
                    maxLines: 3, // Box ko bada dikhane ke liye
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText:
                          "Write any special instructions \n Example: Please review the work, check the Handwriting...",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.1),
                      // Halki transparent background
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xffF5F7FA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.deepOrange,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          termsAndConditionCheckBox(),

          const SizedBox(height: 5),

          Center(
            child: Column(
              children: [
                Text(
                  "🔒 Your files are safe & visible only to assigned user",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 5),

          uploadButton(order),
        ],
      ),
    );
  }

  Future<void> pickSinglePdf() async {
    try {
      setState(() {
        isPickingPdf = true;
      });
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String tempPath = result.files.single.path!;
        File tempFile = File(tempPath);

        final dir = await getApplicationDocumentsDirectory();
        final savedFile = await tempFile.copy(
          '${dir.path}/${result.files.single.name}',
        );

        final document = await PdfDocument.openFile(savedFile.path);
        int pages = document.pagesCount;
        await document.close();

        setState(() {
          fileName = result.files.single.name;
          fileSize = result.files.single.size;
          filePageCount = pages;
          selectedPdfFile = savedFile;
          isPdfView = true;
          pdftextController.text = "File Uploaded Successfully";
        });
      } else {
        print("User cancelled file picker");
      }
    } catch (e) {
      print("Error picking PDF: $e");
    } finally {
      if (mounted) {
        setState(() {
          isPickingPdf = false;
        });
      }
    }
  }

  void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "UPLOAD YOUR WORK",
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900),
          ),
          content: Text(
            "You can upload your work here \n Supported formats: Only Single PDF",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget termsAndConditionCheckBox() {
    return Padding(
      padding: EdgeInsets.all(10),

      child: Column(
        children: [
          CheckboxListTile(
            value: isChecked,
            onChanged: (value) {
              print("object:-$value");
              setState(() {
                isChecked = value!;
              });
            },
            title: Text(
              "I agree to Terms & Conditions",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget uploadButton(Ordersdetailsmodel order) {
    bool isFormValid = isChecked != false && selectedPdfFile != null;

    return InkWell(onTap: (){

      if(isFormValid)
        {

          uploadWriterWork(order);
        }
      else{
        ToastHelper.show("Please fill all required fields", context);
      }

    },
    child:Padding(padding: EdgeInsets.all(10),
    child:Container(
    decoration: BoxDecoration(
        color: isFormValid ? Colors.deepOrange : Color(0xffefac7c),
        borderRadius: BorderRadius.circular(10),

      ),
      child:Padding(padding: EdgeInsets.all(10),
        child:isUploading ? SizedBox(
          width: 24, height: 24,child: CircularProgressIndicator(),
        ) :
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "UPLOAD",
            style: TextStyle(
              color: Color(0xffFFFFFF),
              fontSize: 16.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8.0), // Spacing between text and image

          Image.asset(
            'assets/images/upload.png',
            width: 24.0,
            height: 24.0,
          ),
        ],
      ),
    )
    )
    )
    );
  }
  Future<void> uploadWriterWork(Ordersdetailsmodel order) async {
    try {
      if (mounted) {
        setState(() {
          isUploading = true;
        });
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ToastHelper.show("User not logged in", context);
        return;
      }

      if (selectedPdfFile == null) {
        ToastHelper.show("Please select PDF first", context);
        return;
      }

      final orderId = order.UserOrderId;

      if (orderId == null) {
        ToastHelper.show("Order id not found", context);
        return;
      }

      String? fileUrl = await uploadFile(orderId);

      if (fileUrl == null) {
        throw Exception("File upload failed");
      }


      Writerworkmodel wm = Writerworkmodel(
        userId: order.userId,
        UserOrderId: order.UserOrderId,
        fileName: fileName,
        fileSize: fileSize,
        filePageCount: filePageCount,
        writerId: order.writerId,
        orderCreatedAt: order.orderCreatedAt,
        orderCompletedAt: DateTime.now(),
        writerSuggestionText: writerSuggestionController.text,
        writerAssignmentStatus: "REVIEW",

        fileUrl: fileUrl,
      );

      final token = await user.getIdToken(true);

      final url = Uri.parse(
        "${apiConfig.baseUrl}/api/writer_side/orders/uploadWork",
      );

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(wm.toJson()),
      );

      print("Upload work response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        widget.orders.UserOrderId = data['orderId'];
        widget.orders.writerFirebaseUid = FirebaseAuth.instance.currentUser?.uid;


        widget.orders.writerFileUrl = fileUrl;

        ToastHelper.show("Work submitted successfully", context);

        Navigator.pop(context , "goToReviewTab");


      } else {
        ToastHelper.show("Upload failed", context);
        print("Upload work failed: ${response.body}");
      }
    } catch (e) {
      print("Writer work upload error: $e");
      ToastHelper.show("Something went wrong", context);
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }
  Future<String?> uploadFile(int orderId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    if (selectedPdfFile == null) {
      throw Exception("PDF file not selected");
    }

    final token = await user.getIdToken(true);

    final url = Uri.parse(
      "${apiConfig.baseUrl}/api/writer_side/orders/uploadWorkFile/$orderId",
    );

    var request = http.MultipartRequest("POST", url);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('file', selectedPdfFile!.path),
    );

    var response = await request.send();

    final res = await response.stream.bytesToString();
    print("Upload file response: $res");

    if (response.statusCode == 200) {
      final data = jsonDecode(res);
      return data['filePath'];
    } else {
      print("File upload failed: $res");
      return null;
    }
  }
}
