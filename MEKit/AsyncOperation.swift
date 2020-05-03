//
//  AsyncOperation.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 24/04/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {

    override var isAsynchronous: Bool {
        return true
    }
    
    private var _isExecuting: Bool = false
    override private(set) var isExecuting: Bool {
        get {
            return _isExecuting
        }
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _isFinished: Bool = false
    override private(set) var isFinished: Bool {
        get {
            return _isFinished
        }
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override func start() {
        super.start()
        isFinished = false
        isExecuting = true
    }
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
    
}
