//
//  Settings.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/3/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation


struct gSetting<key : Hashable, value> : CustomStringConvertible, ArrayLiteralConvertible {
    
    
    private var keys = Array<key>()
    private var values = Array<value>()
    
    var setting : key? {
        willSet {
            assert(keys.contains(newValue!), "Invalid Settings")
        }
    }
    
    init() { }
    
    init(elements: [(key, value)]) {
        for element in elements {
            keys.append(element.0)
            values.append(element.1)
        }
    }
    
    init(setting: key, elements: [(key, value)]) {
        self.init(elements: elements)
        self.setting = setting
    }
    
    init(arrayLiteral elements : (key,value)...) {
        self.init(elements: elements)
    }
    
    var settings : [key] {
        get {
            return keys
        }
    }
    
    var mapping : [value] {
        get {
            return values
        }
    }
    
    mutating func append(element : (key, value)) {
        keys.append(element.0)
        values.append(element.1)
    }
    
    mutating func popLast() -> (key, value)? {
        if let key = keys.popLast() {
            if let value = values.popLast() {
                return (key, value)
            }
        }
        
        return nil
    }
    
    subscript(index: key) -> value? {
        if let foundIndex = keys.indexOf(index) {
            return values[foundIndex]
        }
        else {
            return nil
        }
    }
    
    var description : String {
        get {
            var myString = String()
            for (index,key) in keys.enumerate() {
                myString += "\(key) : \(values[index])\n"
            }
            
            return myString
        }
    }
}



struct IntSetting : CustomStringConvertible {
    var value : Int {
        willSet {
            if (range != nil) {
                assert(range.contains(newValue),"Invalid Settings")
            }
                
            else {
                assert(list.contains(newValue),"Invalid Settings")
            }
        }
    }
    
    let range : Range<Int>!
    let list : [Int]!
    
    init(value: Int, range: Range<Int>) {
        self.range = range
        assert(range.contains(value), "Invalid Settings")
        self.value = value
        self.list = nil
    }
    
    init(value: Int, list: [Int]) {
        self.list = list
        assert(list.contains(value), "Invalid Settings")
        self.value = value
        self.range = nil
    }
    
    var description : String {
        get {
            if (range != nil) {
                return "\(value) (\(range.startIndex) to \(range.endIndex-1))"
            }
                
            else {
                return "\(value) in \(list)"
            }
        }
    }
}

struct StrSetting : CustomStringConvertible {
    
    var value : String {
        willSet {
            if (mapping != nil) {
                assert(mapping.keys.contains(newValue),"Invalid Settings")
            }
                
            else {
                assert(list.contains(newValue),"Invalid Settings")
            }
        }
    }
    
    let mapping : [String: UInt8]!
    let list : [String]!
    
    init(value: String, mapping: [String: UInt8]) {
        self.mapping = mapping
        assert(mapping.keys.contains(value), "Invalid Settings")
        self.value = value
        self.list = nil
    }
    
    init(value: String, list: [String]) {
        self.list = list
        assert(list.contains(value), "Invalid Settings")
        self.value = value
        self.mapping = nil
    }
    
    init (value: String, list: [String], mapping: [String: UInt8]) {
        self.list = list
        assert(list.contains(value), "Invalid Settings")
        self.value = value
        self.mapping = mapping
    }
    
    mutating func increment() {
        var myPos = self.list.indexOf(self.value)! + 1
        if myPos >= self.list.endIndex {
            myPos = self.list.endIndex - 1
        }
        self.value = self.list[myPos]
        
        
    }
    
    mutating func decrement() {
        var myPos = self.list.indexOf(self.value)! - 1
        if myPos < self.list.startIndex {
            myPos = self.list.startIndex
        }
        self.value = self.list[myPos]
    }
    
    var description : String {
        get {
            if (mapping != nil) {
                return "\(value) of \(mapping)"
            }
                
            else {
                return "\(value) of \(list)"
            }
        }
    }
    
}

struct RegField {
    private var position : UInt8
    var value : Bool
    func toInt() -> UInt8 {
        if self.value { return 1}
        else { return 0 }
    }
}
