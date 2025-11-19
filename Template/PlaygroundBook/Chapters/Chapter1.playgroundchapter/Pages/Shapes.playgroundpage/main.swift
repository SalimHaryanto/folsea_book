import BookAPI
import UIKit
import UserModule
/*:
 # Change the Shape
 
 On the right, there is a square.
 
 Your tasks:
 - Change the square's **color**.
 - Change the square's **size**.
 
 ### Instructions
 
 1. Create an `InteractiveScene`.
 2. Call `setColor(_:)` with a different color.
 3. Call `setSize(_:)` with a different number.
 4. Call `show(_:)` to display your scene.
 */

let scene = InteractiveScene()

// TODO: Change the color.
scene.setColor(.systemBlue)

// TODO: Change the size (try 50...200).
scene.setSize(100)

// Show the result in the live view.
show(scene)
