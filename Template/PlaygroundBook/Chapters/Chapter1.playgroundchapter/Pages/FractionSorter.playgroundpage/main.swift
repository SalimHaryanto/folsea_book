import BookAPI
import PlaygroundSupport

/*:
 # Compare Fractions
 
 Which fraction is **BIGGER**?
 
 On the right, you'll see two fraction circles and a balance scale.
 Your job is to **drag each circle** onto the scale to find out which fraction is larger!
 
 ## Your Task
 
 1. Choose two fractions to compare by changing the numbers below.
 2. Drag the circles onto the balance scale.
 3. Watch which side goes down - that's the bigger fraction!
 4. Try different fractions to see how they compare.
 
 ### Try These Challenges:
 - Compare 1/2 and 3/4
 - Compare 2/3 and 3/5
 - Find two fractions that are equal (the scale stays balanced!)
 - Try fractions with the same denominator (like 2/5 and 4/5)
 */

// Choose your first fraction:
// Change these numbers to pick different fractions!
let firstFraction = Fraction(1, 2)   // 1/2

// Choose your second fraction:
let secondFraction = Fraction(3, 4)  // 3/4

// Show the fraction comparison scene
showFractionComparison(left: firstFraction, right: secondFraction)
