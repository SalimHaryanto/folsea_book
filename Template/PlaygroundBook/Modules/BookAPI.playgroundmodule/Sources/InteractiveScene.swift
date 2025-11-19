//
//  InteractiveScene.swift
//  
//
//  Created by Haryanto on 19/11/25.
//


import UIKit
import PlaygroundSupport
import BookCore

public final class InteractiveScene {
    private var color: UIColor = .systemBlue
    private var size: CGFloat = 100
    
    public init() {}
    
    public func setColor(_ color: UIColor) {
        self.color = color
    }
    
    public func setSize(_ size: CGFloat) {
        self.size = size
    }
    
    func makeLiveView() -> PlaygroundLiveViewable {
        makeInteractiveSceneLiveView(color: color, size: size)
    }
}

public func show(_ scene: InteractiveScene) {
    PlaygroundPage.current.needsIndefiniteExecution = true
    PlaygroundPage.current.liveView = scene.makeLiveView()
}
