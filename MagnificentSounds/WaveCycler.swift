//
//  WaveCycler.swift
//  MagnificentSounds
//
//  Created by Screwy Uncle Louie on 5/7/23.
//

import Foundation
import Metal
import UIKit
import simd

class WaveCycler {
    
    class WaveCyclerNode {
        enum WaveCyclerNodeDirection {
            case up
            case down
            mutating func toggle() {
                switch self {
                case .up:
                    self = .down
                case .down:
                    self = .up
                }
            }
            var factor: Float {
                switch self {
                case .up:
                    return -1.0
                case .down:
                    return 1.0
                }
            }
        }
        var x: Float
        var direction: WaveCyclerNodeDirection
        init(x: Float, direction: WaveCyclerNodeDirection) {
            self.x = x
            self.direction = direction
        }
        
        var percent: Float = 0.0
        var magnitude: Float = 0.0
        
        var sineAngle: Float = 0.0
        var sineAngleSpeed: Float = 0.1
        
        var directionFactor: Float { direction.factor }
    }
    
    let colorCycler = ColorCycler()
    
    var spawnTime = 12
    var spawnTimeRandomness = 0
    
    var spawnTick = 0
    
    var sampleOffset: Int = 0
    var sampleSmoothingCount: Int = 1
    
    var heightFactor: Float = 1.0
    
    var globalSineAngle: Float = 0.0
    
    var clampFactor: Float = 0.0
    
    var cyclerNodes = [WaveCyclerNode]()
    private var cyclerNodesQueue = [WaveCyclerNode]()
    private var cyclerNodesCompleted = [WaveCyclerNode]()
    private var cyclerNodesKeep = [WaveCyclerNode]()
    
    lazy var audioWave1: AudioWave = {
       AudioWave(graphics: graphics)
    }()
    lazy var audioWave2: AudioWave = {
       AudioWave(graphics: graphics)
    }()
    /*
    lazy var audioWave3: AudioWave = {
       AudioWave(graphics: graphics)
    }()
    lazy var audioWave4: AudioWave = {
       AudioWave(graphics: graphics)
    }()
    */
    
    var audioWaveNodes = [AudioWaveNode]()
    
    var nodeDirection = WaveCyclerNode.WaveCyclerNodeDirection.up
    
    var xShift: Float = 0.0
    
    lazy var baseHeight: Float = {
        let dimension = min(graphics.width, graphics.height)
        let maxHeight: Float = 120.0
        return min(dimension * 0.25, maxHeight)
    }()
    
    lazy var xSpeed: Float = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 8.0
        } else {
            return 6.0
        }
    }()
    
    lazy var xMax: Float = {
        graphics.width + 80.0
    }()
    
    lazy var xMin: Float = {
        -80.0
    }()
    
    var thickness: Float {
        set {
            audioWave1.thickness = newValue
            audioWave2.thickness = newValue
        }
        get {
            audioWave1.thickness
        }
    }
    
    var colorOffset: Float = 0.0
    
    let graphics: Graphics
    let audioWaveScene: AudioWaveScene
    required init(graphics: Graphics, audioWaveScene: AudioWaveScene) {
        self.graphics = graphics
        self.audioWaveScene = audioWaveScene
    }
    
    func setup() {
        
    }
    
    func update() {
        
        colorOffset += 0.1
        if colorOffset > colorCycler.maxPos {
            colorOffset -= colorCycler.maxPos
        }
        
        let pi2 = Float.pi * 2.0
        
        globalSineAngle += 0.05
        if globalSineAngle >= pi2 {
            globalSineAngle -= pi2
        }
        
        let sample16 = audioWaveScene.sampleRecentPercents(count: 16, offset: -sampleOffset)
        let clamp = sample16 < 0.05
        
        if clamp {
            clampFactor -= 0.02
            if clampFactor < 0.0 {
                clampFactor = 0.0
            }
            
        } else {
            clampFactor += 0.02
            if clampFactor > 1.0 {
                clampFactor = 1.0
            }
        }
        
        spawnTick -= 1
        if spawnTick <= 0 {
            spawnTick = spawnTime
            if spawnTimeRandomness > 0 {
                spawnTick += Int.random(in: 0...spawnTimeRandomness)
            }
            
            
            let node: WaveCyclerNode
            if let _node = cyclerNodesQueue.popLast() {
                node = _node
                node.x = xMax
                node.direction = nodeDirection
                
            } else {
                node = WaveCyclerNode(x: xMax,
                                      direction: nodeDirection)
            }
            node.percent = samplePercent(node: node)
            
            node.sineAngle = Float.pi
            node.sineAngleSpeed = Float.random(in: 0.01...0.05)
            
            cyclerNodes.append(node)
            
            nodeDirection.toggle()
        }
        
        
        
        for index in 0..<cyclerNodes.count {
            let node = cyclerNodes[index]
            node.x -= xSpeed
            
            node.sineAngle += node.sineAngleSpeed
            if node.sineAngle >= pi2 {
                node.sineAngle -= pi2
            }
            
            if node.x < xMin {
                cyclerNodesCompleted.append(node)
            }
        }
        
        if cyclerNodesCompleted.count > 0 {
            cyclerNodesKeep.removeAll(keepingCapacity: true)
            for index in 0..<cyclerNodes.count {
                let node = cyclerNodes[index]
                if isCompleted(node: node) {
                    cyclerNodesQueue.append(node)
                } else {
                    cyclerNodesKeep.append(node)
                }
            }
            
            cyclerNodes.removeAll(keepingCapacity: true)
            for index in 0..<cyclerNodesKeep.count {
                let node = cyclerNodesKeep[index]
                cyclerNodes.append(node)
            }
            cyclerNodesKeep.removeAll(keepingCapacity: true)
        }
        cyclerNodesCompleted.removeAll(keepingCapacity: true)
        
        //var cyclerNodes = [WaveCyclerNode]()
        //var cyclerNodesQueue = [WaveCyclerNode]()
    }
    
    func samplePercent(node: WaveCyclerNode) -> Float {
        
        audioWaveScene.sampleRecentPercents(count: sampleSmoothingCount, offset: -sampleOffset)
        
        /*
        var index = audioWaveScene.percents.count - 1 - sampleOffset
        if index >= 0 && index < audioWaveScene.percents.count {
            var sum: Float = audioWaveScene.percents[index]
            var count = 1
            index -= 1
            var backCount = 1
            while backCount < sampleSmoothingCount && index >= 0 {
                sum += audioWaveScene.percents[index]
                count += 1
                backCount += 1
                index -= 1
            }
            return sum / Float(count)
        } else {
            return 0.0
        }
        */
        
        //var sampleOffset: Int = 0
        //var sampleSmoothingCount: Int = 1
        
    }
    
    func isCompleted(node: WaveCyclerNode) -> Bool {
        for _node in cyclerNodesCompleted {
            if _node === node {
                return true
            }
        }
        return false
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        
        
        
        let centerY = Float(Int(graphics.height * 0.5 + 0.5)) - 30.0
        
        var projection = simd_float4x4()
        projection.ortho(width: graphics.width, height: graphics.height)
        
        let modelView = matrix_identity_float4x4
        
        while audioWaveNodes.count < cyclerNodes.count {
            audioWaveNodes.append(AudioWaveNode(x: 0.0, magnitude: 0.0))
        }
        
        
        
        
        
        for index in 0..<cyclerNodes.count {
            let node = cyclerNodes[index]
            
            let sine = sinf(globalSineAngle + node.sineAngle)
            
            let x = node.x + xShift
            let y = centerY + node.percent * node.directionFactor * baseHeight
            
            audioWaveNodes[index].x = x
            audioWaveNodes[index].magnitude = node.percent * node.directionFactor * baseHeight * sine * clampFactor * heightFactor * 0.75
        }
        
        audioWave2.set(nodes: audioWaveNodes, count: cyclerNodes.count)
        audioWave2.draw(renderEncoder: renderEncoder, colorCycler: colorCycler, colorOffset: colorOffset + 1.0, colorSpeed: 0.02)
        
        
        for index in 0..<cyclerNodes.count {
            let node = cyclerNodes[index]
            
            let sine = sinf(globalSineAngle + node.sineAngle)
            
            let x = node.x + xShift
            let y = centerY + node.percent * node.directionFactor * baseHeight
            
            audioWaveNodes[index].x = x
            audioWaveNodes[index].magnitude = node.percent * node.directionFactor * baseHeight * sine * clampFactor * heightFactor
        }
        
        audioWave1.set(nodes: audioWaveNodes, count: cyclerNodes.count)
        audioWave1.draw(renderEncoder: renderEncoder, colorCycler: colorCycler, colorOffset: colorOffset, colorSpeed: 0.02)
        
        
        
    }
    
}
