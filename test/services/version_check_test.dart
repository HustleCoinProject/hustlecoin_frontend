import 'package:flutter_test/flutter_test.dart';
import 'package:hustlecoin/services/version_check_service.dart';

void main() {
  group('VersionCheckService', () {
    test('local 1.0.0, remote 1.0.0 should be upToDate', () {
      expect(
        VersionCheckService.checkVersion('1.0.0', '1.0.0'),
        VersionStatus.upToDate,
      );
    });

    test('local 1.0.0, remote 0.9.9 should be upToDate', () {
      // Remote is older, so no update needed
      expect(
        VersionCheckService.checkVersion('1.0.0', '0.9.9'),
        VersionStatus.upToDate,
      );
    });

    test(
      'local 1.0.0, remote 1.0.1 should be upToDate (Patch update handled as upToDate based on requirements)',
      () {
        // User requirements only specified Major (Forced) and Minor (Optional).
        // "if its last difit mismatch, its opay"
        expect(
          VersionCheckService.checkVersion('1.0.0', '1.0.1'),
          VersionStatus.upToDate,
        );
      },
    );

    test('local 1.0.0, remote 1.1.0 should be optionalUpdate', () {
      expect(
        VersionCheckService.checkVersion('1.0.0', '1.1.0'),
        VersionStatus.optionalUpdate,
      );
    });

    test('local 1.0.0, remote 1.2.5 should be optionalUpdate', () {
      expect(
        VersionCheckService.checkVersion('1.0.0', '1.2.5'),
        VersionStatus.optionalUpdate,
      );
    });

    test('local 1.0.0, remote 2.0.0 should be forcedUpdate', () {
      expect(
        VersionCheckService.checkVersion('1.0.0', '2.0.0'),
        VersionStatus.forcedUpdate,
      );
    });

    test('local 1.9.9, remote 2.0.0 should be forcedUpdate', () {
      expect(
        VersionCheckService.checkVersion('1.9.9', '2.0.0'),
        VersionStatus.forcedUpdate,
      );
    });

    test('local 1.0.0, remote 2.1.0 should be forcedUpdate', () {
      expect(
        VersionCheckService.checkVersion('1.0.0', '2.1.0'),
        VersionStatus.forcedUpdate,
      );
    });

    test('Invalid format should return upToDate', () {
      expect(
        VersionCheckService.checkVersion('invalid', '1.0.0'),
        VersionStatus.upToDate,
      );
      expect(
        VersionCheckService.checkVersion('1.0.0', 'invalid'),
        VersionStatus.upToDate,
      );
    });
  });
}
