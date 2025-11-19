//
//  FractionSorterAPI.swift
//  
//
//  Created by Haryanto on 20/11/25.
//

import PlaygroundSupport
import BookCore

public func startFractionSorterActivity() {
    PlaygroundPage.current.needsIndefiniteExecution = true
    PlaygroundPage.current.liveView = makeFractionSorterLiveView()
}
