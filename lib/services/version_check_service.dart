enum VersionStatus { upToDate, optionalUpdate, forcedUpdate }

class VersionCheckService {
  static VersionStatus checkVersion(String localVersion, String remoteVersion) {
    try {
      final localParts = localVersion.split('.').map(int.parse).toList();
      final remoteParts = remoteVersion.split('.').map(int.parse).toList();

      // Pad with zeros if lengths differ (though usually they should be x.y.z)
      while (localParts.length < 3) localParts.add(0);
      while (remoteParts.length < 3) remoteParts.add(0);

      final localMajor = localParts[0];
      final localMinor = localParts[1];
      // final localPatch = localParts[2];

      final remoteMajor = remoteParts[0];
      final remoteMinor = remoteParts[1];
      // final remotePatch = remoteParts[2];

      if (remoteMajor > localMajor) {
        return VersionStatus.forcedUpdate;
      } else if (remoteMajor == localMajor) {
        if (remoteMinor > localMinor) {
          return VersionStatus.optionalUpdate;
        }
      }

      return VersionStatus.upToDate;
    } catch (e) {
      // If parsing fails, fall back to no update to avoid blocking user due to error
      return VersionStatus.upToDate;
    }
  }
}
