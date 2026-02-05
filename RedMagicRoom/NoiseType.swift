import Foundation

enum NoiseType: String, CaseIterable, Identifiable, Codable {
    case white
    case brown
    case pink

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }
}
