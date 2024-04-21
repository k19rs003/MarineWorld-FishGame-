//
//  SKSpriteNode+Gif.swift
//
//  Created by Timothy Sears on 1/21/18.
//  Copyright © 2018 Timothy Sears. All rights reserved.
//
import ImageIO
import SpriteKit
// SKSpriteNodeの拡張extension
extension SKSpriteNode {
    // MARK: - Helper Types
    private enum Constant {
        static let defaultDelay = 0.1
        static let millisecondDelay = 1000.0
    }
    // MARK: - Converter
    // gifのdataをSKSpriteNodeに
    class func sprite(from gifData: Data) -> SKSpriteNode? { //gif
        guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        var textures = [SKTexture]()
        var duration: Double = 0.0
        for i in 0 ..< count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let texture = SKTexture(cgImage: image)
                textures.append(texture)
            }
            let delaySeconds = delay(at: Int(i), source: source)
            duration += delaySeconds * Constant.millisecondDelay
        }
        guard
            !textures.isEmpty,
            let first = textures.first
        else { return nil }
        let sprite = SKSpriteNode(texture: first)
        let delayInSeconds = duration / Constant.millisecondDelay
        let timePerFrame = TimeInterval(delayInSeconds / Double(textures.count))
        let action = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        sprite.run(SKAction.repeatForever(action))
        return sprite
    }
    /// Gif delay calculation borrowed from: https://github.com/bahlo/SwiftGif
    private class func delay(at index: Int, source: CGImageSource!) -> Double {
        let delay = Constant.defaultDelay
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(
            cfProperties,
            Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false
        {
            return delay
        }
        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(
                gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(
                CFDictionaryGetValue(
                    gifProperties,
                    Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()
                ),
                to: AnyObject.self
            )
        }
        return delayObject as? Double ?? 0.0
    }
}
