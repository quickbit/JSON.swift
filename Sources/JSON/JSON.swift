import Foundation

public indirect enum JSON: Equatable, Hashable {
    case string(String)
    case bool(Bool)
    case number(Double)
    case null
    case dictionary([String: JSON])
    case array([JSON])
}

extension JSON: Codable, CustomStringConvertible {
    enum JSONDecodingError: Error {
        case badType
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let decoded = try? container.decode([String: JSON].self) {
            self = .dictionary(decoded)
        } else if let decoded = try? container.decode([JSON].self) {
            self = .array(decoded)
        } else if let decoded = try? container.decode(String.self) {
            self = .string(decoded)
        } else if let decoded = try? container.decode(Double.self) {
            self = .number(decoded)
        } else if let decoded = try? container.decode(Bool.self) {
            self = .bool(decoded)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "invalid data")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .bool(let bool):
            try container.encode(bool)
        case .number(let number):
            try container.encode(number)
        case .null:
            try container.encodeNil()
        case .dictionary(let dict):
            try container.encode(dict)
        case .array(let array):
            try container.encode(array)
        }
    }

    public init(from value: Any?) throws {
        guard let value else {
            self = .null
            return
        }

        if let value = value as? String {
            self = .string(value)
        } else if let value = value as? Double {
            self = .number(value)
        } else if let value = value as? Int {
            self = .number(Double(value))
        } else if let value = value as? Bool {
            self = .bool(value)
        } else if let value = value as? [Any] {
            let jsonArray = try value.map { try JSON(from: $0) }
            self = .array(jsonArray)
        } else if let value = value as? [String: Any] {
            let jsonArray = try value.map { key, value in (key, try JSON(from: value)) }
            self = .dictionary(Dictionary(jsonArray, uniquingKeysWith: { $1 }))
        } else {
            throw JSONDecodingError.badType
        }
    }

    public var object: Any? {
        switch self {
        case .string(let string):
            return string
        case .bool(let bool):
            return bool
        case .number(let number):
            return number
        case .null:
            return nil
        case .dictionary(let dict):
            return Dictionary(dict.map { key, value in (key, value.object) }, uniquingKeysWith: { $1 })
        case .array(let array):
            return array.map { $0.object }
        }
    }

    public var description: String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? jsonEncoder.encode(self) else {
            return "invalid data"
        }
        return String(data: data, encoding: .utf8) ?? "encoding error"
    }
}

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral: StringLiteralType) {
        self = JSON.string(stringLiteral)
    }
}

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = JSON.null
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral: FloatLiteralType) {
        self = .number(Double(floatLiteral))
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral: IntegerLiteralType) {
        self = .number(Double(integerLiteral))
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral: BooleanLiteralType) {
        self = .bool(Bool(booleanLiteral))
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = JSON

    public init(arrayLiteral: JSON...) {
         self = .array(arrayLiteral)
     }
 }

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral: (String, JSON)...) {
        self = .dictionary(Dictionary(dictionaryLiteral, uniquingKeysWith: { $1 }))
    }
}
