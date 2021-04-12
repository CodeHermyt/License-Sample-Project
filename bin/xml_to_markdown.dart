import 'dart:io';
import 'package:xml/xml.dart';

import 'package:meta/meta.dart';

class XMLToMarkdownConverter {
  final String licenseId;

  XMLToMarkdownConverter({@required this.licenseId});

  String convertToMarkdown() {
    var finalDoc = StringBuffer();
    final licenseFile = _fetchLicenseFile(licenseId);
    final documentNode = _extractTextNodeFromFile(licenseFile);
    _extractAndFormatTexts(finalDoc, documentNode);
    return finalDoc.toString();
  }

  // Function Description:
  //       parameter - <String> licenseId
  //       - fetches file with name licenseId.xml
  //       returns a File
  File _fetchLicenseFile(String licenseId) {
    final _documentFile = File('../src/$licenseId.xml');
    return _documentFile;
  }

  // Function Description:
  //       parameter - <File> documentFile
  //       - parses File into XmlNode
  //       since content of License is enclosed in <text> so I am using that much only
  //       returns XmlNode
  XmlNode _extractTextNodeFromFile(File documentFile) {
    final _document = XmlDocument.parse(documentFile.readAsStringSync())
        .getElement('SPDXLicenseCollection')
        .getElement('license')
        .getElement('text');
    return _document;
  }

  // Function description:
  //        parameters - <StringBuffer> finalDoc, <XmlNode> node
  //        - extracts TEXT from each node and formats the TEXT according to
  //        the tag it was enclosed in.
  //
  void _extractAndFormatTexts(StringBuffer finalDoc, XmlNode node) {
    // if node is of type TEXT =>
    //      1. trimming
    //      2. replacing inline spaces with a new line character to match SPDX formatting
    if (node.nodeType == XmlNodeType.TEXT) {
      finalDoc.write(
        node.text.trim().replaceAll(RegExp('\\n[ ]{2,}'), '\n'),
      );
      return;
    }
    // else if node is in <p> tag =>
    //      1. extracting text from the tag (using node.text)
    //      2. replacing inline spaces with a new line character to match SPDX formatting
    //
    else if (node.toString().startsWith('<p')) {
      final localText =
          node.text.replaceAll(RegExp('\\n[ ]{2,}'), '\n').toString().trim();
      finalDoc.write('$localText\n\n');
      return;
    }
    // if node is <bullet> =>
    //      1. extracting text from the tag (using node.text)
    //      2. replacing inline spaces with a new line character to match SPDX formatting
    //      3. added result to the StringBuffer finalDoc with "\n  " to Match SPDX formatting
    else if (node.toString().startsWith('<bullet')) {
      final localText =
          node.text.replaceAll(RegExp('\\n[ ]{2,}'), '\n').toString().trim();
      finalDoc.write('\n  $localText  ');
      return;
    }
    // if node is <alt> =>
    //      1. extracting text from the tag (using node.text)
    //      2. replacing inline spaces with a new line character to match SPDX formatting
    //      3. added result to the StringBuffer finalDoc with "\n  " to Match SPDX formatting
    else if (node.toString().startsWith('<alt')) {
      final localText =
          node.text.replaceAll(RegExp('\\n[ ]{2,}'), '\n').toString().trim(); //
      finalDoc.write(' $localText ');
    }
    // if all the above condition is not met => the current node consists more tags as a child,
    //  in this case I iterated through each child of the concerned node ad recursively called
    //  convertToMarkDown function to extract texts from all child text and format those texts.
    else {
      for (var newNode in node.nodes) {
        _extractAndFormatTexts(finalDoc, newNode);
      }
    }
  }
}
