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
    
    // MARK: - Nodes
    private var leftCircle: FractionCircle!
    private var rightCircle: FractionCircle!
    private var balanceScale: SKShapeNode!
    private var balanceBeam: SKShapeNode!
    private var resultLabel: SKLabelNode?
    
    // MARK: - State
    private var leftPlaced = false
    private var rightPlaced = false
    private var leftSideFraction: Fraction?
    private var rightSideFraction: Fraction?
    
    // MARK: - Student-Defined Fractions
    private let leftFraction: Fraction
    private let rightFraction: Fraction
    
    // MARK: - Constants
    private let circleRadius: CGFloat = 80
    private let balanceY: CGFloat
    
    // MARK: - Initialization
    public init(size: CGSize, leftFraction: Fraction, rightFraction: Fraction) {
        self.leftFraction = leftFraction
        self.rightFraction = rightFraction
        self.balanceY = size.height * 0.3
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    public override func didMove(to view: SKView) {
        backgroundColor = .white
        setupInstructions()
        setupBalance()
        setupFractionCircles()
        setupResetButton()
    }
    
    private func setupInstructions() {
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.fontSize = 36
        titleLabel.fontColor = .black
        titleLabel.text = "Which fraction is BIGGER?"
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.88)
        addChild(titleLabel)
        
        let instructionLabel = SKLabelNode(fontNamed: "Helvetica")
        instructionLabel.fontSize = 24
        instructionLabel.fontColor = .darkGray
        instructionLabel.text = "Drag each circle to the balance scale"
        instructionLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        addChild(instructionLabel)
        
        let hintLabel = SKLabelNode(fontNamed: "Helvetica")
        hintLabel.fontSize = 20
        hintLabel.fontColor = .gray
        hintLabel.text = "The heavier side goes down!"
        hintLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.77)
        addChild(hintLabel)
    }
    
    private func setupBalance() {
        let balanceWidth = size.width * 0.6
        
        // Central pivot (triangle shape)
        let pivotPath = UIBezierPath()
        pivotPath.move(to: CGPoint(x: -20, y: 0))
        pivotPath.addLine(to: CGPoint(x: 20, y: 0))
        pivotPath.addLine(to: CGPoint(x: 0, y: -20))
        pivotPath.close()
        
        let pivot = SKShapeNode(path: pivotPath.cgPath)
        pivot.fillColor = .darkGray
        pivot.strokeColor = .black
        pivot.lineWidth = 2
        pivot.position = CGPoint(x: size.width / 2, y: balanceY)
        addChild(pivot)
        
        // Balance beam
        balanceBeam = SKShapeNode(rectOf: CGSize(width: balanceWidth, height: 8), cornerRadius: 4)
        balanceBeam.fillColor = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
        balanceBeam.strokeColor = .black
        balanceBeam.lineWidth = 2
        balanceBeam.position = CGPoint(x: size.width / 2, y: balanceY)
        balanceBeam.name = "beam"
        addChild(balanceBeam)
        
        // Left scale plate
        let leftPlate = SKShapeNode(rectOf: CGSize(width: 120, height: 10), cornerRadius: 2)
        leftPlate.fillColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        leftPlate.strokeColor = .darkGray
        leftPlate.lineWidth = 2
        leftPlate.position = CGPoint(x: size.width * 0.35, y: balanceY)
        addChild(leftPlate)
        
        // Right scale plate
        let rightPlate = SKShapeNode(rectOf: CGSize(width: 120, height: 10), cornerRadius: 2)
        rightPlate.fillColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        rightPlate.strokeColor = .darkGray
        rightPlate.lineWidth = 2
        rightPlate.position = CGPoint(x: size.width * 0.65, y: balanceY)
        addChild(rightPlate)
        
        // Drop zone indicators
        createDropZone(at: CGPoint(x: size.width * 0.35, y: balanceY), label: "Left")
        createDropZone(at: CGPoint(x: size.width * 0.65, y: balanceY), label: "Right")
    }
    
    private func createDropZone(at position: CGPoint, label: String) {
        let zone = SKShapeNode(circleOfRadius: circleRadius + 15)
        zone.strokeColor = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 0.5)
        zone.lineWidth = 3
        zone.fillColor = .clear
        zone.position = position
        zone.alpha = 0.5
        
        // Dashed line effect
        let dash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.8, duration: 0.8),
            SKAction.fadeAlpha(to: 0.3, duration: 0.8)
        ])
        zone.run(SKAction.repeatForever(dash))
        
        addChild(zone)
    }
    
    private func setupFractionCircles() {
        // Left circle (student's first fraction)
        leftCircle = FractionCircle(fraction: leftFraction, radius: circleRadius)
        leftCircle.position = CGPoint(x: size.width * 0.25, y: size.height * 0.60)
        leftCircle.name = "leftCircle"
        addChild(leftCircle)
        
        // Right circle (student's second fraction)
        rightCircle = FractionCircle(fraction: rightFraction, radius: circleRadius)
        rightCircle.position = CGPoint(x: size.width * 0.75, y: size.height * 0.60)
        rightCircle.name = "rightCircle"
        addChild(rightCircle)
    }
    
    private func setupResetButton() {
        let button = SKShapeNode(rectOf: CGSize(width: 120, height: 45), cornerRadius: 10)
        button.fillColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        button.strokeColor = .darkGray
        button.lineWidth = 2
        button.position = CGPoint(x: size.width / 2, y: size.height * 0.08)
        button.name = "resetButton"
        addChild(button)
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 24
        label.fontColor = .white
        label.text = "Reset"
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }
    
    // MARK: - Touch Handling
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        // Check for reset button
        if touchedNodes.contains(where: { $0.name == "resetButton" }) {
            resetCircles()
            return
        }
        
        // Check for circles
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
        // Check if circle is close to balance
        if abs(circle.position.y - balanceY) < 100 {
            if circle.position.x < size.width / 2 {
                // Placed on LEFT side
                circle.position = CGPoint(x: size.width * 0.35, y: balanceY)
                leftPlaced = true
                leftSideFraction = circle.fraction
            } else {
                // Placed on RIGHT side
                circle.position = CGPoint(x: size.width * 0.65, y: balanceY)
                rightPlaced = true
                rightSideFraction = circle.fraction
            }
            
            // Snap animation
            circle.run(SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
            
            // Play sound effect (optional)
//            circle.run(SKAction.playSoundFileNamed("snap.wav", waitForCompletion: false))
        }
        
        // Check if both placed
        if leftPlaced && rightPlaced {
            compareAndTilt()
        }
    }
    
    private func compareAndTilt() {
        guard let leftFrac = leftSideFraction,
              let rightFrac = rightSideFraction else { return }
        
        let leftValue = leftFrac.decimalValue
        let rightValue = rightFrac.decimalValue
        
        var tiltAngle: CGFloat = 0
        var winnerFraction: Fraction?
        var resultText: String
        
        if abs(leftValue - rightValue) < 0.001 {
            // Equal fractions
            tiltAngle = 0
            resultText = "They're EQUAL! Both fractions are the same size!"
        } else if leftValue > rightValue {
            // Left side is heavier
            tiltAngle = -0.15
            winnerFraction = leftFrac
            resultText = "\(leftFrac.numerator)/\(leftFrac.denominator) is BIGGER!"
        } else {
            // Right side is heavier
            tiltAngle = 0.15
            winnerFraction = rightFrac
            resultText = "\(rightFrac.numerator)/\(rightFrac.denominator) is BIGGER!"
        }
        
        // Animate balance tilt
        balanceBeam.run(SKAction.rotate(toAngle: tiltAngle, duration: 0.5))
        
        // Highlight winner
        if let winner = winnerFraction {
            let winnerCircle = (leftCircle.fraction.numerator == winner.numerator &&
                                leftCircle.fraction.denominator == winner.denominator) ? leftCircle : rightCircle
            
            winnerCircle?.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.group([
                    SKAction.colorize(with: .systemGreen, colorBlendFactor: 0.6, duration: 0.3),
                    SKAction.scale(to: 1.2, duration: 0.3)
                ])
            ]))
        }
        
        // Show result
        showResult(text: resultText)
    }
    
    private func showResult(text: String) {
        // Remove old result if exists
        resultLabel?.removeFromParent()
        childNode(withName: "resultBackground")?.removeFromParent()
        
        // Create main label with wrapping support
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 32
        label.fontColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
        label.numberOfLines = 0  // Enable multi-line
        label.preferredMaxLayoutWidth = size.width * 0.85  // 85% of screen width
        label.lineBreakMode = .byWordWrapping
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        
        // Set text and measure actual size
        label.text = text
        
        // Position below the reset button with safe spacing
        let resultY = size.height * 0.55// Moved up from 0.15 to avoid overlap
        label.position = CGPoint(x: size.width / 2, y: resultY)
        label.alpha = 0
        
        // Calculate background size based on actual text bounds
        // Add padding to account for multi-line text
        let textBounds = label.frame
        let padding: CGFloat = 40
        let minHeight: CGFloat = 70
        
        let backgroundWidth = min(textBounds.width + padding, size.width * 0.9)
        let backgroundHeight = max(textBounds.height + padding, minHeight)
        
        // Create background with proper sizing
        let background = SKShapeNode(
            rectOf: CGSize(width: backgroundWidth, height: backgroundHeight),
            cornerRadius: 15
        )
        background.fillColor = UIColor(white: 1.0, alpha: 0.95)
        background.strokeColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 0.8)
        background.lineWidth = 3
        background.position = label.position
        background.zPosition = label.zPosition - 1
        background.alpha = 0
        background.name = "resultBackground"
        
        addChild(background)
        addChild(label)
        
        resultLabel = label
        
        // Fade in animation with slight bounce
        let fadeIn = SKAction.group([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.15)
            ])
        ])
        label.run(fadeIn)
        background.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    private func resetCircles() {
        // Reset positions
        leftCircle.position = CGPoint(x: size.width * 0.25, y: size.height * 0.60)
        rightCircle.position = CGPoint(x: size.width * 0.75, y: size.height * 0.60)
        
        // Reset colors and scales
        leftCircle.run(SKAction.group([
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
        rightCircle.run(SKAction.group([
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))
        
        // Reset balance
        balanceBeam.run(SKAction.rotate(toAngle: 0, duration: 0.3))
        
        // Reset state
        leftPlaced = false
        rightPlaced = false
        leftSideFraction = nil
        rightSideFraction = nil
        
        // Remove result label
        resultLabel?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - Public Fraction Structure for Students
public struct Fraction {
    public let numerator: Int
    public let denominator: Int
    
    public init(_ numerator: Int, _ denominator: Int) {
        // Validate denominator
        guard denominator > 0 else {
            fatalError("Denominator must be greater than 0. You tried \(numerator)/\(denominator)")
        }
        
        // Validate numerator
        guard numerator > 0 else {
            fatalError("Numerator must be greater than 0. You tried \(numerator)/\(denominator)")
        }
        
        // Warn if improper fraction (numerator > denominator)
        if numerator > denominator {
            print("⚠️ Warning: \(numerator)/\(denominator) is greater than 1 whole. This is an improper fraction!")
        }
        
        self.numerator = numerator
        self.denominator = denominator
    }
    
    var decimalValue: Double {
        return Double(numerator) / Double(denominator)
    }
}

// MARK: - Fraction Equality Helper
extension Fraction: Equatable {
    public static func == (lhs: Fraction, rhs: Fraction) -> Bool {
        // Compare actual values to handle equivalent fractions
        let lValue = Double(lhs.numerator) / Double(lhs.denominator)
        let rValue = Double(rhs.numerator) / Double(rhs.denominator)
        return abs(lValue - rValue) < 0.0001
    }
}

// MARK: - Fraction Circle Class
private class FractionCircle: SKNode {
    let fraction: Fraction
    private let circleNode: SKShapeNode
    private let shadedNode: SKShapeNode
    
    init(fraction: Fraction, radius: CGFloat) {
        self.fraction = fraction
        
        // Outer circle
        circleNode = SKShapeNode(circleOfRadius: radius)
        circleNode.fillColor = .white
        circleNode.strokeColor = .darkGray
        circleNode.lineWidth = 4
        
        // Shaded portion representing the fraction
        let angle = CGFloat(fraction.numerator) / CGFloat(fraction.denominator) * 2 * .pi
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addArc(withCenter: .zero, radius: radius, startAngle: -.pi / 2, endAngle: -.pi / 2 + angle, clockwise: true)
        path.close()
        
        shadedNode = SKShapeNode(path: path.cgPath)
        shadedNode.fillColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.8)
        shadedNode.strokeColor = .clear
        
        super.init()
        
        addChild(circleNode)
        addChild(shadedNode)
        
        // Fraction label
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 32
        label.fontColor = .black
        label.text = "\(fraction.numerator)/\(fraction.denominator)"
        label.position = CGPoint(x: 0, y: radius + 25)
        addChild(label)
        
        // Decimal value label (helps students understand)
        let decimalLabel = SKLabelNode(fontNamed: "Helvetica")
        decimalLabel.fontSize = 18
        decimalLabel.fontColor = .darkGray
        decimalLabel.text = String(format: "≈ %.2f", fraction.decimalValue)
        decimalLabel.position = CGPoint(x: 0, y: -radius - 25)
        addChild(decimalLabel)
        
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Factory Function
public func makeFractionSorterLiveView(leftFraction: Fraction, rightFraction: Fraction) -> PlaygroundLiveViewable {
    let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
    sceneView.backgroundColor = .white
    
    let scene = FractionSorterScene(size: sceneView.bounds.size, leftFraction: leftFraction, rightFraction: rightFraction)
    scene.scaleMode = .aspectFit
    sceneView.presentScene(scene)
    
    return sceneView
}
