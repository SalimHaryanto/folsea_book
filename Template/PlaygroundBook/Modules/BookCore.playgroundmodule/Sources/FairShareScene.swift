//
//  FairShareScene.swift
//  
//
//  Created by Haryanto on 19/11/25.
//


import UIKit
import SpriteKit
import PlaygroundSupport

public final class FairShareScene: SKScene {
    
    // MARK: - Nodes (max 3 objects)
    private var pizzaCircle: SKShapeNode!
    private var verticalLine: SKShapeNode?
    private var horizontalLine: SKShapeNode?
    
    // MARK: - State
    private var divisionState: DivisionState = .whole
    private var fractionLabel: SKLabelNode!
    
    private enum DivisionState {
        case whole, halves, quarters
    }
    
    // MARK: - Setup
    public override func didMove(to view: SKView) {
        backgroundColor = .white
        setupPizza()
        setupLabel()
    }
    
    private func setupPizza() {
        let radius = size.width * 0.3
        pizzaCircle = SKShapeNode(circleOfRadius: radius)
        pizzaCircle.fillColor = UIColor(red: 1.0, green: 0.65, blue: 0.3, alpha: 1.0)
        pizzaCircle.strokeColor = .darkGray
        pizzaCircle.lineWidth = 3
        pizzaCircle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pizzaCircle.name = "pizza"
        addChild(pizzaCircle)
    }
    
    private func setupLabel() {
        fractionLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        fractionLabel.fontSize = 48
        fractionLabel.fontColor = .black
        fractionLabel.text = "1 whole"
        fractionLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        addChild(fractionLabel)
    }
    
    // MARK: - Touch Handling
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        if touchedNodes.contains(where: { $0.name == "pizza" }) {
            advanceDivision()
        }
    }
    
    private func advanceDivision() {
        switch divisionState {
        case .whole:
            createHalves()
            divisionState = .halves
        case .halves:
            createQuarters()
            divisionState = .quarters
        case .quarters:
            reset()
            divisionState = .whole
        }
    }
    
    private func createHalves() {
        let radius = pizzaCircle.frame.width / 2
        
        verticalLine = SKShapeNode(rectOf: CGSize(width: 4, height: radius * 2))
        verticalLine?.fillColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        verticalLine?.position = pizzaCircle.position
        verticalLine?.zPosition = pizzaCircle.zPosition + 1
        addChild(verticalLine!)
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        pizzaCircle.run(pulse)
        
        fractionLabel.text = "1/2 (one half)"
        
        // Highlight one half
        highlightSection(leftSide: true)
    }
    
    private func createQuarters() {
        let radius = pizzaCircle.frame.width / 2
        
        horizontalLine = SKShapeNode(rectOf: CGSize(width: radius * 2, height: 4))
        horizontalLine?.fillColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        horizontalLine?.position = pizzaCircle.position
        horizontalLine?.zPosition = pizzaCircle.zPosition + 1
        addChild(horizontalLine!)
        
        // Sequential pulse of quarters
        let wait1 = SKAction.wait(forDuration: 0.2)
        let wait2 = SKAction.wait(forDuration: 0.4)
        let wait3 = SKAction.wait(forDuration: 0.6)
        
        pizzaCircle.run(SKAction.sequence([
            wait1, SKAction.scale(to: 1.03, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ]))
        
        fractionLabel.text = "1/4 (one quarter)"
        highlightQuarter(index: 0)
    }
    
    private func reset() {
        verticalLine?.removeFromParent()
        horizontalLine?.removeFromParent()
        verticalLine = nil
        horizontalLine = nil
        
        pizzaCircle.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
        fractionLabel.text = "1 whole"
        divisionState = .whole
    }
    
    private func highlightSection(leftSide: Bool) {
        let fadeOut = SKAction.fadeAlpha(to: 0.6, duration: 0.3)
        pizzaCircle.run(fadeOut)
    }
    
    private func highlightQuarter(index: Int) {
        // Visual feedback for quarter highlighting
        let fadeOut = SKAction.fadeAlpha(to: 0.7, duration: 0.3)
        pizzaCircle.run(fadeOut)
    }
}

// MARK: - Factory
public func makeFairShareLiveView() -> PlaygroundLiveViewable {
    let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
    sceneView.backgroundColor = .white
    
    let scene = FairShareScene(size: sceneView.bounds.size)
    scene.scaleMode = .aspectFit
    sceneView.presentScene(scene)
    
    return sceneView
}
