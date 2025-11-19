//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import UIKit
import BookCore
import PlaygroundSupport

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
//PlaygroundPage.current.liveView = instantiateLiveView()
public func setUpLiveView() -> PlaygroundLiveViewable {
    return makeFairShareLiveView()
}

//public var liveViewConfiguration: PlaygroundLiveViewConfiguration {
//    return .sideBySide
//}
