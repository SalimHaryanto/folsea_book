//
//  FractionSorterAPI.swift
//  
//
//  Created by Haryanto on 20/11/25.
//
import PlaygroundSupport
import BookCore
/// Shows a fraction comparison scene with two fractions on a balance scale.
///
/// Students can drag the fraction circles onto the scale to see which is bigger.
/// The heavier side (bigger fraction) will tilt down!
///
/// - Parameters:
///   - left: The first fraction to compare
///   - right: The second fraction to compare
public func showFractionComparison(left: Fraction, right: Fraction) {
    PlaygroundPage.current.needsIndefiniteExecution = true
    PlaygroundPage.current.liveView = makeFractionSorterLiveView(
        leftFraction: left,
        rightFraction: right
    )
}

// Re-export Fraction from BookCore so students only need to import BookAPI
public typealias Fraction = BookCore.Fraction
