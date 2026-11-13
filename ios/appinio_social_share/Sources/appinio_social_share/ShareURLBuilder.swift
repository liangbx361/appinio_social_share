import Foundation

enum ShareURLBuilder {
    static func httpURL(from value: String) -> URL? {
        guard let components = URLComponents(string: value),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = components.host, !host.isEmpty else { return nil }
        return components.url
    }

    static func makeURL(
        scheme: String,
        host: String,
        path: String = "",
        queryName: String,
        value: String
    ) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [URLQueryItem(name: queryName, value: value)]
        // Some receiving apps decode query values as form data, where a literal + means a space.
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.url
    }
}
