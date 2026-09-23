import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:likhwao/BottomNavigationBar/HomeScreens/HomeScreen3_deliveryInfo.dart';
import 'package:likhwao/Model/OrdersDetailsModel.dart';
import 'package:likhwao/Toast/ToastHelper.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';

import '../PdfPreviewScreen.dart';

class Homescreen2Info extends StatefulWidget {
  const Homescreen2Info({super.key});

  @override
  State<Homescreen2Info> createState() => _Homescreen2InfoState();
}

class _Homescreen2InfoState extends State<Homescreen2Info> {
  bool isPdfView = false;
  File? selectedPdfFile;

  String? fileName;
  int? fileSize;
  int? filePageCount;
  String? typeOfWork;
  String? languageSelectedChips;

  bool? isPickingPdf = false;
  List<String> language = [
    "English",
    "Hindi",
    "Hinglish",
    "Flexible(Writer decides) ",
  ];
  String? selectedInkColor;
  List<String> inkColorList = ["Blue", "Black", "Writer preference"];
  List<String> notebookTypeList = ["Ruled(Default)", "Plain"];
  String? selectedNotebook;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Submit Your Requirement",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0B164A),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
              (route) => false,
            );
          },
          icon: Icon(Icons.arrow_back_outlined, color: Colors.white, size: 20),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Card(
            elevation: 10,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
            color: Color(0xFF0B164A),
            child: Padding(
              padding: EdgeInsetsGeometry.all(8),

              child: Column(
                children: [
                  Text(
                    "Upload your assignment or notes to get started",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 10),
                  TextInputs(context),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ContinueButton(),
      ),
    );
  }

  Widget TextInputs(BuildContext context) {
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
            ),
            readOnly: true,
            onTap: () {
              pickSinglePdf();
            },
            decoration: InputDecoration(
              hintText: "UPLOAD YOUR WORK",
              hintStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
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

              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
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
                        child: Image.asset(
                          "assets/images/view.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),

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
                        child: Image.asset(
                          "assets/images/cross.png",
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),

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
            textAlign: TextAlign.start,
            maxLines: 1,
          ),

          if (isPickingPdf == true)
            Padding(
              padding: EdgeInsets.all(10),
              child: Center(child: CircularProgressIndicator()),
            ),

          SizedBox(height: 10),

          if (pdftextController.text == "File Uploaded Successfully")
            Row(
              children: [
                Image.asset("assets/images/pdf.png", width: 20, height: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName ?? "",
                    style: TextStyle(
                      color: Colors.white,
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
          SizedBox(height: 10),

          if (pdftextController.text == "File Uploaded Successfully")
            Row(
              children: [
                Image.asset("assets/images/page.png", width: 20, height: 20),
                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "${filePageCount ?? 0} Pages , ${formatFileSize(fileSize!)}",
                    style: TextStyle(
                      color: Colors.white,
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

          SizedBox(height: 14),

          DropdownButtonFormField<String>(
            value: typeOfWork,
            dropdownColor: const Color(0xFF0B164A),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
            // Selected text white
            decoration: InputDecoration(
              hint: Text(
                "TYPE OF WORK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.deepOrange,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Items ke andar Text ko style dena zaroori hai warna wo black dikhenge
            items:
                [
                      "Handwritten Notes",
                      "Assignment",
                      "Practical / Lab File",
                      "Exam Preparation Notes",
                      "Other",
                    ]
                    .map(
                      (subject) => DropdownMenuItem<String>(
                        value: subject,
                        child: Text(
                          subject,
                          style: const TextStyle(
                            color: Colors.white,
                          ), // <--- Items ka text white yahan se hoga
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                typeOfWork = value;
              });
            },
          ),

          SizedBox(height: 14),

          Text(
            "Select Langugage",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0, // Chips ke beech horizontal gap
            runSpacing: 4.0, // Chips ke beech vertical gap
            children: language.map((subject) {
              bool isSelected = languageSelectedChips == subject;
              return ChoiceChip(
                label: Text(subject),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    languageSelectedChips = selected ? subject : null;
                  });
                },
                selectedColor: Colors.deepOrange,
                // Select hone par color
                backgroundColor: const Color(0xFF1A237E),
                // Default color
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? Colors.deepOrange : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 10),

          Text(
            "Ink Color",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0, // Chips ke beech horizontal gap
            runSpacing: 4.0, // Chips ke beech vertical gap
            children: inkColorList.map((subject) {
              bool isSelected = selectedInkColor == subject;
              return ChoiceChip(
                label: Text(subject),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    selectedInkColor = selected ? subject : null;
                  });
                },
                selectedColor: Colors.deepOrange,
                // Select hone par color
                backgroundColor: const Color(0xFF1A237E),
                // Default color
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? Colors.deepOrange : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 10),

          Text(
            "NoteBook Type",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 10),

          Wrap(
            spacing: 8.0, // Chips ke beech horizontal gap
            runSpacing: 4.0, // Chips ke beech vertical gap
            children: notebookTypeList.map((subject) {
              bool isSelected = selectedNotebook == subject;
              return ChoiceChip(
                label: Text(subject),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    selectedNotebook = selected ? subject : null;
                  });
                },
                selectedColor: Colors.deepOrange,
                // Select hone par color
                backgroundColor: const Color(0xFF1A237E),
                // Default color
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? Colors.deepOrange : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 10),
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
                    "Notes for Writer ?(Optional)",
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
                    maxLines: 4, // Box ko bada dikhane ke liye
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText:
                          "Write any special instructions \n Example: Neat handwriting, medium size letters...",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 14,
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

          const SizedBox(height: 10),

          Center(
            child: Column(
              children: [
                Text(
                  "🔒 Your files are safe & visible only to assigned writer",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),


              ],
            ),
          ),
        ],
      ),
    );
  }

  // dialog box show karwane ke liye hai
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

  Widget ContinueButton() {
    bool isFormValid =
        selectedPdfFile != null &&
        typeOfWork != null &&
        selectedNotebook != null &&
        selectedInkColor != null &&
        languageSelectedChips != null;

    return InkWell(
      onTap: () {
        if (isFormValid) {
          Ordersdetailsmodel ordersdetailsmodel = Ordersdetailsmodel(
            selectedPdfFile: selectedPdfFile,
            userFileName: fileName,
            userFileSize: fileSize,
            userFilePageCount: filePageCount,
            typeOfWork: typeOfWork,
            languageSelectedChips: languageSelectedChips,
            selectedInkColor: selectedInkColor,
            selectedNotebook: selectedNotebook,
            writerSuggestionText: writerSuggestionController.text,
          );

          Navigator.push(context, MaterialPageRoute(builder: (context)=>
          Homescreen3Deliveryinfo(order:ordersdetailsmodel)));
        } else {
          ToastHelper.show("Please Fill all details", context);
          return;
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isFormValid ? Colors.deepOrange : Color(0xffefac7c),
          // Button background color
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Wrap content horizontally
          children: [
            const Text(

              "CONTINUE",
              style: TextStyle(
                color: Color(0xffFFFFFF),
                fontSize: 16.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8.0), // Spacing between text and image

            Image.asset(
              'assets/images/arrowright.png',
              width: 24.0,
              height: 24.0,
              color: Colors
                  .white,
            ),
          ],
        ),
      ),
    );
  }

  // NOW AB HUM APNE FILES SE PDF SELECT KARWAYENGE

  Future<void> pickSinglePdf() async {
    try {
      setState(() {
        isPickingPdf = true;
      });
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String tempPath = result.files.single.path!;
        File tempFile = File(tempPath);

        //permanent storage

        final dir = await getApplicationDocumentsDirectory();
        final savedFile = await tempFile.copy(
          '${dir.path}/${result.files.single.name}',
        );

        fileName = result.files.single.name;

        fileSize = result.files.single.size;

        final document = await PdfDocument.openFile(savedFile.path);
        int pages = document.pagesCount;
        await document.close();

        setState(() {
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
    }
    finally {
      if (mounted) {
        setState(() {
          isPickingPdf = false;
        });
      }
    }
  }
}
