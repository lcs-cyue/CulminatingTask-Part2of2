import Foundation
import CanvasGraphics

class Sketch : NSObject {
    
    // NOTE: Every sketch must contain an object of type Canvas named 'canvas'
    //       Therefore, the line immediately below must always be present.
    let canvas: Canvas
    
    // L-system definitions
    let coniferousTree: LindenmayerSystem
    let purpleFlower: LindenmayerSystem
    let dandelion: LindenmayerSystem
    
    // This function runs once
    override init() {
        
        // Create canvas object – specify size
        canvas = Canvas(width: 500, height: 500)
        
        // Draw slowly
        //canvas.framesPerSecond = 1
        
        // Define a stochastic system that resembles a coniferous tree
        coniferousTree = LindenmayerSystem(axiom: "SF",
                                           angle: 20,
                                           rules: ["F": [
                                            RuleSet(odds: 1, successorText: "3F[++1F[X]][+2F][-4F][--5F[X]]6F"),
                                            RuleSet(odds: 1, successorText: "3F[+1F][+2F][-4F]5F"),
                                            RuleSet(odds: 1, successorText: "3F[+1F][-2F][--6F]4F"),
                                            ],
                                                   "X": [
                                                    RuleSet(odds: 1, successorText: "X")
                                            ]
            ],
                                           colors: ["1": Color(hue: 170, saturation: 100, brightness: 61, alpha: 100),
                                                    "2": Color(hue: 184, saturation: 97, brightness: 46, alpha: 100),
                                                    "3": Color(hue: 195, saturation: 87, brightness: 8, alpha: 100),
                                                    "4": Color(hue: 185, saturation: 84, brightness: 41, alpha: 100),
                                                    "5": Color(hue: 166, saturation: 26, brightness: 100, alpha: 100),
                                                    "6": Color(hue: 211, saturation: 71, brightness: 53, alpha: 100)
            ],
                                           generations: 5)
        
        
        purpleFlower = LindenmayerSystem(axiom: "F-F-F-F-F-F",
                                         angle: 300,
                                         rules: ["F": [
                                            RuleSet(odds: 1, successorText: "1F-2X++1F+2F-1X+2F"),
                                            ],
                                                 "X": [
                                                    RuleSet(odds: 1, successorText: "1F-2X+1F++2X+1F+2X")
                                            ]
            ],
                                         colors: ["1": Color(hue: 288, saturation: 80, brightness: 36, alpha: 100),
                                                  "2": Color(hue: 174, saturation: 71, brightness: 88, alpha: 100),
            ],
                                         generations: 5)
        
        dandelion = LindenmayerSystem(axiom: "2F",
                                      angle: 20,
                                      rules: ["F": [
                                        RuleSet(odds: 1, successorText: "X[++F][+F][-F][--F]"),
                                        ],
                                              "X": [
                                                RuleSet(odds: 1, successorText: "XX")
                                        ]
            ],
                                      colors: ["2": Color(hue: 132, saturation: 3, brightness: 98, alpha: 100),
            ],
                                      generations: 4)
        
        // Create a gradient sky background, blue to white as vertical location increases
        for y in 300...500 {
            
            // Set the line saturation to progressively get closer to white
            let currentSaturation = 100.0 - Float(y - 300) / 2
            // DEBUG: Uncomment line below to see how this value changes
            print("currentSaturation is: \(currentSaturation)")
            canvas.lineColor = Color(hue: 270.0, saturation: currentSaturation, brightness: 70.0, alpha: 100.0)
            
            // Draw a horizontal line at this vertical location
            canvas.drawLine(from: Point(x: 0, y: y), to: Point(x: canvas.width, y: y))
            
        }
        
        // Create a gradient ground background, brown to darker brown as vertical location increases
        // NOTE: Can use the HSV/HSB sliders (third from top) at this site for help picking colours:
        //       http://colorizer.org
        for y in 0...300 {
            
            // Set the line brightness to progressively get closer to black
            let currentBrightness = 50.0 - Float(y) / 30.0 * 3.0
            // DEBUG: Uncomment line below to see how this value changes
            print("currentBrightness is \(currentBrightness)")
            canvas.lineColor = Color(hue: 25.0, saturation: 68.0, brightness: currentBrightness, alpha: 100.0)
            
            // Draw a horizontal line at this vertical location
            canvas.drawLine(from: Point(x: 0, y: y), to: Point(x: canvas.width, y: y))
            
        }
        
        // Create 9 trees, drawn from their tops along a quadratic path
        
        // Define the vertex of the parabolic path (top right of canvas)
        let vertex = Point(x: 450, y: 350)
        
        // Define some other point on the parabolic path (in this case, closer to bottom left)
        let anotherPointOnParabola = Point(x: 100, y: 225)
        
        // Work out the "a" value for the parabola (vertical stretch)
        let a = (anotherPointOnParabola.y - vertex.y) / pow(anotherPointOnParabola.x - vertex.x, 2)
        
        // Iterate to create 9 trees
        for i in 1...9 {
            
            // Use a quadratic relationship to define the vertical starting point for the top of each tree
            // (trees grow down from starting point)
            let x = CGFloat(i - 1) * 90 + 75
            // This defines "spread" of the trees along the quadratic path
            //let y = a * pow(x - vertex.x, 2) + vertex.y     // Determine vertical position using y = a(x-h)^2 + k
            let y = a * pow(x - vertex.x, 2) + vertex.y
            
            // DEBUG: To help see where starting points are
            print("Starting point for tree is... x: \(x), y: \(y)")
            
            // Define the length of the tree's initial stroke
            let length = 27.0 - Double(y) / 16.0            // Piggyback on quadratic change in y values to set length
            print("Length of line for system is: \(length)")
            
            // Generate the tree
            var aTree = VisualizedLindenmayerSystem(system: coniferousTree,
                                                    length: length,
                                                    initialDirection: 270,
                                                    reduction: 1.25,
                                                    pointToStartRenderingFrom: Point(x: x, y: y),
                                                    drawnOn: canvas)
            
            //draw flowers along the bottom of th canvas
            for i in 1...100 {
                let x = 20 * i
                let y = 100
                var aFlower = VisualizedLindenmayerSystem(system: purpleFlower,
                                                          length: length,
                                                          initialDirection: 0,
                                                          reduction: 1.5,
                                                          pointToStartRenderingFrom: Point(x: x, y: y),
                                                          drawnOn: canvas)
                aFlower.renderFullSystem()
            }
            
            //create Dandelion in random positions
            
            for _ in 1...10 {
                let x = random(from: 0, to: 500)
                let y = random(from: 0, to: 500)
                var dandelionFlower = VisualizedLindenmayerSystem(system: dandelion,
                                                                  length: length,
                                                                  initialDirection: 90,
                                                                  reduction: 0.6,
                                                                  pointToStartRenderingFrom: Point(x: x, y: y),
                                                                  drawnOn: canvas)
                dandelionFlower.renderFullSystem()
            }
            
            
            
            // Render this tree
            aTree.renderFullSystem()
            
            
            
            
        }
        
        
    }
    
    // This function runs repeatedly, forever, to create the animated effect
    func draw() {
        
        // Nothing to animate, so nothing in this function
        
    }
    
}
