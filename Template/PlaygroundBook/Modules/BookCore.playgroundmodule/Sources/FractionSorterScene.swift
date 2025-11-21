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
    
    // MARK: - Fixed State Tracking
    private var leftSideFraction: Fraction?
    private var rightSideFraction: Fraction?

    // MARK: - Updated checkPlacement
    private func checkPlacement(_ circle: FractionCircle) {
        let balanceY = size.height * 0.3
        
        if abs(circle.position.y - balanceY) < 100 {
            if circle.position.x < size.width / 2 {
                // Placed on LEFT side of balance
                circle.position = CGPoint(x: size.width * 0.35, y: balanceY)
                leftPlaced = true
                leftSideFraction = circle.fraction
            } else {
                // Placed on RIGHT side of balance
                circle.position = CGPoint(x: size.width * 0.65, y: balanceY)
                rightPlaced = true
                rightSideFraction = circle.fraction
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

    // MARK: - Fixed compareAndTilt
    private func compareAndTilt() {
        guard let leftFrac = leftSideFraction,
              let rightFrac = rightSideFraction else { return }
        
        let leftValue = Double(leftFrac.numerator) / Double(leftFrac.denominator)
        let rightValue = Double(rightFrac.numerator) / Double(rightFrac.denominator)
        
        var tiltAngle: CGFloat = 0
        var winnerFraction: Fraction?
        
        if leftValue > rightValue {
            // Left side is HEAVIER, so it tilts DOWN (negative angle)
            tiltAngle = -0.15
            winnerFraction = leftFrac
        } else if rightValue > leftValue {
            // Right side is HEAVIER, so it tilts DOWN (positive angle)
            tiltAngle = 0.15
            winnerFraction = rightFrac
        } else {
            // Equal fractions - balance stays level
            tiltAngle = 0
        }
        
        // Animate the balance tilt
        balanceScale.run(SKAction.rotate(toAngle: tiltAngle, duration: 0.5))
        
        // Highlight the heavier fraction (wherever it is)
        if let winner = winnerFraction {
            highlightWinnerCircle(winner)
            showResult(winner: winner)
        } else {
            showEqualResult()
        }
    }

    // MARK: - Helper to highlight the correct circle
    private func highlightWinnerCircle(_ winnerFraction: Fraction) {
        let winnerCircle = (leftCircle.fraction == winnerFraction) ? leftCircle : rightCircle
        
        winnerCircle?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.colorize(with: .systemYellow, colorBlendFactor: 0.5, duration: 0.3)
        ]))
    }

    // MARK: - Updated result display
    private func showResult(winner: Fraction) {
        let resultLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        resultLabel.fontSize = 40
        resultLabel.fontColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
        resultLabel.text = "\(winner.numerator)/\(winner.denominator) is HEAVIER!"
        resultLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        resultLabel.alpha = 0
        addChild(resultLabel)
        
        resultLabel.run(SKAction.fadeIn(withDuration: 0.5))
    }

    private func showEqualResult() {
        let resultLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        resultLabel.fontSize = 40
        resultLabel.fontColor = .systemBlue
        resultLabel.text = "Equal! The fractions are the same!"
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

// MARK: - Fraction Equality Helper
extension Fraction: Equatable {
    static func == (lhs: Fraction, rhs: Fraction) -> Bool {
        // Compare actual values to handle equivalent fractions
        let lValue = Double(lhs.numerator) / Double(lhs.denominator)
        let rValue = Double(rhs.numerator) / Double(rhs.denominator)
        return abs(lValue - rValue) < 0.0001
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
