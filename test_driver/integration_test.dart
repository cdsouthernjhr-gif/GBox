// Runs integration_test/device_test.dart through `flutter drive`, so the
// on-device tests can use a release build (R8 shrinking, like the APKs users
// install). See tool/ci_device_tests.sh.
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
