# FlexibleJsonDecoder 🏆

🚀 A Swift Macro for Automatic JSON Decoding with Default Values

This Swift package provides an easy way to decode JSON into Swift structures without handling missing or invalid values manually.
Using `@FlexibleJsonDecoder`, your models automatically fall back to default values when keys are missing or invalid.

## 📌 Installation
🔹 Swift Package Manager (SPM)
Add this package to your Package.swift:
```
dependencies: [
    .package(url: "https://github.com/kosalpen11/FlexibleJsonDecoder", from: "1.0.0"),
],
targets: [
    .target(name: "YourApp", dependencies: ["FlexibleJsonDecoder"]),
]
```
## Usage
## 1️⃣ Decoding a Simple Struct
```
import FlexibleJsonDecoder

@FlexibleJsonDecoder
struct User {
    var id: Int
    var name: String
    var email: String
}
```
🔹 Example JSON (Missing Fields)
```
{
  "id": 1
}
```
✅ Decodes Without Errors:
```
let user = try JSONDecoder().decode(User.self, from: jsonData)
print(user.name)  // Output: ""
print(user.email) // Output: ""
```
## 2️⃣ Decoding Enums with Default Value
```
enum UserRole: String, DefaultEnumProvider {
    case admin, user, guest
    static var defaultCase: UserRole { .guest }  // ✅ Default fallback case
}

@FlexibleJsonDecoder
struct Account {
    var id: Int
    var role: UserRole
}
```
✅ Decodes Without Failing:
```
let account = try JSONDecoder().decode(Account.self, from: jsonData)
print(account.role) // Output: guest
```

## How It Works
The @FlexibleJsonDecoder macro automatically generates init(from decoder:) with default values:
```
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
    self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
    
    self.role = UserRole(rawValue: try container.decode(String.self, forKey: .role)) ?? .guest
}
```
