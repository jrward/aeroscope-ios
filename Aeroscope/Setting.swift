//
//  Setting.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/4/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

protocol Mappable : ExpressibleByArrayLiteral {
    associatedtype key
    associatedtype value
    subscript(index: key ) -> value? {get}
    var settings : [key] {get}
    var mappings : [value] {get}
}


protocol Setting : CustomStringConvertible {
    associatedtype T
    var value : T {get set}
    mutating func increment()
    mutating func decrement()
}

protocol StrSetting : Setting {
    associatedtype T = String
    associatedtype setting
    var mapping : Mapping<String, setting> {get}
    func mappedSetting() -> setting
}


struct RegField {
    var value : Bool
    fileprivate var position : UInt8
    
    init(position: UInt8, value: Bool) {
        self.value = value
        assert(position < 8, "Invalid Position")
        self.position = position
    }
    
    var byte : UInt8 {
        get {
            return self.toInt() << position
        }
    }
    
    var mask : UInt8 {
        get {
            return ~(1 << position)
        }
    }
    
    func toInt() -> UInt8 {
        if self.value { return 1}
        else { return 0 }
    }
}


struct IntListSetting : Setting {
    typealias T = Int
    var value : Int  {
        willSet {
            assert(list.contains(newValue), "Invalid Setting")
        }
    }
    var list : Array<Int>
    
    init(value: Int, list: [Int]) {
        self.list = list
        self.value = value
    }
    
    mutating func increment() {
        
        
    }
    mutating func decrement() {
        
    }
    
    var description : String {
        get {
            return "\(value) in \(list)"
        }
    }
}

struct IntRangeSetting : Setting {
    typealias T = Int
    var value : Int {
        willSet {
            assert(range.contains(newValue), "Invalid Setting")
        }
    }
    var range : Range<Int>
    
    init(value: Int, range: Range<Int>) {
        self.range = range
        self.value = value
    }
    mutating func increment() {
        
        
    }
    mutating func decrement() {
        
    }
    
    var description : String {
        get {
            return "\(value) in \(range)"
        }
    }
}


struct StringSetting<Tmapping> : StrSetting, CustomStringConvertible {
    var value: String {
        willSet {
            assert(mapping.settings.contains(newValue), "Invalid Settings")
        }
    }
    var mapping : Mapping<String, Tmapping>
    
    var count : Int {
        get {
            return mapping.settings.count
        }
    }
    
    func mappedSetting() -> Tmapping {
        let index = mapping.settings.firstIndex(of: value)!
        return mapping.mappings[index]
    }
    
    func listSettings() -> [String] {
        return mapping.settings
    }
    
    func listMappings() -> [Tmapping] {
        return mapping.mappings
    }
    
    
    init(value: String, mapping: Mapping<String, Tmapping>) {
        self.mapping = mapping
        assert(mapping.settings.contains(value), "Invalid Setting")
        self.value = value
    }
    
    mutating func increment() {
        let currIndex = mapping.settings.firstIndex(of: value)!
        if currIndex < mapping.settings.endIndex - 1 {
            value = mapping.settings[currIndex + 1]
        }

    }
    
    mutating func decrement() {
        let currIndex = mapping.settings.firstIndex(of: value)!
        if currIndex > mapping.settings.startIndex {
            value = mapping.settings[currIndex - 1]
        }

    }
    
    
    
    subscript(index: Int) -> String {
        return mapping.settings[index]
    }
    
    var description : String {
        get {
            return "\(value) of \(mapping)"
        }
    }
}


/*class VertSetting : StringSetting<UInt8> {
    override init(value: String, mapping: Mapping<String, UInt8>) {
        super.init(value: value, mapping: mapping)
    }
}


class HorizSetting : StringSetting<horiz_mapping> {
    
    override init(value: String, mapping: Mapping<String,horiz_mapping>) {
        super.init(value: value, mapping: mapping)
    }
}*/

struct Mapping<key : Hashable, value> : Mappable, CustomStringConvertible, ExpressibleByArrayLiteral {
    
    fileprivate var keys = [key]()
    fileprivate var values = [value]()
    
    init() { }
    
    init(elements: [(key, value)]) {
        for element in elements {
            keys.append(element.0)
            values.append(element.1)
        }
    }
    
    
    init(arrayLiteral elements : (key,value)...) {
        self.init(elements: elements)
    }
    
    var settings : [key] {
        get {
            return keys
        }
    }
    
    var mappings : [value] {
        get {
            return values
        }
    }
    
    subscript(index: key) -> value? {
        if let foundIndex = keys.firstIndex(of: index) {
            return values[foundIndex]
        }
        else {
            return nil
        }
    }
    
    var description : String {
        get {
            var myString = String()
            for (index,key) in keys.enumerated() {
                myString += "\(key) : \(values[index])\n"
            }
            
            return myString
        }
    }
}
