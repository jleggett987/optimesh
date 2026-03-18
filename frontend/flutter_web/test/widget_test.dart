import 'package:flutter_test/flutter_test.dart';
import 'package:optimesh_flutter_web/main.dart';

void main() {
  testWidgets('OptiMesh app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const OptiMeshApp());

    expect(find.text('OptiMesh'), findsOneWidget);
    expect(find.text('Run Sample Task'), findsOneWidget);
  });
}