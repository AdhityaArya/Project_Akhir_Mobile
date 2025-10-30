class NeoEvent {
  final String name;
  final DateTime closeApproachTimeUtc;
  final double missDistanceKm;
  final double relativeVelocityKps;
  final double estimatedDiameterMinMeters;
  final double estimatedDiameterMaxMeters;
  final bool isPotentiallyHazardous;

  NeoEvent({
    required this.name,
    required this.closeApproachTimeUtc,
    this.missDistanceKm = 0.0,
    this.relativeVelocityKps = 0.0,
    this.estimatedDiameterMinMeters = 0.0,
    this.estimatedDiameterMaxMeters = 0.0,
    this.isPotentiallyHazardous = false,
  });
}
