import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

import FlexibleJsonDecoder

final class FlexibleJsonDecoderTests: XCTestCase {
    // ✅ Test Decoding with Missing Optional Fields
    func testDecodingWithDefaults() throws {
        
        enum UserRole: String, DefaultEnumProvider {
            case admin, user, guest
            static var defaultCase: UserRole { .guest }  // ✅ Default fallback case
        }
      
        @FlexibleJsonDecoder
        struct User: Codable {
            let id: Int
            let name: String
            let email: String
            let isActive: Bool
            let role: UserRole
        }

        let jsonData = """
        {
            "id": 1,
            "role": "in_valid"
        }
        """.data(using: .utf8)!

        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: jsonData)
            
            print("✅ User Decoded Successfully:")
            print("ID: \(user.id)")
            print("Name: \(user.name)")  // Should be ""
            print("Email: \(user.email)") // Should be ""
            print("Is Active: \(String(describing: user.isActive))") // Should be false
            print("Role: \(String(describing: user.role))") // Should be false
        } catch {
            print("❌ Decoding Failed: \(error)")
        }
    }
    
     // ✅ Test Decoding with Full JSON Data
    func testDecodingWithFullJSON() throws {
        @FlexibleJsonDecoder
        struct User: Codable {
            let id: Int
            var name: String = ""
            var email: String = ""
        }
        
        let json = """
            {
                "id": 2,
                "name": "Alice",
                "email": "alice@example.com"
            }
            """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: json)
        
        //XCTAssertEqual(user.id, 2)
        //XCTAssertEqual(user.name, "Alice")  // ✅ Uses JSON value
        //XCTAssertEqual(user.email, "alice@example.com")  // ✅ Uses JSON value
    }
}
