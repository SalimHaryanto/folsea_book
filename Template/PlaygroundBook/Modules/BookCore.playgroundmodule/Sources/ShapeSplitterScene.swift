//
//  ShapeSplitterScene.swift
//  
//
//  Created by Haryanto on 20/11/25.
//


import UIKit
import SpriteKit
import PlaygroundSupport

public final class ShapeSplitterScene: SKScene {
    
    // MARK: - Nodes (max 3 objects on screen)
    private var squareShape: SKShapeNode!
    private var circleShape: SKShapeNode!
    private var currentDivisionLine: SKShapeNode?
    
    // MARK: - Fixed State Management
    private var squareDivisions: Int = 1
    private var circleDivisions: Int = 1
    private var squareLines: [SKShapeNode] = []
    private var circleLines: [SKShapeNode] = []

    // MARK: - Constants
    private let lineWidth: CGFloat = 2
    private let labelOffset: CGFloat = 40
    private let lineColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
    
    // MARK: - Setup
    public override func didMove(to view: SKView) {
        backgroundColor = .white
        setupShapes()
        setupInstructions()
    }
    
    private func setupShapes() {
        // Square (left side)
        let squareSize: CGFloat = size.width * 0.3
        squareShape = SKShapeNode(rectOf: CGSize(width: squareSize, height: squareSize))
        squareShape.fillColor = UIColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0)
        squareShape.strokeColor = .darkGray
        squareShape.lineWidth = 3
        squareShape.position = CGPoint(x: size.width * 0.3, y: size.height / 2)
        squareShape.name = "square"
        addChild(squareShape)
        
        // Circle (right side)
        let radius = squareSize / 2
        circleShape = SKShapeNode(circleOfRadius: radius)
        circleShape.fillColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 1.0)
        circleShape.strokeColor = .darkGray
        circleShape.lineWidth = 3
        circleShape.position = CGPoint(x: size.width * 0.7, y: size.height / 2)
        circleShape.name = "circle"
        addChild(circleShape)
    }
    
    // MARK: - Visual Enhancement: Shading
    private func shadeQuarter(in shape: SKShapeNode) {
        let shadingName = "shading_\(shape.name ?? "")"
        childNode(withName: shadingName)?.removeFromParent()
        
        let quarterSize = shape.frame.width / 2
        let shading: SKShapeNode
        
        if shape.name == "square" {
            // Shade top-left quarter
            shading = SKShapeNode(rectOf: CGSize(width: quarterSize, height: quarterSize))
            let offsetX = -quarterSize / 2
            let offsetY = quarterSize / 2
            shading.position = CGPoint(x: shape.position.x + offsetX, y: shape.position.y + offsetY)
        } else {
            // Shade top-right quarter (approximation with wedge)
            let path = UIBezierPath()
            let center = CGPoint.zero
            let radius = quarterSize
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius,
                       startAngle: -.pi / 2, endAngle: 0, clockwise: true)
            path.close()
            
            shading = SKShapeNode(path: path.cgPath)
            shading.position = shape.position
        }
        
        shading.fillColor = UIColor(white: 0, alpha: 0.2)
        shading.strokeColor = .clear
        shading.name = shadingName
        shading.zPosition = shape.zPosition + 0.5
        addChild(shading)
        
        // Add "1/4" label in the shaded area
        let pieceLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        pieceLabel.fontSize = 24
        pieceLabel.fontColor = .darkGray
        pieceLabel.text = "1/4"
        pieceLabel.name = "piece_\(shadingName)"
        
        if shape.name == "square" {
            pieceLabel.position = CGPoint(
                x: shading.position.x,
                y: shading.position.y - 8
            )
        } else {
            pieceLabel.position = CGPoint(
                x: shape.position.x + quarterSize / 2,
                y: shape.position.y + quarterSize / 2 - 8
            )
        }
        
        addChild(pieceLabel)
    }

    private func removeShading(from shape: SKShapeNode) {
        let shadingName = "shading_\(shape.name ?? "")"
        childNode(withName: shadingName)?.removeFromParent()
        childNode(withName: "piece_\(shadingName)")?.removeFromParent()
    }

    // MARK: - Enhanced Instructions
    private func setupInstructions() {
        let label = SKLabelNode(fontNamed: "Helvetica")
        label.fontSize = 32
        label.fontColor = .black
        label.text = "Tap a shape to divide it"
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        addChild(label)
        
        // Add hint label
        let hint = SKLabelNode(fontNamed: "Helvetica")
        hint.fontSize = 20
        hint.fontColor = .gray
        hint.text = "Tap again to divide further"
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.80)
        addChild(hint)
        
        // Add subtle pulse to indicate interactivity
        [squareShape, circleShape].forEach { shape in
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.8, duration: 1.0),
                SKAction.fadeAlpha(to: 1.0, duration: 1.0)
            ])
            shape?.run(SKAction.repeatForever(pulse))
        }
    }

    // MARK: - Reset Button (optional enhancement)
    private func setupResetButton() {
        let resetButton = SKShapeNode(rectOf: CGSize(width: 120, height: 50), cornerRadius: 10)
        resetButton.fillColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        resetButton.strokeColor = .darkGray
        resetButton.lineWidth = 2
        resetButton.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        resetButton.name = "resetButton"
        addChild(resetButton)
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 24
        label.fontColor = .white
        label.text = "Reset"
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        resetButton.addChild(label)
    }
    
    // MARK: - Touch Handling with Reset
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        if touchedNodes.contains(where: { $0.name == "resetButton" }) {
            resetAllShapes()
        } else if touchedNodes.contains(where: { $0.name == "square" }) {
            divideSquare()
        } else if touchedNodes.contains(where: { $0.name == "circle" }) {
            divideCircle()
        }
    }

    private func resetAllShapes() {
        squareDivisions = 1
        circleDivisions = 1
        clearLines(for: squareShape, lines: &squareLines)
        clearLines(for: circleShape, lines: &circleLines)
        removeShading(from: squareShape)
        removeShading(from: circleShape)
        showFractionLabel("1 whole", above: squareShape)
        showFractionLabel("1 whole", above: circleShape)
    }

    // MARK: - Fixed Division Methods
    private func divideSquare() {
        clearLines(for: squareShape, lines: &squareLines)
        
        squareDivisions = squareDivisions == 1 ? 2 : (squareDivisions == 2 ? 4 : 1)
        
        switch squareDivisions {
        case 2:
            let line = drawVerticalLine(in: squareShape)
            squareLines.append(line)
            showFractionLabel("2 halves", above: squareShape)
        case 4:
            let lines = drawCrossLines(in: squareShape)
            squareLines.append(contentsOf: lines)
            showFractionLabel("4 quarters", above: squareShape)
            shadeQuarter(in: squareShape)
        default:
            showFractionLabel("1 whole", above: squareShape)
            removeShading(from: squareShape)
        }
        
        animateShape(squareShape)
    }

    private func divideCircle() {
        clearLines(for: circleShape, lines: &circleLines)
        
        circleDivisions = circleDivisions == 1 ? 2 : (circleDivisions == 2 ? 4 : 1)
        
        switch circleDivisions {
        case 2:
            let line = drawVerticalLine(in: circleShape)
            circleLines.append(line)
            showFractionLabel("2 halves", above: circleShape)
        case 4:
            let lines = drawCrossLines(in: circleShape)
            circleLines.append(contentsOf: lines)
            showFractionLabel("4 quarters", above: circleShape)
            shadeQuarter(in: circleShape)
        default:
            showFractionLabel("1 whole", above: circleShape)
            removeShading(from: circleShape)
        }
        
        animateShape(circleShape)
    }

    // MARK: - Fixed Line Drawing (returns created nodes)
    private func drawVerticalLine(in shape: SKShapeNode) -> SKShapeNode {
        let line = SKShapeNode(rectOf: CGSize(width: lineWidth, height: shape.frame.height))
        line.fillColor = lineColor
        line.strokeColor = .clear
        line.position = shape.position
        line.zPosition = shape.zPosition + 1
        addChild(line)
        return line
    }
    
    private func drawCrossLines(in shape: SKShapeNode) -> [SKShapeNode] {
        let vLine = SKShapeNode(rectOf: CGSize(width: lineWidth, height: shape.frame.height))
        vLine.fillColor = lineColor
        vLine.strokeColor = .clear
        vLine.position = shape.position
        vLine.zPosition = shape.zPosition + 1
        addChild(vLine)
        
        let hLine = SKShapeNode(rectOf: CGSize(width: shape.frame.width, height: lineWidth))
        hLine.fillColor = lineColor
        hLine.strokeColor = .clear
        hLine.position = shape.position
        hLine.zPosition = shape.zPosition + 1
        addChild(hLine)
        
        return [vLine, hLine]
    }

    private func clearLines(for shape: SKShapeNode, lines: inout [SKShapeNode]) {
        lines.forEach { $0.removeFromParent() }
        lines.removeAll()
    }
    
    private func drawCrossDiameters(in shape: SKShapeNode) {
        drawCrossLines(in: shape)
    }
    
    private func showFractionLabel(_ text: String, above shape: SKShapeNode) {
        let labelName = "fraction_\(shape.name ?? "")"
        childNode(withName: labelName)?.removeFromParent()
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 36
        label.fontColor = .black
        label.text = text
        label.name = labelName
        label.position = CGPoint(x: shape.position.x, y: shape.position.y + shape.frame.height / 2 + 40)
        addChild(label)
    }
    
    private func animateShape(_ shape: SKShapeNode) {
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        shape.run(pulse)
    }
}

// MARK: - Factory
public func makeShapeSplitterLiveView() -> PlaygroundLiveViewable {
    let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
    sceneView.backgroundColor = .white
    
    let scene = ShapeSplitterScene(size: sceneView.bounds.size)
    scene.scaleMode = .aspectFit
    sceneView.presentScene(scene)
    
    return sceneView
}
