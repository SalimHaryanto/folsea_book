//
//  InteractiveSceneViewController.swift
//  
//
//  Created by Haryanto on 19/11/25.
//


import UIKit
import PlaygroundSupport

public final class InteractiveSceneViewController: UIViewController {

    private let squareView = UIView()
    
    public var squareColor: UIColor = .systemBlue {
        didSet { updateView() }
    }
    
    public var squareSize: CGFloat = 100 {
        didSet { updateView() }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        squareView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(squareView)
        
        NSLayoutConstraint.activate([
            squareView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            squareView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            squareView.widthAnchor.constraint(equalToConstant: squareSize),
            squareView.heightAnchor.constraint(equalTo: squareView.widthAnchor)
        ])
        
        updateView()
    }
    
    private func updateView() {
        squareView.backgroundColor = squareColor
        
        if let width = squareView.constraints.first(where: { $0.firstAttribute == .width }) {
            width.constant = squareSize
        }
        
        view.layoutIfNeeded()
    }
}

// Factory for both PlaygroundBook and LiveViewTestApp.
public func makeInteractiveSceneLiveView(
    color: UIColor = .systemBlue,
    size: CGFloat = 100
) -> PlaygroundLiveViewable {
    let vc = InteractiveSceneViewController()
    vc.squareColor = color
    vc.squareSize = size
    return vc
}
