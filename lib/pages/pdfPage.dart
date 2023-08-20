// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWid;
import 'package:printing/printing.dart';

class PdfPage extends StatefulWidget {
  const PdfPage({
    Key? key,
  }) : super(key: key);

  @override
  _PdfPage createState() => _PdfPage();
}

class _PdfPage extends State<PdfPage> {
  late User? _currentUser;
  late Map<String, dynamic> _userData = {};
  String profilePictuyreUrl='https://i.stack.imgur.com/l60Hf.png';
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    setState(() {
      _currentUser = user;
    });

    if (_currentUser != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
      await firestore.collection('UsersInformation').doc(_currentUser!.email).get();
      setState(() {
        _userData = snapshot.data() as Map<String, dynamic>;
        profilePictuyreUrl=_userData["profilePicture"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.indigo[400], // Adjust the background color
        elevation: 1, // Add a subtle elevation for depth
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
      body: PdfPreview(
        build: (format) => _createPdf(
          format,
        ),
      ),
    );
  }

  Future<Uint8List> _createPdf(
      PdfPageFormat format,
      ) async {
    final pdf = pdfWid.Document(
      version: PdfVersion.pdf_1_4,
      compress: true,
    );
    pdf.addPage(
      pdfWid.Page(
        pageFormat: PdfPageFormat((80 * (72.0 / 25.4)), 600,
            marginAll: 5 * (72.0 / 25.4)),
        //pageFormat: format,
        build: (context) {
          return pdfWid.SizedBox(
            width: double.infinity,
            child: pdfWid.FittedBox(
                child: pdfWid.Column(
                    mainAxisAlignment: pdfWid.MainAxisAlignment.start,
                    children: [
                      pdfWid.Text("Information",
                          style: pdfWid.TextStyle(
                              fontSize: 35, fontWeight: pdfWid.FontWeight.bold)),
                      pdfWid.Container(
                        width: 250,
                        height: 1.5,
                        margin: pdfWid.EdgeInsets.symmetric(vertical: 5),
                        color: PdfColors.black,
                      ),
                      pdfWid.Container(
                        width: 300,
                        child: pdfWid.Text('${_userData["userName"]}'.toUpperCase(),
                            style: pdfWid.TextStyle(
                              fontSize: 35,
                              fontWeight: pdfWid.FontWeight.bold,
                            ),
                            textAlign: pdfWid.TextAlign.center,
                            maxLines: 5),
                      ),
                      pdfWid.Container(
                        width: 250,
                        height: 1.5,
                        margin: pdfWid.EdgeInsets.symmetric(vertical: 10),
                        color: PdfColors.black,
                      ),
                      pdfWid.Text("User Name:${_userData["userName"]}",
                          style: pdfWid.TextStyle(
                              fontSize: 25, fontWeight: pdfWid.FontWeight.bold)),
                      pdfWid.Text("Email:${_userData["email"]}",
                          style: pdfWid.TextStyle(
                              fontSize: 25, fontWeight: pdfWid.FontWeight.bold)),
                      pdfWid.Text("Birthdate:${_userData["birthdate"]}",
                          style: pdfWid.TextStyle(
                              fontSize: 25, fontWeight: pdfWid.FontWeight.bold)),

                    ])),
          );
        },
      ),
    );
    return pdf.save();
  }
}