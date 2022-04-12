import 'package:json_parser/json_parser.dart' as P;

void main() {
  var awesome = P.Awesome();
  print('awesome: ${awesome.isAwesome}');
  final parser = P.parseInt('"not int"');
  print('int: ${parser}');
  print('parser value: ${parser.safe}');
}
