//
//  ShapeSplitterAPI.swift
//  
//
//  Created by Haryanto on 20/11/25.
//

import PlaygroundSupport
import BookCore

public func startShapeSplitterActivity() {
    PlaygroundPage.current.needsIndefiniteExecution = true
    PlaygroundPage.current.liveView = makeShapeSplitterLiveView()
}
