import 'dart:io';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
// import 'package:pdf_viewer_v2/pdf_viewer_v2.dart';

class ObdViewer extends StatefulWidget {
  const ObdViewer({super.key, required this.title, this.file, this.url});

  final String title;
  final File? file;
  final String? url;
  @override
  State<ObdViewer> createState() => _ObdViewerState();
}

class _ObdViewerState extends State<ObdViewer> {
  // bool _isLoading = true;
  // late PDFDocument document;

  @override
  void initState() {
    super.initState();
    // loadDocument();
  }

  // loadDocument() async {
  //   //print(widget.file!);
  //   if(widget.file != null){
  //     document = await PDFDocument.fromFile(widget.file!);
  //     setState(() => _isLoading = false);
  //   }else if(widget.url != null){
  //     document = await PDFDocument.fromURL(
  //       widget.url!,
  //       cacheManager: CacheManager(
  //         Config(
  //           "customCacheKey",
  //           stalePeriod: const Duration(days: 2),
  //           maxNrOfCacheObjects: 10,
  //         ),
  //       ),
  //     );
  //     setState(() => _isLoading = false);
  //   }else{
  //     Get.back();
  //   }

  //   setState(() => _isLoading = false);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: //_isLoading
             const Center(child: CircularProgressIndicator(color: FColors.primaryColor,))
        //     : PDFViewer(
        //   document: document,
        //   lazyLoad: false,
        //   zoomSteps: 1,
        //   numberPickerConfirmWidget: const Text(
        //     "Confirm",
        //   ),
        // ),
      ),
    );
  }
}
