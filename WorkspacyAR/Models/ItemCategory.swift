//
//  ItemCategory.swift
//  WorkspacyAR
//
//  Created by Mochammad Athar Humam Ghazanfar on 20/07/26.
//


import Foundation

public enum ItemCategory: String, CaseIterable, Identifiable {
    case monitor = "Monitor"
    case laptop = "Laptop"
    case keyboard = "Keyboard"
    case mouse = "Mouse"
    case deskmat = "Deskmat"
    case accessories = "Accessories"
    
    public var id: String { self.rawValue }
    
    public var sfSymbol: String {
        switch self {
        case .monitor: return "desktopcomputer"
        case .laptop: return "laptopcomputer"
        case .keyboard: return "keyboard"
        case .mouse: return "mouse"
        case .deskmat, .accessories: return "rectangle.3.offgrid.fill"
        }
    }
}

public enum PlaceableObjectType: String, CaseIterable, Identifiable {
    case macbookAir13 = "macbook_air_13"
    case macbookAir13new = "newmac13inch"
    case macbookPro14 = "macbook_pro_14"
    
    case macbookAir15 = "macbook_air_15"
    case macbook16 = "macbook_16"
    case iMac24 = "imac_24"
    case studioDisplay27 = "studio_display_27"
    case monitor32 = "monitor_32"
    case appleMouse = "apple_mouse"
    case deskmat = "deskmat_30x70"
    case magicKeyboard = "magic_keyboard"
    case monitorRaiser = "monitor_raiser_70x22_5x8"
    
    public var id: String { self.rawValue }
    
    public var displayName: String {
        switch self {
        case .macbookAir13: return "13\" MacBook Air"
        case .macbookPro14: return "14\" MacBook Pro (M5)"
        case .macbookAir15: return "15\" MacBook Air"
        case .macbook16: return "16\" MacBook Pro"
        case .iMac24: return "24\" iMac"
        case .studioDisplay27: return "27\" Studio Display"
        case .monitor32: return "32\" Monitor"
        case .appleMouse: return "Apple Mouse"
        case .deskmat: return "Desk Mat"
        case .magicKeyboard: return "Magic Keyboard"
        case .monitorRaiser: return "Monitor Raiser"
        default: return "unknown"
        }
    }
    
    public var category: ItemCategory {
        switch self {
<<<<<<< HEAD
        case .macbookAir13, .macbookPro14, .macbookAir15, .macbook16:
=======
        case .macbookAir13, .macbookPro14, .macbookAir15, .macbook16, .macbook16CenterNew, .macbookAir13new:
>>>>>>> d01692b (F/30 object anchor handling (#31))
            return .laptop
        case .iMac24, .studioDisplay27, .monitor32:
            return .monitor
        case .appleMouse:
            return .mouse
        case .magicKeyboard:
            return .keyboard
        case .deskmat:
            return .deskmat
        case .monitorRaiser:
            return .accessories
        }
    }
    
    public var dimensionsDescription: String {
        switch self {
        case .macbookAir13: return "30.4 x 21.5 x 1.1 cm"
        case .macbookPro14: return "31.3 x 22.1 x 1.6 cm"
        case .macbookAir15: return "34.0 x 23.8 x 1.2 cm"
        case .macbook16: return "35.6 x 24.8 x 1.7 cm"
        case .iMac24: return "54.7 x 46.1 x 14.7 cm"
        case .studioDisplay27: return "62.3 x 47.8 x 16.8 cm"
        case .monitor32: return "71.4 x 42.4 x 20 cm"
        case .appleMouse: return "11.3 x 5.7 x 3.4 cm"
        case .deskmat: return "70 x 30 cm"
        case .magicKeyboard: return "27.9 x 11.5 x 1.1 cm"
        case .monitorRaiser: return "70 x 22.5 x 8 cm"
        default: return "unknown"
        }
    }
    
    public var sfSymbol: String {
        switch self {
        case .macbookAir13, .macbookPro14, .macbookAir15, .macbook16:
            return "laptopcomputer"
        case .iMac24: return "desktopcomputer"
        case .studioDisplay27, .monitor32: return "tv"
        case .appleMouse: return "computermouse"
        case .deskmat: return "rectangle.3.offgrid.fill"
        case .magicKeyboard: return "keyboard"
        case .monitorRaiser: return "square.stack.3d.up"
        default: return "unknown"
        }
    }
    
    public var ergonomicTip: String {
        switch self {
        case .macbookAir13, .macbookAir15:
            return "Use a laptop riser along with an external keyboard and mouse to prevent neck strain."
        case .macbookPro14, .macbook16:
            return "Use a laptop riser along with an external keyboard and mouse to prevent neck strain."
        case .iMac24:
            return "The top of the screen should be at or slightly below eye level, at an arm's distance."
        case .studioDisplay27:
            return "Position the display so the top third of the screen aligns with your eye level."
        case .monitor32:
            return "Position the monitor so the top third of the screen aligns with your eye level."
        case .appleMouse:
            return "Keep the mouse close to the keyboard and avoid resting your wrist on hard desk edges."
        case .deskmat:
            return "A larger desk mat gives your mouse and keyboard consistent glide and reduces desk clutter."
        case .magicKeyboard:
            return "Keep the keyboard flat or slightly tilted away from you to keep your wrists in a neutral position."
        case .monitorRaiser:
            return "Raise your monitor so the top of the screen sits at or slightly below eye level."
        default: return "unknown"
        }
    }
    
    public var assetName: String {
        switch self {
        case .macbookAir13: return "13inch_MacbookAirSpaceGray"
        case .macbookPro14: return "14inch_MacBookProM5"
        case .macbookAir15: return "15inch_MacbookAir"
        case .macbook16: return "16inch_Macbook"
        case .iMac24: return "24inch_iMac"
        case .studioDisplay27: return "27inch_StudioDisplay"
        case .monitor32: return "32inch_Monitor"
        case .appleMouse: return "AppleMouse"
        case .deskmat: return "deskmat30x70"
        case .magicKeyboard: return "MagicKeyboardMac"
        case .monitorRaiser: return "MonitorRaiser_70x22,5x8"
        case .macbookAir13new: return "newmac13inch"
        }
    }
    
<<<<<<< HEAD
    public var scaleCorrection: SIMD3<Float> {
        switch self {
        case .macbookAir13:
            // Target: 30.4 x 21.5 x 1.1 | Actual: 30.212 x 0.621 x 21.221
            return SIMD3<Float>(1.006, 34.62, 0.0518)
        case .macbookPro14:
            // Target: 31.3 x 22.1 x 1.6 | Actual: 31.173 x 21.784 x 1.042
            return SIMD3<Float>(1.004, 1.014, 1.535)
        case .macbookAir15:
            // Target: 34.0 x 23.8 x 1.2 | Actual: 3.805 x 4.345 x 1.588
            return SIMD3<Float>(8.936, 5.478, 0.756)
        case .macbook16:
            // Target: 35.6 x 24.8 x 1.7 | Actual: 35.485 x 33.664 x 23.778
            return SIMD3<Float>(1.003, 0.737, 0.0715)
        case .iMac24:
            // Target: 54.7 x 46.1 x 14.7 | Actual: 14.345 x 13.170 x 1.326
            return SIMD3<Float>(3.813, 3.501, 11.086)
        case .studioDisplay27:
            // Target: 62.3 x 47.8 x 16.8 | Actual: 14.844 x 0.461 x 16.286
            return SIMD3<Float>(4.196, 103.68, 1.031)
        case .monitor32:
            // Target: 71.4 x 42.4 x 20 | Actual: 2.0 x 2.0 x 2.0
            return SIMD3<Float>(35.7, 21.2, 10.0)
        case .appleMouse:
            // Target: 11.3 x 5.7 x 3.4 | Actual: 86.740 x 32.385 x 81.040
            return SIMD3<Float>(0.1303, 0.1761, 0.0420)
        case .deskmat:
            // Target: 70 x 30 (asumsi Y=0.5cm tipis) | Actual: 2.012 x 4.659 x 0.031
            return SIMD3<Float>(34.79, 0.00107, 96.77)
        case .magicKeyboard:
            // Target: 27.9 x 11.5 x 1.1 | Actual: 60.480 x 0.985 x 56.490
            return SIMD3<Float>(0.4613, 0.1168, 0.01947)
        case .monitorRaiser:
            // Target: 70 x 22.5 x 8 | Actual: 0.711 x 0.229 x 0.019
            return SIMD3<Float>(0.985, 0.983, 4.211)
        }
    }}
=======
    
    
    public var scaleCorrection: SIMD3<Float> {
        switch self {
//        case .macbook16: return 10.0
        case .macbook16: return SIMD3<Float>(1.003, 0.737, 0.0715)
        case .macbookAir13new: return SIMD3<Float>(1,1,1)
//        case .macbook16CenterNew: return 1.0
//        case .monitor32: return 50.0
//        case .magicKeyboard: return 50.0
//        default: return 1.0 // TODO: belum diukur, perlu print bounds satu-satu
        default : return SIMD3<Float>(1, 1, 1)
        }
    }
}
>>>>>>> d01692b (F/30 object anchor handling (#31))
