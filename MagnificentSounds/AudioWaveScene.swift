//
//  AudioWaveScene.swift
//  MagnificentSounds
//
//  Created by Tiger Nixon on 5/4/23.
//

import Foundation
import Metal
import UIKit
import simd

class AudioWaveScene: GraphicsDelegate {
    unowned var graphics: Graphics!
    
    weak var playbackMenuViewController: PlaybackMenuViewController!
    weak var audioSampler: AudioSampler!
    weak var timeSampler: TimeSampler!
    
    let recyclerShapeQuad2D = RecyclerShapeQuad2D()
    
    init(playbackMenuViewController: PlaybackMenuViewController, audioSampler: AudioSampler, timeSampler: TimeSampler) {
        self.playbackMenuViewController = playbackMenuViewController
        self.audioSampler = audioSampler
        self.timeSampler = timeSampler
    }
    
    var samples = [Float](repeating: -80.0, count: 256)
    var percents = [Float](repeating: 0.0, count: 256)
    //var percentsSquared = [Float](repeating: 0.0, count: 256)
    //var percentsCubed = [Float](repeating: 0.0, count: 256)
    //var percentsSine = [Float](repeating: 0.0, count: 256)
    //var percentsCosine = [Float](repeating: 0.0, count: 256)
    
    
    lazy var waveCycler1: WaveCycler = {
        let result = WaveCycler(graphics: graphics, audioWaveScene: self)
        result.setup()
        result.sampleOffset = 0
        result.sampleSmoothingCount = 6
        result.heightFactor = 1.0
        result.xShift = 0.0
        result.thickness = 6.0
        
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 0.5, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 1.0)
        result.colorCycler.add(red: 0.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 1.0)
        
        return result
    }()
    
    lazy var waveCycler2: WaveCycler = {
        let result = WaveCycler(graphics: graphics, audioWaveScene: self)
        result.setup()
        result.sampleOffset = 8
        result.sampleSmoothingCount = 6
        result.heightFactor = 0.9
        result.xShift = 4.0
        result.thickness = 5.5
        
        result.colorCycler.add(red: 0.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 0.5, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 1.0)
        
        
        return result
    }()
    
    lazy var waveCycler3: WaveCycler = {
        let result = WaveCycler(graphics: graphics, audioWaveScene: self)
        result.setup()
        result.sampleOffset = 16
        result.sampleSmoothingCount = 6
        result.heightFactor = 0.85
        result.xShift = 8.0
        result.thickness = 5.0
        
        
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 1.0)
        result.colorCycler.add(red: 0.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 0.5, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 1.0, blue: 0.0)
        
        
        return result
    }()
    
    lazy var waveCycler4: WaveCycler = {
        let result = WaveCycler(graphics: graphics, audioWaveScene: self)
        result.setup()
        result.sampleOffset = 24
        result.sampleSmoothingCount = 6
        result.heightFactor = 0.80
        result.xShift = 12.0
        result.thickness = 4.5
        
        result.colorCycler.add(red: 1.0, green: 0.5, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 1.0)
        result.colorCycler.add(red: 0.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 0.0)
        
        
        return result
    }()
    
    lazy var waveCycler5: WaveCycler = {
        let result = WaveCycler(graphics: graphics, audioWaveScene: self)
        result.setup()
        result.sampleOffset = 30
        result.sampleSmoothingCount = 6
        result.heightFactor = 0.75
        result.xShift = 16.0
        result.thickness = 4.0
        
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 0.5, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 1.0)
        result.colorCycler.add(red: 0.0, green: 0.0, blue: 1.0)
       
        
        return result
    }()
    
    lazy var waveCycler6: WaveCycler = {
        let result = WaveCycler(graphics: graphics, audioWaveScene: self)
        result.setup()
        result.sampleOffset = 36
        result.sampleSmoothingCount = 6
        result.heightFactor = 0.70
        result.xShift = 20.0
        result.thickness = 3.5
        
        
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 1.0)
        result.colorCycler.add(red: 0.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 1.0)
        result.colorCycler.add(red: 1.0, green: 0.0, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 0.5, blue: 0.0)
        result.colorCycler.add(red: 1.0, green: 1.0, blue: 0.0)
        result.colorCycler.add(red: 0.0, green: 1.0, blue: 0.0)
        
        return result
    }()
    
    
    func load() {
        
        for _ in 0..<100 {
            waveCycler1.update()
            waveCycler2.update()
            waveCycler3.update()
            waveCycler4.update()
            waveCycler5.update()
            waveCycler6.update()
        }
    }
    
    func update() {
        playbackMenuViewController.update()
        
        var sample: Float = -80.0
        if audioSampler.isPlaying {
            let time = audioSampler.time
            let duration = Float(timeSampler.trackLength)
            if duration > Math.epsilon {
                sample = timeSampler.sample(time: time)
            }
        } else {
            
        }
        if sample < -80.0 { sample = -80.0 }
        if sample > 0.0 { sample = 0.0 }
        for i in 1..<samples.count {
            samples[i - 1] = samples[i]
        }
        samples[samples.count - 1] = sample
        
        
        var percent = (80.0 + sample) / 80.0
        if percent < 0.0 { percent = 0.0 }
        if percent > 1.0 { percent = 1.0 }
        for i in 1..<percents.count {
            percents[i - 1] = percents[i]
        }
        percents[percents.count - 1] = percent
        
        
        
        waveCycler1.update()
        waveCycler2.update()
        waveCycler3.update()
        waveCycler4.update()
        waveCycler5.update()
        waveCycler6.update()
        
        
        if waveCycler2.cyclerNodes.count != waveCycler1.cyclerNodes.count {
            print("problem A")
        } else {
            
            // Link the sines...
            for index in 0..<waveCycler1.cyclerNodes.count {
                let node1 = waveCycler1.cyclerNodes[index]
                let node2 = waveCycler2.cyclerNodes[index]
                node2.sineAngle = node1.sineAngle
            }
            
        }
        
        if waveCycler3.cyclerNodes.count != waveCycler1.cyclerNodes.count {
            print("problem B")
        } else {
            
            // Link the sines...
            for index in 0..<waveCycler1.cyclerNodes.count {
                let node1 = waveCycler1.cyclerNodes[index]
                let node3 = waveCycler3.cyclerNodes[index]
                node3.sineAngle = node1.sineAngle
            }
            
        }
        
        if waveCycler4.cyclerNodes.count != waveCycler1.cyclerNodes.count {
            print("problem C")
        } else {
            
            // Link the sines...
            for index in 0..<waveCycler1.cyclerNodes.count {
                let node1 = waveCycler1.cyclerNodes[index]
                let node4 = waveCycler4.cyclerNodes[index]
                node4.sineAngle = node1.sineAngle
            }
            
        }
        
        if waveCycler5.cyclerNodes.count != waveCycler1.cyclerNodes.count {
            print("problem D")
        } else {
            
            // Link the sines...
            for index in 0..<waveCycler1.cyclerNodes.count {
                let node1 = waveCycler1.cyclerNodes[index]
                let node5 = waveCycler5.cyclerNodes[index]
                node5.sineAngle = node1.sineAngle
            }
            
        }
        
        if waveCycler6.cyclerNodes.count != waveCycler1.cyclerNodes.count {
            print("problem E")
        } else {
            
            // Link the sines...
            for index in 0..<waveCycler1.cyclerNodes.count {
                let node1 = waveCycler1.cyclerNodes[index]
                let node6 = waveCycler6.cyclerNodes[index]
                node6.sineAngle = node1.sineAngle
            }
            
        }
        
        
    }
    
    func sampleRecentPercents(count: Int, offset: Int) -> Float {
        var index = percents.count - 1 + offset
        if index >= 0 && index < percents.count && count > 0 {
            var sum: Float = percents[index]
            index -= 1
            var backCount = 1
            while backCount < count && index >= 0 {
                sum += percents[index]
                backCount += 1
                index -= 1
            }
            return sum / Float(count)
        } else {
            return 0.0
        }
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        
        var matrixProjection = simd_float4x4()
        matrixProjection.ortho(width: graphics.width, height: graphics.height)
        
        var matrixModelView = matrix_identity_float4x4
        
        recyclerShapeQuad2D.reset()
        
        /*
        var width = roundf((graphics.width - 60.0) / Float(samples.count))
        var totalWidth = width * Float(samples.count)
        var x = roundf(graphics.width * 0.5 - totalWidth * 0.5)
        
        graphics.set(pipelineState: .shape2DNoBlending, renderEncoder: renderEncoder)
        
        for i in 0..<samples.count {
            
            let sample = samples[i]
            var percent = (80.0 + sample) / 80.0
            if percent < 0.0 { percent = 0.0 }
            if percent > 1.0 { percent = 1.0 }
            
            percent = 1.0 - (1.0 - percent * percent)
            
            //__exp10f(sample / 20.0)
            //print("per = \(percent)")
            
            var centerY = graphics.height * 0.5
            
            var height = graphics.height * 0.5 * percent
            
            var y = centerY - (height * 0.5)
            
            
            recyclerShapeQuad2D.set(red: Float.random(in: 0.0...1.0), green: Float.random(in: 0.0...1.0), blue: Float.random(in: 0.0...1.0))
            recyclerShapeQuad2D.drawRect(graphics: graphics,
                                         renderEncoder: renderEncoder,
                                         projection: matrixProjection,
                                         modelView: matrixModelView,
                                         origin: simd_float2(x, y),
                                         size: simd_float2(width, height))
            
            
            x += width
        }

        
        graphics.set(pipelineState: .shape2DAlphaBlending, renderEncoder: renderEncoder)
        
        */
        
        waveCycler6.draw(renderEncoder: renderEncoder)
        waveCycler5.draw(renderEncoder: renderEncoder)
        waveCycler4.draw(renderEncoder: renderEncoder)
        waveCycler3.draw(renderEncoder: renderEncoder)
        waveCycler2.draw(renderEncoder: renderEncoder)
        waveCycler1.draw(renderEncoder: renderEncoder)
        
    }
    
    func touchBegan(touch: UITouch, x: Float, y: Float) {
        
    }
    
    func touchMoved(touch: UITouch, x: Float, y: Float) {
        
    }
    
    func touchEnded(touch: UITouch, x: Float, y: Float) {
        
    }
}

