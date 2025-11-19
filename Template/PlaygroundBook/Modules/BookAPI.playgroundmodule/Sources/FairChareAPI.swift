//
//  FairChareAPI.swift
//  
//
//  Created by Haryanto on 19/11/25.
//

import PlaygroundSupport
import BookCore

public func startFairShareActivity() {
    PlaygroundPage.current.needsIndefiniteExecution = true
    PlaygroundPage.current.liveView = makeFairShareLiveView()
}
