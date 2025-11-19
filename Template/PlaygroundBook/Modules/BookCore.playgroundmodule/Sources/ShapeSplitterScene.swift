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
    
    // MARK: - State
    private var squareDivisions: Int = 1
    private var circleDivisions: Int = 1
    private var selectedShape: ShapeType?
    
    private enum ShapeType {
        case square, circle
    }
    
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
    
    private func setupInstructions() {
        let label = SKLabelNode(fontNamed: "Helvetica")
        label.fontSize = 32
        label.fontColor = .black
        label.text = "Tap a shape to divide it"
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        addChild(label)
    }
    
    // MARK: - Touch Handling
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        if touchedNodes.contains(where: { $0.name == "square" }) {
            divideSquare()
        } else if touchedNodes.contains(where: { $0.name == "circle" }) {
            divideCircle()
        }
    }
    
    private func divideSquare() {
        currentDivisionLine?.removeFromParent()
        
        squareDivisions = squareDivisions == 1 ? 2 : (squareDivisions == 2 ? 4 : 1)
        
        switch squareDivisions {
        case 2:
            drawVerticalLine(in: squareShape)
            showFractionLabel("1/2", above: squareShape)
        case 4:
            drawCrossLines(in: squareShape)
            showFractionLabel("1/4", above: squareShape)
        default:
            showFractionLabel("1 whole", above: squareShape)
        }
        
        animateShape(squareShape)
    }
    
    private func divideCircle() {
        currentDivisionLine?.removeFromParent()
        
        circleDivisions = circleDivisions == 1 ? 2 : (circleDivisions == 2 ? 4 : 1)
        
        switch circleDivisions {
        case 2:
            drawDiameter(in: circleShape)
            showFractionLabel("1/2", above: circleShape)
        case 4:
            drawCrossDiameters(in: circleShape)
            showFractionLabel("1/4", above: circleShape)
        default:
            showFractionLabel("1 whole", above: circleShape)
        }
        
        animateShape(circleShape)
    }
    
    private func drawVerticalLine(in shape: SKShapeNode) {
        let line = SKShapeNode(rectOf: CGSize(width: 4, height: shape.frame.height))
        line.fillColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        line.position = shape.position
        line.zPosition = shape.zPosition + 1
        addChild(line)
        currentDivisionLine = line
    }
    
    private func drawDiameter(in shape: SKShapeNode) {
        let line = SKShapeNode(rectOf: CGSize(width: 4, height: shape.frame.height))
        line.fillColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        line.position = shape.position
        line.zPosition = shape.zPosition + 1
        addChild(line)
        currentDivisionLine = line
    }
    
    private func drawCrossLines(in shape: SKShapeNode) {
        let vLine = SKShapeNode(rectOf: CGSize(width: 4, height: shape.frame.height))
        vLine.fillColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        vLine.position = shape.position
        vLine.zPosition = shape.zPosition + 1
        addChild(vLine)
        
        let hLine = SKShapeNode(rectOf: CGSize(width: shape.frame.width, height: 4))
        hLine.fillColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        hLine.position = shape.position
        hLine.zPosition = shape.zPosition + 1
        addChild(hLine)
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