//
//  ColorCycler.swift
//  MagnificentSounds
//
//  Created by Screwy Uncle Louie on 5/7/23.
//

import Foundation

class ColorCycler {
    
    struct ColorCyclerNode {
        var red: Float
        var green: Float
        var blue: Float
        var alpha: Float
    }
    
    var nodes = [ColorCyclerNode]()
    
    func add(red: Float, green: Float, blue: Float) {
        nodes.append(ColorCyclerNode(red: red, green: green, blue: blue, alpha: 0.5))
    }
    
    var maxPos: Float {
        if nodes.count <= 1 {
            return 1.0
        } else {
            return Float(nodes.count)
        }
    }
    
    func get(pos: Float) -> ColorCyclerNode {
        
        var result = ColorCyclerNode(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        if nodes.count <= 0 {
            
        } else if nodes.count == 1 {
            result.red = nodes[0].red
            result.green = nodes[0].green
            result.blue = nodes[0].blue
            result.alpha = nodes[0].alpha
            
        } else {
            var index = Int(pos)
            if index < 0 {
                result.red = nodes[0].red
                result.green = nodes[0].green
                result.blue = nodes[0].blue
                result.alpha = nodes[0].alpha
            }
            else if index >= nodes.count {
                result.red = nodes[nodes.count - 1].red
                result.green = nodes[nodes.count - 1].green
                result.blue = nodes[nodes.count - 1].blue
                result.alpha = nodes[nodes.count - 1].alpha
            } else {
                
                var otherIndex = (index + 1) % nodes.count
                var factor = pos - Float(index)
                result.red = nodes[index].red + (nodes[otherIndex].red - nodes[index].red) * factor
                result.green = nodes[index].green + (nodes[otherIndex].green - nodes[index].red) * factor
                result.blue = nodes[index].blue + (nodes[otherIndex].blue - nodes[index].blue) * factor
                result.alpha = nodes[index].alpha + (nodes[otherIndex].alpha - nodes[index].red) * factor
            }
            
        }
        
        return result
        
    }
    
    
}
