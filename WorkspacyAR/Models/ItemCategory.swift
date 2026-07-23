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
    case macbookPro14 = "macbook_pro_14"
    case macbookAir15 = "macbook_air_15"
    case macbookPro16 = "macbook_pro_16"
    case iMac24 = "imac_24"
    case studioDisplay27 = "studio_display_27"
    case monitor32 = "monitor_32"
    case appleMouse = "apple_mouse"
    case deskmat = "deskmat"
    case magicKeyboard = "magic_keyboard"
    case monitorRaiser = "monitor_raiser"
    
    public var id: String { self.rawValue }
    
    public var displayName: String {
        switch self {
        case .macbookAir13: return "13\" MacBook Air"
        case .macbookPro14: return "14\" MacBook Pro"
        case .macbookAir15: return "15\" MacBook Air"
        case .macbookPro16: return "16\" MacBook Pro"
        case .iMac24: return "24\" iMac"
        case .studioDisplay27: return "27\" Studio Display"
        case .monitor32: return "32\" Monitor"
        case .appleMouse: return "Apple Mouse"
        case .deskmat: return "Desk Mat"
        case .magicKeyboard: return "Magic Keyboard"
        case .monitorRaiser: return "Monitor Raiser"
        }
    }
    
    public var category: ItemCategory {
        switch self {
        case .macbookAir13, .macbookPro14, .macbookAir15, .macbookPro16:
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
        case .macbookPro16: return "35.6 x 24.8 x 1.7 cm"
        case .iMac24: return "54.7 x 46.1 x 14.7 cm"
        case .studioDisplay27: return "62.3 x 47.8 x 16.8 cm"
        case .monitor32: return "71.4 x 42.4 x 20 cm"
        case .appleMouse: return "11.3 x 5.7 x 3.4 cm"
        case .deskmat: return "70 x 30 cm"
        case .magicKeyboard: return "27.9 x 11.5 x 1.1 cm"
        case .monitorRaiser: return "70 x 22.5 x 8 cm"
        }
    }
    
    public var sfSymbol: String {
        switch self {
        case .macbookAir13, .macbookPro14, .macbookAir15, .macbookPro16:
            return "laptopcomputer"
        case .iMac24: return "desktopcomputer"
        case .studioDisplay27, .monitor32: return "tv"
        case .appleMouse: return "computermouse"
        case .deskmat: return "rectangle.3.offgrid.fill"
        case .magicKeyboard: return "keyboard"
        case .monitorRaiser: return "square.stack.3d.up"
        }
    }
    
    public var ergonomicTip: String {
        switch self {
        case .macbookAir13, .macbookAir15:
            return "Use a laptop riser along with an external keyboard and mouse to prevent neck strain."
        case .macbookPro14, .macbookPro16:
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
        }
    }
    
    public var assetName: String {
        switch self {
        case .macbookAir13: return "13inch_MacbookAir"
        case .macbookPro14: return "14inch_MacBookPro"
        case .macbookAir15: return "15inch_MacbookAir"
        case .macbookPro16: return "16inch_MacbookPro"
        case .iMac24: return "24inch_iMac"
        case .studioDisplay27: return "27inch_StudioDisplay"
        case .monitor32: return "32inch_Monitor"
        case .appleMouse: return "AppleMouse"
        case .deskmat: return "Deskmat"
        case .magicKeyboard: return "MagicKeyboardMac"
        case .monitorRaiser: return "MonitorRaiser"
        }
    }
    
    public var scaleCorrection: SIMD3<Float> {
        return SIMD3<Float> (1,1,1)
    }
    
    public var canBeStackedOn: Bool {
        switch self {
        case .monitorRaiser, .deskmat:
            return true
        default:
            return false
        }
    }
    
    public var footprintRadius: Float {
        switch self {
        case .macbookAir13: return 0.19
        case .macbookPro14: return 0.20
        case .macbookAir15: return 0.21
        case .macbookPro16: return 0.22
        case .iMac24: return 0.36
        case .studioDisplay27: return 0.40
        case .monitor32: return 0.42
        case .appleMouse: return 0.07
        case .deskmat: return 0.35
        case .magicKeyboard: return 0.16
        case .monitorRaiser: return 0.35
        }
    }
    
    /// Tinggi fisik objek dalam meter (dipakai untuk stacking - seberapa tinggi objek lain harus "naik" kalau ditaruh di atasnya)
    public var physicalHeight: Float {
        switch self {
        case .macbookAir13: return 0.011
        case .macbookPro14: return 0.016
        case .macbookAir15: return 0.012
        case .macbookPro16: return 0.017
        case .iMac24: return 0.147
        case .studioDisplay27: return 0.168
        case .monitor32: return 0.20
        case .appleMouse: return 0.034
        case .deskmat: return 0.003 // tipis, ~3mm
        case .magicKeyboard: return 0.011
        case .monitorRaiser: return 0.08
        }
    }
}



