//
//  UIDevice.swift
//
//  Created by Koichiro Tanaka on 2021/09/24.
//  Copyright © 2019-2021 Kyushu Sangyo University. All rights reserved.
//

import UIKit

extension UIDevice {
    
    class var modelName: String {
        //    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity

#if os(iOS)
            switch identifier {
                
            case "iPod1,1":                                 return "iPod touch (1st generation)"
            case "iPod2,1":                                 return "iPod touch (2nd generation)"
            case "iPod3,1":                                 return "iPod touch (3rd generation)"
            case "iPod4,1":                                 return "iPod touch (4th generation)"
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
                
            case "iPhone1,1":   return "iPhone"
            case "iPhone1,2":   return "iPhone 3G"
            case "iPhone2,1":   return "iPhone 3GS"
            case "iPhone3,1":   return "iPhone 4"
            case "iPhone3,2":   return "iPhone 4 (GSM)"
            case "iPhone3,3":   return "iPhone 4 (CDMA)"
            case "iPhone4,1":   return "iPhone 4s"
            case "iPhone5,1":   return "iPhone 5 (GSM)"
            case "iPhone5,2":   return "iPhone 5 (Global)"
            case "iPhone5,3":   return "iPhone 5c (GSM)"
            case "iPhone5,4":   return "iPhone 5c (Global)"
            case "iPhone6,1":   return "iPhone 5s (GSM)"
            case "iPhone6,2":   return "iPhone 5s (Global)"
            case "iPhone7,2":   return "iPhone 6"
            case "iPhone7,1":   return "iPhone 6 Plus"
            case "iPhone8,1":   return "iPhone 6s"
            case "iPhone8,2":   return "iPhone 6s Plus"
            case "iPhone8,4":   return "iPhone SE (1st generation)"
            case "iPhone9,1":   return "iPhone 7 (CDMA)"
            case "iPhone9,3":   return "iPhone 7 (GSM)"
            case "iPhone9,2":   return "iPhone 7 Plus (CDMA)"
            case "iPhone9,4":   return "iPhone 7 Plus (GSM)"
            case "iPhone10,1":  return "iPhone 8 (GSM)"
            case "iPhone10,4":  return "iPhone 8 (Global)"
            case "iPhone10,2":  return "iPhone 8 Plus (GSM)"
            case "iPhone10,5":  return "iPhone 8 Plus (Global)"
            case "iPhone10,3":  return "iPhone X (Global)"
            case "iPhone10,6":  return "iPhone X (GSM)"
            case "iPhone11,2":  return "iPhone XS"
            case "iPhone11,4":  return "iPhone XS Max"
            case "iPhone11,6":  return "iPhone XS Max (Global)"
            case "iPhone11,8":  return "iPhone XR"
            case "iPhone12,1":  return "iPhone 11"
            case "iPhone12,3":  return "iPhone 11 Pro"
            case "iPhone12,5":  return "iPhone 11 Pro Max"
            case "iPhone12,8":  return "iPhone SE (2nd generation)"
            case "iPhone13,1":  return "iPhone 12 mini"
            case "iPhone13,2":  return "iPhone 12"
            case "iPhone13,3":  return "iPhone 12 Pro"
            case "iPhone13,4":  return "iPhone 12 Pro Max"
            case "iPhone14,2":  return "iPhone 13 Pro"
            case "iPhone14,3":  return "iPhone 13 Pro Max"
            case "iPhone14,4":  return "iPhone 13 mini"
            case "iPhone14,5":  return "iPhone 13"
            case "iPhone14,6":  return "iPhone SE (3rd generation)"
            case "iPhone14,7":  return "iPhone 14"
            case "iPhone14,8":  return "iPhone 14 Plus"
            case "iPhone15,2":  return "iPhone 14 Pro"
            case "iPhone15,3":  return "iPhone 14 Pro Max"
            
            case "iPad1,1":     return "iPad 1 WiFi"
            case "iPad1,2":     return "iPad 1 3G"
            case "iPad2,1":     return "iPad 2 WiFi"
            case "iPad2,2":     return "iPad 2 WiFi+GSM"
            case "iPad2,3":     return "iPad 2 WiFi+CDMA"
            case "iPad2,4":     return "iPad 2 Revision"
            case "iPad3,1":     return "iPad (3rd generation) WiFi"
            case "iPad3,2":     return "iPad (3rd generation) WiFi+CDMA" // なぜ逆？
            case "iPad3,3":     return "iPad (3rd generation) WiFi+GSM"
            case "iPad3,4":     return "iPad (4th generation) WiFi"
            case "iPad3,5":     return "iPad (4th generation) WiFi+LTE+GSM"
            case "iPad3,6":     return "iPad (4th generation) WiFi+LTE+CDMA"
            case "iPad6,11":    return "iPad (5th generation) WiFi"
            case "iPad6,12":    return "iPad (5th generation) WiFi+Cellular"
            case "iPad7,5":     return "iPad (6th generation) WiFi"
            case "iPad7,6":     return "iPad (6th generation) WiFi+Cellular"
            case "iPad7,11":    return "iPad (7th generation) WiFi"
            case "iPad7,12":    return "iPad (7th generation) WiFi+Cellular"
            case "iPad11,6":    return "iPad (8th generation) WiFi"
            case "iPad11,7":    return "iPad (8th generation) WiFi+Cellular"
            case "iPad12,1":    return "iPad (9th generation) WiFi"
            case "iPad12,2":    return "iPad (9th generation) WiFi+Cellular"
                
            case "iPad4,1":     return "iPad Air WiFi"
            case "iPad4,2":     return "iPad Air WiFi+Cellular"
            case "iPad4,3":     return "iPad Air WiFi+Cellular (China)"
            case "iPad5,3":     return "iPad Air 2 WiFi"
            case "iPad5,4":     return "iPad Air 2 WiFi+Cellular"
            case "iPad11,3":    return "iPad Air (3rd generation) WiFi"
            case "iPad11,4":    return "iPad Air (3rd generation) WiFi+Cellular"
            case "iPad13,1":    return "iPad Air (4th generation) WiFi"
            case "iPad13,2":    return "iPad Air (4th generation) WiFi+Cellular"
            case "iPad13,16":   return "iPad Air (5th generation) WiFi"
            case "iPad13,17":   return "iPad Air (5th generation) WiFi+Cellular"
             
            case "iPad2,5":     return "iPad mini WiFi"
            case "iPad2,6":     return "iPad mini WiFi+LTE+GSM"
            case "iPad2,7":     return "iPad mini WiFi+LTE+CDMA"
            case "iPad4,4":     return "iPad mini 2 WiFi"
            case "iPad4,5":     return "iPad mini 2 WiFi+GSM+CDMA"
            case "iPad4,6":     return "iPad mini 2 WiFi+Cellular (China)"
            case "iPad4,7":     return "iPad mini 3 WiFi"
            case "iPad4,8":     return "iPad mini 3 WiFi+GSM+CDMA"
            case "iPad4,9":     return "iPad mini 3 WiFi+Cellular (China)"
            case "iPad5,1":     return "iPad mini 4 WiFi"
            case "iPad5,2":     return "iPad mini 4 WiFi+Cellular"
            case "iPad11,1":    return "iPad mini (5th generation) WiFi"
            case "iPad11,2":    return "iPad mini (5th generation) WiFi+Cellular"
            case "iPad14,1":    return "iPad mini (6th generation) WiFi"
            case "iPad14,2":    return "iPad mini (6th generation) WiFi+Cellular"
                
            case "iPad6,3":     return "iPad Pro (9.7-inch) WiFi"
            case "iPad6,4":     return "iPad Pro (9.7-inch) WiFi+Cellular"
            case "iPad7,3":     return "iPad Pro (10.5-inch) WiFi"
            case "iPad7,4":     return "iPad Pro (10.5-inch) WiFi+Cellular"
            case "iPad8,1":     return "iPad Pro (11-inch) (1st generation) WiFi"
            case "iPad8,2":     return "iPad Pro (11-inch) (1st generation) WiFi (1TB)"
            case "iPad8,3":     return "iPad Pro (11-inch) (1st generation) WiFi+Cellular"
            case "iPad8,4":     return "iPad Pro (11-inch) (1st generation) WiFi+Cellular (1TB)"
            case "iPad8,9":     return "iPad Pro (11-inch) (2nd generation) WiFi"
            case "iPad8,10":    return "iPad Pro (11-inch) (2nd generation) WiFi+Cellular"
            case "iPad13,4":    return "iPad Pro (11-inch) (3rd generation) WiFi"
            case "iPad13,5":    return "iPad Pro (11-inch) (3rd generation) WiFi+Cellular (US)"
            case "iPad13,6":    return "iPad Pro (11-inch) (3rd generation) WiFi+Cellular (Global)"
            case "iPad13,7":    return "iPad Pro (11-inch) (3rd generation) WiFi+Cellular (China)"
                
            case "iPad6,7":     return "iPad Pro (12.9-inch) (1st generation) WiFi"
            case "iPad6,8":     return "iPad Pro (12.9-inch) (1st generation) WiFi+Cellular"
            case "iPad7,1":     return "iPad Pro (12.9-inch) (2nd generation) WiFi"
            case "iPad7,2":     return "iPad Pro (12.9-inch) (2nd generation) WiFi+Cellular"
            case "iPad8,5":     return "iPad Pro (12.9-inch) (3rd generation) WiFi"
            case "iPad8,6":     return "iPad Pro (12.9-inch) (3rd generation) WiFi (1TB)"
            case "iPad8,7":     return "iPad Pro (12.9-inch) (3rd generation) WiFi+Cellular"
            case "iPad8,8":     return "iPad Pro (12.9-inch) (3rd generation) WiFi+Cellular (1TB)"
            case "iPad8,11":    return "iPad Pro (12.9-inch) (4th generation) WiFi"
            case "iPad8,12":    return "iPad Pro (12.9-inch) (4th generation) WiFi+Cellular"
            case "iPad13,8":    return "iPad Pro (12.9-inch) (5th generation) WiFi"
            case "iPad13,9":    return "iPad Pro (12.9-inch) (5th generation) WiFi+Cellular (US)"
            case "iPad13,10":   return "iPad Pro (12.9-inch) (5th generation) WiFi+Cellular (Global)"
            case "iPad13,11":   return "iPad Pro (12.9-inch) (5th generation) WiFi+Cellular (China)"
                
            case "AudioAccessory1,1":   return "HomePod"
            case "i386", "x86_64":  return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:            return identifier
            }
            
#elseif os(tvOS)
            
            switch identifier {
            case "AppleTV5,3":  return "Apple TV HD"
            case "AppleTV6,2":  return "Apple TV 4K (1st generation)"
            case "AppleTV11,1":  return "Apple TV 4K (2nd generation)"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default:            return identifier
            }
            
#endif
        }
        
        return mapToDevice(identifier: identifier)
    }
    
    class func interfaceOrientationLandscape(_ view: UIView)->Bool{
        
        let ifOrientation = { () -> UIInterfaceOrientation in
            return view.window?.windowScene?.interfaceOrientation ?? .unknown
        }
        
        switch ifOrientation() {
        case .unknown:
            print("unknown")
            return false
        case .portrait:
            print("portrait")
            return false
        case .portraitUpsideDown:
            print("portraitUpsideDown")
            return false
        case .landscapeLeft:
            print("landscapeLeft")
            return true
        case .landscapeRight:
            print("landscapeRight")
            return true
        @unknown default:
            return false
        }
    }
}
