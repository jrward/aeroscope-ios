//
//  Samples.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 3/9/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation

struct Sample {
    var value : Float
    var isValid : Bool
    
    init(_ value: Float, isValid: Bool) {
        self.value = value
        self.isValid = isValid
    }
}

struct Samples  {
    var data : [Sample] = []
    var raw : [Float] {
        get {
            return data.map{(el) in return el.value}
        }
        set {
            for (i,_) in data.enumerated() {
                data[i].value = newValue[i]
            }
        }
    }
    
    var count : Int {
        get {
            return data.count
        }
    }
    
    init() {
        data = []
    }
    
    init(samples: [Sample]) {
        self.data = samples
    }
    
    init(rawData: [Float]) {
        for el in rawData {
            self.data.append(Sample(el, isValid: true))
        }
    }
    
    init(interpData: [Float]) {
        for el in interpData {
            self.data.append(Sample(el, isValid: false))
        }
    }
    //
    //    mutating func insert(_ contentsOf: [Samples], at Index: Int) {
    //
    //    }
    //
    mutating func insert(interpData: [Float], at Index: Int) {
        var myIndex = Index
        for el in interpData {
            self.data.insert(Sample(el, isValid: false), at: myIndex)
            myIndex += 1
        }
    }
    
    mutating func insert(_ newElement: Float, at Index: Int) {
        self.data.insert(Sample(newElement, isValid: false), at: Index)
    }
    
    mutating func clipToBounds() {
        self.data = self.data.map{ (el) in Sample(max(min(el.value, 255.0), 0.0), isValid: el.isValid) }
    }
    
    mutating func addOffset(_ offset: Float) {
        self.data = self.data.map{ (el) in Sample(el.value + offset, isValid: el.isValid) }
    }
    
    mutating func append(_ newElement: Float) {
        self.data.append(Sample(newElement, isValid: false))
    }
    
    
    mutating func append(contentsOf: [Float]) {
        for el in contentsOf {
            self.data.append(Sample(el, isValid: false))
        }
    }
    
    mutating func append(sample: Sample) {
        self.data.append(sample)
    }
    
}
