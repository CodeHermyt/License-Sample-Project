import 'dart:io';
import 'xml_to_markdown.dart';

void main(List<String> arguments) {
  print('-------------------------');
  print('Enter the License ID : ');
  final id = stdin.readLineSync();
  final xmlConverter = XMLToMarkdownConverter(licenseId: id);
  final convertedMarkdown = xmlConverter.convertToMarkdown();
  print('\n******The selected license file******\n\n');
  print(convertedMarkdown);
}
