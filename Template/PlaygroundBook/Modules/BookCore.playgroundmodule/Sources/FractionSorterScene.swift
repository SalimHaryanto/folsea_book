//
//  FractionSorterScene.swift
//  
//
//  Created by Haryanto on 20/11/25.
//


import UIKit
import SpriteKit
import PlaygroundSupport

public final class FractionSorterScene: SKScene {
    
    // MARK: - Nodes (max 3 objects)
    private var leftCircle: FractionCircle!
    private var rightCircle: FractionCircle!
    private var balanceScale: SKShapeNode!
    
    // MARK: - State
    private var leftPlaced = false
    private var rightPlaced = false
    private var currentRound = 0
    
    private let fractionPairs: [(Fraction, Fraction)] = [
        (Fraction(1, 2), Fraction(1, 4)),
        (Fraction(1, 3), Fraction(1, 4)),
        (Fraction(1, 2), Fraction(1, 3))
    ]
    
    // MARK: - Setup
    public override func didMove(to view: SKView) {
        backgroundColor = .white
        setupBalance()
        loadRound(currentRound)
        setupInstructions()
    }
    
    private func setupBalance() {
        let balanceWidth = size.width * 0.6
        let balanceY = size.height * 0.3
        
        // Central pivot
        let pivot = SKShapeNode(circleOfRadius: 15)
        pivot.fillColor = .darkGray
        pivot.position = CGPoint(x: size.width / 2, y: balanceY)
        addChild(pivot)
        
        // Balance beam
        let beam = SKShapeNode(rectOf: CGSize(width: balanceWidth, height: 8))
        beam.fillColor = .darkGray
        beam.position = CGPoint(x: size.width / 2, y: balanceY)
        beam.name = "beam"
        addChild(beam)
        
        balanceScale = beam
    }
    
    private func setupInstructions() {
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 32
        label.fontColor = .black
        label.text = "Which fraction is BIGGER?"
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        addChild(label)
    }
    
    private func loadRound(_ round: Int) {
        guard round < fractionPairs.count else { return }
        
        let (frac1, frac2) = fractionPairs[round]
        
        leftCircle = FractionCircle(fraction: frac1, radius: 80)
        leftCircle.position = CGPoint(x: size.width * 0.3, y: size.height * 0.65)
        leftCircle.name = "leftCircle"
        addChild(leftCircle)
        
        rightCircle = FractionCircle(fraction: frac2, radius: 80)
        rightCircle.position = CGPoint(x: size.width * 0.7, y: size.height * 0.65)
        rightCircle.name = "rightCircle"
        addChild(rightCircle)
        
        leftPlaced = false
        rightPlaced = false
    }
    
    // MARK: - Touch Handling
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        if let circle = touchedNodes.first(where: { $0 is FractionCircle }) as? FractionCircle {
            circle.userData = ["dragging": true]
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let circle = leftCircle, circle.userData?["dragging"] as? Bool == true {
            circle.position = location
        } else if let circle = rightCircle, circle.userData?["dragging"] as? Bool == true {
            circle.position = location
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let circle = leftCircle, circle.userData?["dragging"] as? Bool == true {
            circle.userData?["dragging"] = false
            checkPlacement(circle)
        } else if let circle = rightCircle, circle.userData?["dragging"] as? Bool == true {
            circle.userData?["dragging"] = false
            checkPlacement(circle)
        }
    }
    
    private func checkPlacement(_ circle: FractionCircle) {
        let balanceY = size.height * 0.3
        
        if abs(circle.position.y - balanceY) < 100 {
            if circle.position.x < size.width / 2 {
                circle.position = CGPoint(x: size.width * 0.35, y: balanceY)
                leftPlaced = true
            } else {
                circle.position = CGPoint(x: size.width * 0.65, y: balanceY)
                rightPlaced = true
            }
            
            circle.run(SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
        }
        
        if leftPlaced && rightPlaced {
            compareAndTilt()
        }
    }
    
    private func compareAndTilt() {
        let leftFrac = leftCircle.fraction
        let rightFrac = rightCircle.fraction
        
        let leftValue = Double(leftFrac.numerator) / Double(leftFrac.denominator)
        let rightValue = Double(rightFrac.numerator) / Double(rightFrac.denominator)
        
        var tiltAngle: CGFloat = 0
        var winner: FractionCircle?
        
        if leftValue > rightValue {
            tiltAngle = -0.15
            winner = leftCircle
        } else if rightValue > leftValue {
            tiltAngle = 0.15
            winner = rightCircle
        }
        
        balanceScale.run(SKAction.rotate(toAngle: tiltAngle, duration: 0.5))
        
        if let winner = winner {
            winner.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.colorize(with: .systemYellow, colorBlendFactor: 0.5, duration: 0.3)
            ]))
            
            showResult(winner: winner.fraction)
        }
    }
    
    private func showResult(winner: Fraction) {
        let resultLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        resultLabel.fontSize = 40
        resultLabel.fontColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
        resultLabel.text = "\(winner.numerator)/\(winner.denominator) is BIGGER!"
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        resultLabel.alpha = 0
        addChild(resultLabel)
        
        resultLabel.run(SKAction.fadeIn(withDuration: 0.5))
    }
}

// MARK: - Helper Types
private struct Fraction {
    let numerator: Int
    let denominator: Int
    
    init(_ numerator: Int, _ denominator: Int) {
        self.numerator = numerator
        self.denominator = denominator
    }
}

private class FractionCircle: SKNode {
    let fraction: Fraction
    private let circleNode: SKShapeNode
    private let shadedNode: SKShapeNode
    
    init(fraction: Fraction, radius: CGFloat) {
        self.fraction = fraction
        
        circleNode = SKShapeNode(circleOfRadius: radius)
        circleNode.fillColor = .white
        circleNode.strokeColor = .darkGray
        circleNode.lineWidth = 3
        
        let angle = CGFloat(fraction.numerator) / CGFloat(fraction.denominator) * 2 * .pi
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addArc(withCenter: .zero, radius: radius, startAngle: -.pi / 2, endAngle: -.pi / 2 + angle, clockwise: true)
        path.close()
        
        shadedNode = SKShapeNode(path: path.cgPath)
        shadedNode.fillColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.7)
        shadedNode.strokeColor = .clear
        
        super.init()
        
        addChild(circleNode)
        addChild(shadedNode)
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 36
        label.fontColor = .black
        label.text = "\(fraction.numerator)/\(fraction.denominator)"
        label.position = CGPoint(x: 0, y: radius + 20)
        addChild(label)
        
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Factory
public func makeFractionSorterLiveView() -> PlaygroundLiveViewable {
    let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
    sceneView.backgroundColor = .white
    
    let scene = FractionSorterScene(size: sceneView.bounds.size)
    scene.scaleMode = .aspectFit
    sceneView.presentScene(scene)
    
    return sceneView
}