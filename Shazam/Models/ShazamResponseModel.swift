
// Shazam

struct Images: Codable {
    let background: String

    enum CodingKeys: String, CodingKey {
        case background = "coverart"
    }
}

struct Shared: Codable {
    let subject: String
}

struct Track: Codable {
    let title: String?
    let subtitle: String?
    let images: Images?
    let share: Shared

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case images = "images"
        case share = "share"
    }
}

struct Hits: Codable {
    let track: Track
}

struct Tracks: Codable {
    var hits: Array<Hits>

    enum CodingKeys: String, CodingKey {
        case hits = "hits"
    }
}

struct ShazamResponse: Codable {
    var tracks: Tracks?

    enum CodingKeys: String, CodingKey {
        case tracks = "tracks"
    }
}
