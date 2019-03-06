//
//  SvrfOptional+String.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 06/03/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

import Foundation

private let numbers: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

extension Optional where Wrapped == String {

    var isNumeric: Bool {

        guard let string = self, string.count > 0 else {
            return false
        }

        return Set(string).isSubset(of: numbers)
    }
}

extension String {

    var isNumeric: Bool {

        guard count > 0 else {
            return false
        }

        return Set(self).isSubset(of: numbers)
    }
}
