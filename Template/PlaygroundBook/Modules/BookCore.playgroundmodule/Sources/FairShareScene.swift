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
    private var slices: [PizzaSlice] = []
    private var fractionLabel: SKLabelNode!
    private var instructionLabel: SKLabelNode!
    private var friendsIcons: [SKShapeNode] = []
    
    // MARK: - State
    private var divisionState: DivisionState = .whole
    private var selectedSliceIndex: Int?
    
    private enum DivisionState {
        case whole, halves, quarters
        
        var sliceCount: Int {
            switch self {
            case .whole: return 1
            case .halves: return 2
            case .quarters: return 4
            }
        }
        
        var description: String {
            switch self {
            case .whole: return "1 whole pizza"
            case .halves: return "2 halves (1/2 each)"
            case .quarters: return "4 quarters (1/4 each)"
            }
        }
    }
    
    // MARK: - Constants
    private let pizzaRadius: CGFloat = 230
    private let pizzaColor = UIColor(red: 1.0, green: 0.65, blue: 0.3, alpha: 1.0)
    private let crustColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
    private let lineColor = UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
    private let selectedColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
    
    // MARK: - Setup
    public override func didMove(to view: SKView) {
        backgroundColor = .white
        setupLabels()
        setupFriends()
        createSlices(count: 1)
        updateDisplay()
    }
    
    private func setupLabels() {
        // Title
            let title = SKLabelNode(fontNamed: "Helvetica-Bold")
            title.fontSize = 36
            title.fontColor = .black
            title.text = "Fair Share Pizza"
            title.position = CGPoint(x: size.width / 2, y: size.height * 0.9)
            addChild(title)
            
            // Instructions - simpler now!
            instructionLabel = SKLabelNode(fontNamed: "Helvetica")
            instructionLabel.fontSize = 24
            instructionLabel.fontColor = .darkGray
            instructionLabel.text = "Tap a slice to select it"
            instructionLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
            addChild(instructionLabel)
            
            // Fraction label
            fractionLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            fractionLabel.fontSize = 40
            fractionLabel.fontColor = .black
            fractionLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.20)
            addChild(fractionLabel)
    }
    
    private func setupFriends() {
        // Simple stick figure representations
        let friendY = size.height * 0.75
        let spacing = size.width * 0.15
        
        for i in 0..<4 {
            let friend = createFriendIcon()
            friend.position = CGPoint(
                x: size.width / 2 - spacing * 1.5 + spacing * CGFloat(i),
                y: friendY
            )
            friend.alpha = 0  // Hidden initially
            friend.name = "friend_\(i)"
            addChild(friend)
            friendsIcons.append(friend)
        }
    }
    
    // MARK: - Enhanced Friend Icons with Colors
    private func createFriendIcon() -> SKShapeNode {
        let container = SKShapeNode()
        
        // Use different colors for variety
        let colors: [UIColor] = [
            UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0),  // Blue
            UIColor(red: 0.9, green: 0.4, blue: 0.4, alpha: 1.0),  // Red
            UIColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0),  // Green
            UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0)   // Yellow
        ]
        
        let colorIndex = friendsIcons.count % colors.count
        
        let head = SKShapeNode(circleOfRadius: 15)
        head.fillColor = colors[colorIndex]
        head.strokeColor = .darkGray
        head.lineWidth = 2
        head.position = CGPoint(x: 0, y: 15)
        
        let bodyPath = UIBezierPath()
        bodyPath.move(to: CGPoint(x: 0, y: 0))
        bodyPath.addLine(to: CGPoint(x: 0, y: -20))
        let body = SKShapeNode(path: bodyPath.cgPath)
        body.strokeColor = .darkGray
        body.lineWidth = 3
        
        container.addChild(head)
        container.addChild(body)
        
        // Add number label
        let numberLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        numberLabel.fontSize = 18
        numberLabel.fontColor = .white
        numberLabel.text = "\(friendsIcons.count + 1)"
        numberLabel.verticalAlignmentMode = .center
        numberLabel.position = CGPoint(x: 0, y: 15)
        container.addChild(numberLabel)
        
        return container
    }

    // MARK: - Optional Reset Button Enhancement
    private func setupResetButton() {
        let button = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 8)
        button.fillColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        button.strokeColor = .darkGray
        button.lineWidth = 2
        button.position = CGPoint(x: size.width / 2, y: size.height * 0.05)
        button.name = "resetButton"
        addChild(button)
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 20
        label.fontColor = .white
        label.text = "Reset"
        label.verticalAlignmentMode = .center
        button.addChild(label)
    }
    
    // MARK: - Slice Management
    private func createSlices(count: Int) {
        // Remove old slices
        slices.forEach { $0.removeFromParent() }
        slices.removeAll()
        selectedSliceIndex = nil
        
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        // Create new slices
        for i in 0..<count {
            let anglePerSlice = 2 * CGFloat.pi / CGFloat(count)
            let startAngle = CGFloat(i) * anglePerSlice - .pi / 2
            let endAngle = startAngle + anglePerSlice
            
            let slice = PizzaSlice(
                radius: pizzaRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                pizzaColor: pizzaColor,
                crustColor: crustColor,
                index: i
            )
            slice.position = CGPoint(x: centerX, y: centerY)
            addChild(slice)
            slices.append(slice)
        }
    }
    
    // MARK: - Fixed Touch Handling
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check for reset button
        let touchedNodes = nodes(at: location)
        if touchedNodes.contains(where: { $0.name == "resetButton" }) {
            resetToWhole()
            return
        }
        
        // Check if tap is within pizza area
        let centerPoint = CGPoint(x: size.width / 2, y: size.height / 2)
        let distance = hypot(location.x - centerPoint.x, location.y - centerPoint.y)
        
        guard distance <= pizzaRadius else { return }
        
        // Handle double-tap for division
        if touch.tapCount == 2 {
            advanceDivision()
            return
        }
        
        // Single tap: select slice
        if let touchedSlice = slices.first(where: { $0.contains(location) }) {
            handleSliceTouch(touchedSlice)
        }
    }

    // MARK: - Fixed Slice Selection with Toggle
    private func handleSliceTouch(_ slice: PizzaSlice) {
        // Toggle selection if tapping the same slice
        if selectedSliceIndex == slice.index {
            deselectAllSlices()
            fractionLabel.text = divisionState.description
            return
        }
        
        // Select new slice
        deselectAllSlices()
        slice.setSelected(true)
        selectedSliceIndex = slice.index
        
        // Update label to show individual slice
        let fractionText: String
        switch divisionState {
        case .whole:
            fractionText = "The whole pizza = 1"
        case .halves:
            fractionText = "This is 1/2 of the pizza"
        case .quarters:
            fractionText = "This is 1/4 of the pizza"
        }
        
        fractionLabel.text = fractionText
        
        // Animate selection
        slice.run(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }

    private func deselectAllSlices() {
        slices.forEach { $0.setSelected(false) }
        selectedSliceIndex = nil
    }
    
    private func advanceDivision() {
        switch divisionState {
        case .whole:
            divisionState = .halves
            createSlices(count: 2)
            showFriends(count: 2)
        case .halves:
            divisionState = .quarters
            createSlices(count: 4)
            showFriends(count: 4)
        case .quarters:
            divisionState = .whole
            createSlices(count: 1)
            hideFriends()
        }
        
        updateDisplay()
        animateTransition()
    }
    
    private func showFriends(count: Int) {
        for i in 0..<count {
            friendsIcons[i].run(SKAction.fadeIn(withDuration: 0.3))
        }
    }
    
    private func hideFriends() {
        friendsIcons.forEach { $0.run(SKAction.fadeOut(withDuration: 0.3)) }
    }
    
    private func updateDisplay() {
        fractionLabel.text = divisionState.description
        
        // Update instruction based on state
        if divisionState == .whole {
            instructionLabel.text = "Tap pizza to divide • Share with friends!"
        } else {
            instructionLabel.text = "Each friend gets one slice!"
        }
    }
    
    private func animateTransition() {
        // Stagger slice animations
        for (index, slice) in slices.enumerated() {
            let delay = Double(index) * 0.1
            slice.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.scale(to: 0.8, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ]))
        }
    }
    
    private func resetToWhole() {
        divisionState = .whole
        createSlices(count: 1)
        hideFriends()
        updateDisplay()
    }
}

// MARK: - Fixed PizzaSlice with Proper Hit Testing
private class PizzaSlice: SKNode {
    let index: Int
    private let sliceShape: SKShapeNode
    private let pizzaColor: UIColor
    private let selectedColor = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0)
    
    // Store geometry for hit testing
    private let radius: CGFloat
    private let startAngle: CGFloat
    private let endAngle: CGFloat
    
    init(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat,
         pizzaColor: UIColor, crustColor: UIColor, index: Int) {
        self.index = index
        self.pizzaColor = pizzaColor
        self.radius = radius
        self.startAngle = startAngle
        self.endAngle = endAngle
        
        // Create slice path
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addArc(withCenter: .zero, radius: radius,
                   startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.close()
        
        sliceShape = SKShapeNode(path: path.cgPath)
        sliceShape.fillColor = pizzaColor
        sliceShape.strokeColor = crustColor
        sliceShape.lineWidth = 4
        
        super.init()
        
        addChild(sliceShape)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(_ selected: Bool) {
        sliceShape.fillColor = selected ? selectedColor : pizzaColor
    }
    
    // CRITICAL: Proper hit testing for pie slices
    override func contains(_ point: CGPoint) -> Bool {
        // Convert to local coordinates
        let localPoint = convert(point, from: parent!)
        
        // Calculate distance from center
        let distance = hypot(localPoint.x, localPoint.y)
        
        // Check if within radius
        guard distance <= radius else { return false }
        
        // Calculate angle of touch point (in radians)
        var touchAngle = atan2(localPoint.y, localPoint.x)
        
        // Normalize angle to [0, 2π]
        if touchAngle < 0 {
            touchAngle += 2 * .pi
        }
        
        // Normalize start and end angles to [0, 2π]
        var normalizedStart = startAngle
        var normalizedEnd = endAngle
        
        while normalizedStart < 0 {
            normalizedStart += 2 * .pi
        }
        while normalizedEnd < 0 {
            normalizedEnd += 2 * .pi
        }
        
        // Handle wraparound case (e.g., slice from 350° to 10°)
        if normalizedStart < normalizedEnd {
            return touchAngle >= normalizedStart && touchAngle <= normalizedEnd
        } else {
            return touchAngle >= normalizedStart || touchAngle <= normalizedEnd
        }
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
