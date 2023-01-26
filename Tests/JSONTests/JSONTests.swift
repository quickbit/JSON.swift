import Foundation
import JSON
import XCTest

class JSONTests: XCTestCase {

    func testDecodeString() {
        let data = #""string""#.data(using: .utf8)!

        let decoder = JSONDecoder()
        XCTAssertEqual(try? decoder.decode(JSON.self, from: data), JSON.string("string"))
    }

    func testDecodeNull() {
        let data = #"null"#.data(using: .utf8)!

        let decoder = JSONDecoder()
        XCTAssertEqual(try? decoder.decode(JSON.self, from: data), JSON.null)

    }

    func testDecodeNumber() {
        let data = #"5"#.data(using: .utf8)!

        let decoder = JSONDecoder()
        XCTAssertEqual(try? decoder.decode(JSON.self, from: data), JSON.number(5))
    }

    func testDecodeBool() {
        let data = #"false"#.data(using: .utf8)!

        let decoder = JSONDecoder()
        XCTAssertEqual(try? decoder.decode(JSON.self, from: data), JSON.bool(false))
    }

    func testDecodeDictionary() {
        let data = #"{"test": 5 }"#.data(using: .utf8)!

        let decoder = JSONDecoder()
        XCTAssertEqual(try? decoder.decode(JSON.self, from: data), JSON.dictionary(["test": .number(5)]))
    }

    func testDecodeArray() {
        let data = #"["test", 5]"#.data(using: .utf8)!

        let decoder = JSONDecoder()
        XCTAssertEqual(try? decoder.decode(JSON.self, from: data), JSON.array([.string("test"), .number(5)]))
    }

    func testDecodeFromObject() {
        let data: [Any] = ["test", 5]

        XCTAssertEqual(try? JSON(from: data), ["test", 5])
    }

    func testDecodeFromObjectDictionary() {
        let data: Any = ["test": 5]

        XCTAssertEqual(try? JSON(from: data), ["test": 5])
    }
}
