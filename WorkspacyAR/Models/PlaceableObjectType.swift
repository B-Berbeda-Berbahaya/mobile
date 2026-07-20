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
    case macbook16 = "macbook_16"
    case iMac24 = "imac_24"
    case monitor32 = "monitor_32"
    case appleMouse = "apple_mouse"
    case magicKeyboard = "magic_keyboard"
    
    public var id: String { self.rawValue }
    
    public var displayName: String {
        switch self {
        case .macbook16: return "16\" MacBook Pro"
        case .iMac24: return "24\" iMac"
        case .monitor32: return "32\" Monitor"
        case .appleMouse: return "Apple Mouse"
        case .magicKeyboard: return "Magic Keyboard"
        }
    }
    
    public var category: ItemCategory {
        switch self {
        case .macbook16: return .laptop
        case .iMac24, .monitor32: return .monitor
        case .appleMouse: return .mouse
        case .magicKeyboard: return .keyboard
        }
    }
    
    public var dimensionsDescription: String {
        switch self {
        case .macbook16: return "35.6 x 24.8 x 1.7 cm"
        case .iMac24: return "54.7 x 46.1 x 14.7 cm"
        case .monitor32: return "71.4 x 42.4 x 20 cm"
        case .appleMouse: return "11.3 x 5.7 x 3.4 cm"
        case .magicKeyboard: return "27.9 x 11.5 x 1.1 cm"
        }
    }
    
    public var sfSymbol: String {
        switch self {
        case .macbook16: return "laptopcomputer"
        case .iMac24: return "desktopcomputer"
        case .monitor32: return "tv"
        case .appleMouse: return "computermouse"
        case .magicKeyboard: return "keyboard"
        }
    }
    
    public var ergonomicTip: String {
        switch self {
        case .macbook16: return "Use a laptop riser along with an external keyboard and mouse to prevent neck strain."
        case .iMac24: return "The top of the screen should be at or slightly below eye level, at an arm's distance."
        case .monitor32: return "Position the monitor so the top third of the screen aligns with your eye level."
        case .appleMouse: return "Keep the mouse close to the keyboard and avoid resting your wrist on hard desk edges."
        case .magicKeyboard: return "Keep the keyboard flat or slightly tilted away from you to keep your wrists in a neutral position."
        }
    }
    
    public var assetName: String {
        switch self {
        case .macbook16: return "16inch_Macbook"
        case .iMac24: return "24inch_iMac"
        case .monitor32: return "32inch_Monitor"
        case .appleMouse: return "AppleMouse"
        case .magicKeyboard: return "MagicKeyboardMac"
        }
    }
    
    public var scaleCorrection: Float {
        switch self {
        case .macbook16: return 1.0     // sudah benar, ~35cm sesuai bounds kemarin
        case .iMac24: return 1.0        // belum diukur, asumsi normal dulu
        case .monitor32: return 50.0    // terbukti ~50x kekecilan
        case .appleMouse: return 1.0    // belum diukur, asumsi normal dulu
        case .magicKeyboard: return 50.0 // terbukti ~50x kekecilan (0.56cm vs harusnya ~28cm = rasio ~50x)
        }
    }
}
