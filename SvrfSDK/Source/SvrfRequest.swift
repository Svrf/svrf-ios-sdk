//
//  SvrfRequest.swift
//  SvrfSDK
//
//  Created by Jesse Boyes on 6/19/19.
//  Copyright © 2019 Svrf. All rights reserved.
//

import Foundation
import Alamofire

public enum SvrfRequestState {
    case initialized
    case queued
    case canceled
    case active(DataRequest?)
    case completed
}

public class SvrfRequest: NSObject {
    public var state: SvrfRequestState {
        willSet(newState) {
            if case .canceled = newState, case .active(let dataRequest?) = state {
                dataRequest.cancel()
            }
        }
    }

    override public init() {
        state = .initialized
    }

    public func cancel() {
        self.state = .canceled
    }
}
