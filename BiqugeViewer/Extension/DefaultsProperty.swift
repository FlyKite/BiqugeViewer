//
//  DefaultsProperty.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/21.
//

import Foundation

protocol DefaultsSupportedType { }

protocol DefaultsCustomType: DefaultsSupportedType {
    func getStorableValue() -> DefaultsSupportedType
    init?(storableValue: Any?)
}

@propertyWrapper struct DefaultsProperty<ValueType: DefaultsSupportedType> {
    var key: String { keyType.key }
    let defaultValue: ValueType
    
    private enum KeyType {
        case staticKey(key: String)
        case dynamicKey(provider: () -> String)
        
        var key: String {
            switch self {
            case let .staticKey(key): return key
            case let .dynamicKey(provider): return provider()
            }
        }
    }
    
    private let keyType: KeyType
    
    init(key: String, defaultValue: ValueType) {
        self.keyType = .staticKey(key: key)
        self.defaultValue = defaultValue
    }
    
    init(keyProvider: @escaping () -> String, defaultValue: ValueType) {
        self.keyType = .dynamicKey(provider: keyProvider)
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: ValueType {
        get {
            let value = UserDefaults.standard.value(forKey: key)
            if let storableType = ValueType.self as? DefaultsCustomType.Type {
                let result = storableType.init(storableValue: value)
                return (result as? ValueType) ?? defaultValue
            } else {
                return value as? ValueType ?? defaultValue
            }
        }
        set {
            if let value = newValue as? AnyOptional, value.isNil {
                UserDefaults.standard.removeObject(forKey: key)
            } else if let value = newValue as? DefaultsCustomType {
                UserDefaults.standard.set(value.getStorableValue(), forKey: key)
            } else {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool {
        return self == nil
    }
}

extension Bool: DefaultsSupportedType { }

extension Int: DefaultsSupportedType { }

extension Int8: DefaultsSupportedType { }

extension Int16: DefaultsSupportedType { }

extension Int32: DefaultsSupportedType { }

extension Int64: DefaultsSupportedType { }

extension UInt: DefaultsSupportedType { }

extension UInt8: DefaultsSupportedType { }

extension UInt16: DefaultsSupportedType { }

extension UInt32: DefaultsSupportedType { }

extension UInt64: DefaultsSupportedType { }

extension Float: DefaultsSupportedType { }

extension Double: DefaultsSupportedType { }

extension URL: DefaultsSupportedType { }

extension String: DefaultsSupportedType { }

extension Data: DefaultsSupportedType { }

extension Date: DefaultsSupportedType { }

extension Array: DefaultsSupportedType where Element: DefaultsSupportedType { }

extension Dictionary: DefaultsSupportedType where Key: DefaultsSupportedType, Value: DefaultsSupportedType { }

extension Optional: DefaultsSupportedType where Wrapped: DefaultsSupportedType { }

extension Optional: DefaultsCustomType where Wrapped: DefaultsSupportedType {
    func getStorableValue() -> DefaultsSupportedType {
        switch self {
        case .none: return Optional<Wrapped>.none
        case let .some(wrappedValue):
            if let value = wrappedValue as? DefaultsCustomType {
                return value.getStorableValue()
            } else {
                return wrappedValue
            }
        }
    }
    
    init?(storableValue: Any?) {
        if let type = Wrapped.self as? DefaultsCustomType.Type {
            self = type.init(storableValue: storableValue) as? Wrapped
        } else if let value = storableValue as? Wrapped {
            self = .some(value)
        } else {
            self = .none
        }
    }
}
