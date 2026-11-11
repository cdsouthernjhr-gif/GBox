enum PerformanceTier { entry, standard, advanced, high }

extension PerformanceTierLabel on PerformanceTier {
  String get label => switch (this) {
        PerformanceTier.entry => 'ENTRY GAMING',
        PerformanceTier.standard => 'STANDARD GAMING',
        PerformanceTier.advanced => 'ADVANCED GAMING',
        PerformanceTier.high => 'HIGH PERFORMANCE',
      };

  String get description => switch (this) {
        PerformanceTier.entry =>
          '8/16-bit systems and Game Boy family are the expected sweet spot.',
        PerformanceTier.standard =>
          'Adds PlayStation and lighter handheld/3D systems.',
        PerformanceTier.advanced =>
          'Adds PSP, N64, Nintendo DS and Dreamcast class systems.',
        PerformanceTier.high =>
          'Candidate for GameCube/Wii/PS2 class emulation (game dependent).',
      };
}

enum CompatibilityRating { excellent, good, limited, unsupported, notTested }

extension CompatibilityRatingLabel on CompatibilityRating {
  String get label => switch (this) {
        CompatibilityRating.excellent => 'Excellent',
        CompatibilityRating.good => 'Good',
        CompatibilityRating.limited => 'Limited',
        CompatibilityRating.unsupported => 'Unsupported',
        CompatibilityRating.notTested => 'Not Tested',
      };
}

/// What a rating is based on. Ratings from hardware data alone are always
/// labelled as estimates.
enum EvidenceLevel { hardwareEstimate, benchmark, communityReport, verified }

extension EvidenceLevelLabel on EvidenceLevel {
  String get label => switch (this) {
        EvidenceLevel.hardwareEstimate => 'Estimate from detected hardware',
        EvidenceLevel.benchmark => 'Local benchmark',
        EvidenceLevel.communityReport => 'Community report (unverified)',
        EvidenceLevel.verified => 'Verified by GAMEBOX testing',
      };
}
