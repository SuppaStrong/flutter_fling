import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Ensure the Flutter test binding is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_fling');

  setUp(() {
    // Set a mock handler using the defaultBinaryMessenger.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    // Remove the mock handler after each test.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Method channel returns the mocked value', () async {
    // Invoke any method on the channel.
    final result = await channel.invokeMethod('dummyMethod');
    // Verify that the result is what the mock handler returned.
    expect(result, equals('42'));
  });
}
