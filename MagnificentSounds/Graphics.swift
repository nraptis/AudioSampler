//
//  Graphics.swift
//  RebuildEarth
//
//  Created by Nicky Taylor on 2/9/23.
//

import Foundation
import Metal
import MetalKit

protocol GraphicsDelegate: AnyObject {
    var graphics: Graphics! { set get }
    func initialize(graphics: Graphics)
    func update()
    func load()
    func draw(renderEncoder: MTLRenderCommandEncoder)
    
    func touchBegan(touch: UITouch, x: Float, y: Float)
    func touchMoved(touch: UITouch, x: Float, y: Float)
    func touchEnded(touch: UITouch, x: Float, y: Float)
    
}

extension GraphicsDelegate {
    func initialize(graphics: Graphics) {
        self.graphics = graphics
    }
}

class Graphics {
    
    enum PipelineState {
        case invalid
        
        case shape2DNoBlending
        case shape2DAlphaBlending
        case shape2DAdditiveBlending
        case shape2DPremultipliedBlending
        
        case shapeNodeIndexed2DNoBlending
        case shapeNodeIndexed2DAlphaBlending
        case shapeNodeIndexed2DAdditiveBlending
        case shapeNodeIndexed2DPremultipliedBlending
        
        case shapeNodeColoredIndexed2DNoBlending
        case shapeNodeColoredIndexed2DAlphaBlending
        case shapeNodeColoredIndexed2DAdditiveBlending
        case shapeNodeColoredIndexed2DPremultipliedBlending
        
        case sprite2DNoBlending
        case sprite2DAlphaBlending
        case sprite2DAdditiveBlending
        case sprite2DPremultipliedBlending
        
        case spriteNodeIndexed2DNoBlending
        case spriteNodeIndexed2DAlphaBlending
        case spriteNodeIndexed2DAdditiveBlending
        case spriteNodeIndexed2DPremultipliedBlending
        
        case spriteNodeColoredIndexed2DNoBlending
        case spriteNodeColoredIndexed2DAlphaBlending
        case spriteNodeColoredIndexed2DAdditiveBlending
        case spriteNodeColoredIndexed2DPremultipliedBlending
    }
    
    enum SamplerState {
        case invalid
        
        case linearClamp
        case linearRepeat
    }
    
    let delegate: GraphicsDelegate
    private(set) var width: Float
    private(set) var height: Float
    
    init(delegate: GraphicsDelegate, width: Float, height: Float) {
        print("Create Graphics With Size: \(width) x \(height)")
        self.delegate = delegate
        self.width = width
        self.height = height
    }
    
    private(set) var pipelineState = PipelineState.invalid
    private(set) var samplerState = SamplerState.invalid
    
    lazy var metalViewController: MetalViewController = {
        MetalViewController(graphics: self, metalView: metalView)
    }()
    
    lazy var metalView: MetalView = {
        MetalView(delegate: delegate,
                  graphics: self,
                  width: CGFloat(width),
                  height: CGFloat(height))
    }()
    
    lazy var engine: MetalEngine = {
        metalView.engine
    }()
    
    lazy var pipeline: MetalPipeline = {
        metalView.pipeline
    }()

    lazy var device: MTLDevice = {
        engine.device
    }()
    
    func update(width: Float, height: Float) {
        if (width != self.width) || (height != self.height) {
            self.width = width
            self.height = height
        }
    }
    
    lazy var window: UIWindow = {
        guard let scene = UIApplication.shared.connectedScenes.first else {
            return UIWindow()
        }
        guard let windowScene = scene as? UIWindowScene else {
            return UIWindow()
        }
        guard let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }()
    
    lazy var safeAreaTop: Float = {
        Float(window.safeAreaInsets.top)
    }()
    
    lazy var safeAreaBottom: Float = {
        Float(window.safeAreaInsets.bottom)
    }()
    
    lazy var safeAreaLeft: Float = {
        Float(window.safeAreaInsets.left)
    }()
    
    lazy var safeAreaRight: Float = {
        Float(window.safeAreaInsets.right)
    }()
    
    func loadTexture(url: URL) -> MTLTexture? {
        let loader = MTKTextureLoader(device: engine.device)
        return try? loader.newTexture(URL: url, options: nil)
    }
    
    func loadTexture(fileName: String) -> MTLTexture? {
        if let bundleResourcePath = Bundle.main.resourcePath {
            let filePath = bundleResourcePath + "/" + fileName
            let fileURL = URL(filePath: filePath)
            return loadTexture(url: fileURL)
        }
        return nil
    }
    
    func buffer<Element>(array: Array<Element>) -> MTLBuffer! {
        let length = MemoryLayout<Element>.size * array.count
        return device.makeBuffer(bytes: array,
                                 length: length)
    }

    func write<Element>(buffer: MTLBuffer, array: Array<Element>) {
        let length = MemoryLayout<Element>.size * array.count
        buffer.contents().copyMemory(from: array,
                                     byteCount: length)
    }

    func buffer(uniform: Uniforms) -> MTLBuffer! {
        return device.makeBuffer(bytes: uniform.data,
                                 length: uniform.size,
                                 options: [])
    }

    func write(buffer: MTLBuffer, uniform: Uniforms) {
        buffer.contents().copyMemory(from: uniform.data, byteCount: uniform.size)
    }
    
    func set(pipelineState: PipelineState, renderEncoder: MTLRenderCommandEncoder) {
        self.pipelineState = pipelineState
        switch pipelineState {
        case .invalid:
            break
        case .shape2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape2DNoBlending)
        case .shape2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape2DAlphaBlending)
        case .shape2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape2DAdditiveBlending)
        case .shape2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShape2DPremultipliedBlending)
            
        case .shapeNodeIndexed2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed2DNoBlending)
        case .shapeNodeIndexed2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed2DAlphaBlending)
        case .shapeNodeIndexed2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed2DAdditiveBlending)
        case .shapeNodeIndexed2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeIndexed2DPremultipliedBlending)
            
        case .shapeNodeColoredIndexed2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed2DNoBlending)
        case .shapeNodeColoredIndexed2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed2DAlphaBlending)
        case .shapeNodeColoredIndexed2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed2DAdditiveBlending)
        case .shapeNodeColoredIndexed2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateShapeNodeColoredIndexed2DPremultipliedBlending)
            
        case .sprite2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DNoBlending)
        case .sprite2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DAlphaBlending)
        case .sprite2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DAdditiveBlending)
        case .sprite2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSprite2DPremultipliedBlending)
            
        case .spriteNodeIndexed2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed2DNoBlending)
        case .spriteNodeIndexed2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed2DAlphaBlending)
        case .spriteNodeIndexed2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed2DAdditiveBlending)
        case .spriteNodeIndexed2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeIndexed2DPremultipliedBlending)
            
        case .spriteNodeColoredIndexed2DNoBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DNoBlending)
        case .spriteNodeColoredIndexed2DAlphaBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DAlphaBlending)
        case .spriteNodeColoredIndexed2DAdditiveBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DAdditiveBlending)
        case .spriteNodeColoredIndexed2DPremultipliedBlending:
            renderEncoder.setRenderPipelineState(pipeline.pipelineStateSpriteNodeColoredIndexed2DPremultipliedBlending)
            
        }
    }
    
    func set(samplerState: SamplerState, renderEncoder: MTLRenderCommandEncoder) {
        
        self.samplerState = samplerState
        
        var metalSamplerState: MTLSamplerState!
        switch samplerState {
        case .linearClamp:
            metalSamplerState = engine.samplerStateLinearClamp
        case .linearRepeat:
            metalSamplerState = engine.samplerStateLinearRepeat
        default:
            break
        }
        
        switch pipelineState {
        case .sprite2DNoBlending,
                .sprite2DAlphaBlending,
                .sprite2DAdditiveBlending,
                .sprite2DPremultipliedBlending:
            renderEncoder.setFragmentSamplerState(metalSamplerState, index: MetalPipeline.spriteFragmentIndexSampler)
        case .spriteNodeIndexed2DNoBlending,
                .spriteNodeIndexed2DAlphaBlending,
                .spriteNodeIndexed2DAdditiveBlending,
                .spriteNodeIndexed2DPremultipliedBlending,
                .spriteNodeColoredIndexed2DNoBlending,
                .spriteNodeColoredIndexed2DAlphaBlending,
                .spriteNodeColoredIndexed2DAdditiveBlending,
                .spriteNodeColoredIndexed2DPremultipliedBlending:
            renderEncoder.setFragmentSamplerState(metalSamplerState, index: MetalPipeline.spriteNodeIndexedFragmentIndexSampler)
            
        default:
            break
        }
    }
    
    func setVertexUniformsBuffer(_ uniformsBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let uniformsBuffer = uniformsBuffer {
            switch pipelineState {
            case .shape2DNoBlending,
                    .shape2DAlphaBlending,
                    .shape2DAdditiveBlending,
                    .shape2DPremultipliedBlending:
                renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.shapeVertexIndexUniforms)
                
            case .shapeNodeIndexed2DNoBlending,
                    .shapeNodeIndexed2DAlphaBlending,
                    .shapeNodeIndexed2DAdditiveBlending,
                    .shapeNodeIndexed2DPremultipliedBlending,
                    .shapeNodeColoredIndexed2DNoBlending,
                    .shapeNodeColoredIndexed2DAlphaBlending,
                    .shapeNodeColoredIndexed2DAdditiveBlending,
                    .shapeNodeColoredIndexed2DPremultipliedBlending:
                
                renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.shapeNodeIndexedVertexIndexUniforms)
                
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending:
                renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteVertexIndexUniforms)
                
            case .spriteNodeIndexed2DNoBlending,
                    .spriteNodeIndexed2DAlphaBlending,
                    .spriteNodeIndexed2DAdditiveBlending,
                    .spriteNodeIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DNoBlending,
                    .spriteNodeColoredIndexed2DAlphaBlending,
                    .spriteNodeColoredIndexed2DAdditiveBlending,
                    .spriteNodeColoredIndexed2DPremultipliedBlending:
                renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteNodeIndexedVertexIndexUniforms)
                
            default:
                break
            }
        }
    }

    func setFragmentUniformsBuffer(_ uniformsBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let uniformsBuffer = uniformsBuffer {
            switch pipelineState {
            case .shape2DNoBlending,
                    .shape2DAlphaBlending,
                    .shape2DAdditiveBlending,
                    .shape2DPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.shapeFragmentIndexUniforms)
                
            case .shapeNodeIndexed2DNoBlending,
                    .shapeNodeIndexed2DAlphaBlending,
                    .shapeNodeIndexed2DAdditiveBlending,
                    .shapeNodeIndexed2DPremultipliedBlending,
                    .shapeNodeColoredIndexed2DNoBlending,
                    .shapeNodeColoredIndexed2DAlphaBlending,
                    .shapeNodeColoredIndexed2DAdditiveBlending,
                    .shapeNodeColoredIndexed2DPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.shapeNodeIndexedFragmentIndexUniforms)
                
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteFragmentIndexUniforms)
            
            case .spriteNodeIndexed2DNoBlending,
                    .spriteNodeIndexed2DAlphaBlending,
                    .spriteNodeIndexed2DAdditiveBlending,
                    .spriteNodeIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DNoBlending,
                    .spriteNodeColoredIndexed2DAlphaBlending,
                    .spriteNodeColoredIndexed2DAdditiveBlending,
                    .spriteNodeColoredIndexed2DPremultipliedBlending:
                renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: MetalPipeline.spriteNodeIndexedFragmentIndexUniforms)
                
            default:
                break
            }
        }
    }
    
    func setVertexDataBuffer(_ dataBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let dataBuffer = dataBuffer {
            switch pipelineState {
            case .shapeNodeIndexed2DNoBlending,
                    .shapeNodeIndexed2DAlphaBlending,
                    .shapeNodeIndexed2DAdditiveBlending,
                    .shapeNodeIndexed2DPremultipliedBlending,
                    .shapeNodeColoredIndexed2DNoBlending,
                    .shapeNodeColoredIndexed2DAlphaBlending,
                    .shapeNodeColoredIndexed2DAdditiveBlending,
                    .shapeNodeColoredIndexed2DPremultipliedBlending:
                renderEncoder.setVertexBuffer(dataBuffer, offset: 0, index: MetalPipeline.shapeNodeIndexedVertexIndexData)
                
            
            case .spriteNodeIndexed2DNoBlending,
                    .spriteNodeIndexed2DAlphaBlending,
                    .spriteNodeIndexed2DAdditiveBlending,
                    .spriteNodeIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DNoBlending,
                    .spriteNodeColoredIndexed2DAlphaBlending,
                    .spriteNodeColoredIndexed2DAdditiveBlending,
                    .spriteNodeColoredIndexed2DPremultipliedBlending:
                renderEncoder.setVertexBuffer(dataBuffer, offset: 0, index: MetalPipeline.spriteNodeIndexedVertexIndexData)
                
            default:
                break
            }
        }
    }
    
    func setVertexPositionsBuffer(_ positionsBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let positionsBuffer = positionsBuffer {
            switch pipelineState {
            case .shape2DNoBlending,
                    .shape2DAlphaBlending,
                    .shape2DAdditiveBlending,
                    .shape2DPremultipliedBlending:
                renderEncoder.setVertexBuffer(positionsBuffer, offset: 0, index: MetalPipeline.shapeVertexIndexPosition)
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending:
                renderEncoder.setVertexBuffer(positionsBuffer, offset: 0, index: MetalPipeline.spriteVertexIndexPosition)
            default:
                break
            }
        }
    }
    
    func setVertexTextureCoordsBuffer(_ textureCoordsBuffer: MTLBuffer?, renderEncoder: MTLRenderCommandEncoder) {
        if let textureCoordsBuffer = textureCoordsBuffer {
            switch pipelineState {
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending:
                renderEncoder.setVertexBuffer(textureCoordsBuffer, offset: 0, index: MetalPipeline.spriteVertexIndexTextureCoord)
            default:
                break
            }
        }
    }

    func setFragmentTexture(_ texture: MTLTexture?, renderEncoder: MTLRenderCommandEncoder) {
        if let texture = texture {
            switch pipelineState {
            case .sprite2DNoBlending,
                    .sprite2DAlphaBlending,
                    .sprite2DAdditiveBlending,
                    .sprite2DPremultipliedBlending:
                renderEncoder.setFragmentTexture(texture, index: MetalPipeline.spriteFragmentIndexTexture)
            case .spriteNodeIndexed2DNoBlending,
                    .spriteNodeIndexed2DAlphaBlending,
                    .spriteNodeIndexed2DAdditiveBlending,
                    .spriteNodeIndexed2DPremultipliedBlending,
                    .spriteNodeColoredIndexed2DNoBlending,
                    .spriteNodeColoredIndexed2DAlphaBlending,
                    .spriteNodeColoredIndexed2DAdditiveBlending,
                    .spriteNodeColoredIndexed2DPremultipliedBlending:
                renderEncoder.setFragmentTexture(texture, index: MetalPipeline.spriteNodeIndexedFragmentIndexTexture)
            default:
                break
            }
        }
    }
}
