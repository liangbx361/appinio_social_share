import Foundation

@main
struct ShareURLCheck {
    static func main() {
        let messages = [
            "Watch this: https://example.com/drama?a=1&b=2#episode",
            "中文 العربية 😀\n50% off + bonus",
            "https://example.com/share?redirect=https%3A%2F%2Fexample.com%2Fplay%3Fa%3D1%26b%3D2",
        ]
        let targets = [
            ("whatsapp", "send", "", "text"),
            ("tg", "msg", "", "text"),
            ("instagram", "sharesheet", "", "text"),
            ("fb-messenger", "share", "/", "link"),
            ("twitter", "post", "", "message"),
        ]
        for value in ["https://example.com/a?x=1&y=2#part", "http://example.com"] {
            precondition(ShareURLBuilder.httpURL(from: value) != nil)
        }
        for value in ["", "Watch https://example.com", "ftp://example.com", "https:///", "joyreels://playlet/1"] {
            precondition(ShareURLBuilder.httpURL(from: value) == nil)
        }
        for target in targets {
            for message in messages {
                guard let url = ShareURLBuilder.makeURL(
                    scheme: target.0, host: target.1, path: target.2, queryName: target.3, value: message
                ), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                    fatalError("Expected a valid share URL")
                }
                precondition(components.scheme == target.0)
                precondition(components.host == target.1)
                precondition(components.path == target.2)
                precondition(components.fragment == nil)
                precondition(components.queryItems == [URLQueryItem(name: target.3, value: message)])
                precondition(!(components.percentEncodedQuery ?? "").contains("+"))
            }
        }
        print("Share URL encoding checks passed (15 cases).")
    }
}
