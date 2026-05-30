import CoreImage
import UIKit

/// 5軸チューニング値から Core Image フィルターパラメータへ合成する（端末内処理のみ）
enum PhotoFilterProcessor {
    struct TuningIndices {
        var era: Int
        var season: Int
        var timeOfDay: Int
        var weather: Int
        var texture: Int
    }

    struct Parameters {
        var brightness: Float = 0
        var contrast: Float = 1
        var saturation: Float = 1
        var warmth: Float = 0
        var vignette: Float = 0
        var grain: Float = 0
        var greenShift: Float = 0
    }

    static func parameters(for indices: TuningIndices) -> Parameters {
        var p = Parameters()

        switch indices.era {
        case 0: p.saturation -= 0.18; p.warmth += 0.22; p.vignette += 0.28; p.grain += 0.12
        case 1: p.brightness += 0.06; p.greenShift += 0.08; p.contrast -= 0.08; p.grain += 0.18
        case 2: p.saturation -= 0.05; p.contrast -= 0.04
        case 3: p.saturation += 0.08; p.warmth -= 0.06
        default: break
        }

        switch indices.season {
        case 0: p.warmth += 0.08; p.brightness += 0.04; p.saturation += 0.04
        case 1: p.brightness += 0.08; p.greenShift += 0.12; p.saturation += 0.06
        case 2: p.warmth += 0.14; p.saturation -= 0.10
        case 3: p.warmth -= 0.10; p.brightness -= 0.06; p.saturation -= 0.06
        default: break
        }

        switch indices.timeOfDay {
        case 0: p.brightness += 0.10; p.warmth += 0.06
        case 1: p.brightness += 0.04
        case 2: p.brightness -= 0.06; p.warmth += 0.18; p.vignette += 0.22; p.saturation -= 0.06
        case 3: p.brightness -= 0.18; p.warmth += 0.10; p.vignette += 0.30; p.grain += 0.10
        default: break
        }

        switch indices.weather {
        case 0: p.brightness += 0.06; p.contrast += 0.10; p.saturation += 0.06
        case 1: p.saturation -= 0.12; p.contrast -= 0.10; p.brightness -= 0.02
        case 2: p.greenShift += 0.14; p.brightness -= 0.10; p.contrast -= 0.14; p.saturation -= 0.14
        case 3: p.saturation -= 0.16; p.contrast -= 0.08; p.greenShift += 0.06; p.brightness -= 0.04
        default: break
        }

        switch indices.texture {
        case 0: p.grain += 0.28; p.saturation -= 0.10; p.contrast -= 0.06
        case 1: p.saturation -= 0.28; p.contrast -= 0.08
        case 2: p.greenShift += 0.22; p.saturation -= 0.08
        case 3: p.brightness -= 0.14; p.warmth += 0.12; p.greenShift += 0.10; p.grain += 0.20
        case 4: p.saturation -= 0.22; p.contrast -= 0.12; p.vignette += 0.14; p.brightness -= 0.02
        default: break
        }

        p.contrast = min(max(p.contrast, 0.55), 1.35)
        p.saturation = min(max(p.saturation, 0.25), 1.35)
        p.brightness = min(max(p.brightness, -0.35), 0.25)
        p.vignette = min(max(p.vignette, 0), 0.85)
        p.grain = min(max(p.grain, 0), 0.55)
        return p
    }

    static func apply(to image: UIImage, indices: TuningIndices) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        let params = parameters(for: indices)
        let context = CIContext(options: [.useSoftwareRenderer: false])
        var output = ciImage

        if let filtered = CIFilter(name: "CIColorControls") {
            filtered.setValue(output, forKey: kCIInputImageKey)
            filtered.setValue(params.brightness, forKey: kCIInputBrightnessKey)
            filtered.setValue(params.contrast, forKey: kCIInputContrastKey)
            filtered.setValue(params.saturation, forKey: kCIInputSaturationKey)
            if let result = filtered.outputImage { output = result }
        }

        if abs(params.warmth) > 0.01, let temp = CIFilter(name: "CITemperatureAndTint") {
            let neutral = CIVector(x: 6500, y: 0)
            let target = CIVector(x: 6500 + CGFloat(params.warmth * 1800), y: CGFloat(params.greenShift * 40))
            temp.setValue(output, forKey: kCIInputImageKey)
            temp.setValue(neutral, forKey: "inputNeutral")
            temp.setValue(target, forKey: "inputTargetNeutral")
            if let result = temp.outputImage { output = result }
        } else if abs(params.greenShift) > 0.01, let hue = CIFilter(name: "CIHueAdjust") {
            hue.setValue(output, forKey: kCIInputImageKey)
            hue.setValue(params.greenShift * 0.35, forKey: kCIInputAngleKey)
            if let result = hue.outputImage { output = result }
        }

        if params.vignette > 0.01, let vignette = CIFilter(name: "CIVignette") {
            vignette.setValue(output, forKey: kCIInputImageKey)
            vignette.setValue(params.vignette * 2.2, forKey: kCIInputIntensityKey)
            vignette.setValue(1.4, forKey: kCIInputRadiusKey)
            if let result = vignette.outputImage { output = result }
        }

        if params.grain > 0.01, let noise = CIFilter(name: "CIRandomGenerator")?.outputImage {
            let cropped = noise.cropped(to: output.extent)
            if let matrix = CIFilter(name: "CIColorMatrix") {
                matrix.setValue(cropped, forKey: kCIInputImageKey)
                let amount = CGFloat(params.grain * 0.18)
                matrix.setValue(CIVector(x: amount, y: 0, z: 0, w: 0), forKey: "inputRVector")
                matrix.setValue(CIVector(x: 0, y: amount, z: 0, w: 0), forKey: "inputGVector")
                matrix.setValue(CIVector(x: 0, y: 0, z: amount, w: 0), forKey: "inputBVector")
                matrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
                matrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
                if let grainLayer = matrix.outputImage,
                   let blend = CIFilter(name: "CIOverlayBlendMode") {
                    blend.setValue(grainLayer, forKey: kCIInputImageKey)
                    blend.setValue(output, forKey: kCIInputBackgroundImageKey)
                    if let result = blend.outputImage { output = result }
                }
            }
        }

        let extent = ciImage.extent
        guard let cgImage = context.createCGImage(output, from: extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    static func previewScale(for image: UIImage, maxDimension: CGFloat = 900) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxDimension else { return image }
        let scale = maxDimension / longest
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
