//
//  Copyable.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 5/8/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

protocol Copyable {
    init(original: Self)
}

extension Copyable {
    func copy() -> Self {
        return Self.init(original: self)
    }
}