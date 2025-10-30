// lib/models/neo_event.dart

// Cetakan untuk data Near Earth Object (Asteroid Mendekat)
class NeoEvent {
  final String name; // Nama asteroid (cth: (2024 XD4))
  final DateTime closeApproachTimeUtc; // Waktu terdekat dengan bumi (UTC)
  final double missDistanceKm; // Jarak terdekat (km) - Opsional
  final double relativeVelocityKps; // Kecepatan relatif (km/s) - Opsional
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
