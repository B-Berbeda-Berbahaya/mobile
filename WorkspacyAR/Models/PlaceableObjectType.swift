import Foundation

public enum ItemCategory: String, CaseIterable, Identifiable {
    case furniture = "Furniture"
    case devices = "Devices"
    case accessories = "Accessories"
    
    public var id: String { self.rawValue }
    
    public var sfSymbol: String {
        switch self {
        case .furniture: return "table"
        case .devices: return "desktopcomputer"
        case .accessories: return "keyboard"
        }
    }
}

public enum PlaceableObjectType: String, CaseIterable, Identifiable {
    case standardDesk = "standard_desk"
    case standingDesk = "standing_desk"
    case ergonomicChair = "ergonomic_chair"
    case monitor34 = "monitor_34"
    case laptop = "laptop"
    case deskLamp = "desk_lamp"
    case keyboard = "keyboard"
    case mouse = "mouse"
    case plant = "plant"
    case speakers = "speakers"
    
    public var id: String { self.rawValue }
    
    public var displayName: String {
        switch self {
        case .standardDesk: return "Standard Desk"
        case .standingDesk: return "Electric Standing Desk"
        case .ergonomicChair: return "Ergonomic Office Chair"
        case .monitor34: return "34\" Curved Monitor"
        case .laptop: return "MacBook Pro"
        case .deskLamp: return "LED Desk Lamp"
        case .keyboard: return "Mechanical Keyboard"
        case .mouse: return "Vertical Mouse"
        case .plant: return "Potted Snake Plant"
        case .speakers: return "Studio Monitors"
        }
    }
    
    public var category: ItemCategory {
        switch self {
        case .standardDesk, .standingDesk, .ergonomicChair:
            return .furniture
        case .monitor34, .laptop, .speakers:
            return .devices
        case .deskLamp, .keyboard, .mouse, .plant:
            return .accessories
        }
    }
    
    public var dimensionsDescription: String {
        switch self {
        case .standardDesk: return "120 x 60 x 75 cm"
        case .standingDesk: return "140 x 70 x 65-125 cm"
        case .ergonomicChair: return "65 x 65 x 100-115 cm"
        case .monitor34: return "80 x 25 x 45 cm"
        case .laptop: return "35 x 24 x 1.5 cm"
        case .deskLamp: return "15 x 15 x 40 cm"
        case .keyboard: return "44 x 13 x 3 cm"
        case .mouse: return "12 x 7 x 8 cm"
        case .plant: return "20 x 20 x 30 cm"
        case .speakers: return "18 x 20 x 28 cm"
        }
    }
    
    public var sfSymbol: String {
        switch self {
        case .standardDesk: return "table"
        case .standingDesk: return "arrow.up.and.down.square"
        case .ergonomicChair: return "chair.lounge"
        case .monitor34: return "tv"
        case .laptop: return "laptopcomputer"
        case .deskLamp: return "lightbulb"
        case .keyboard: return "keyboard"
        case .mouse: return "computermouse"
        case .plant: return "sprout"
        case .speakers: return "speaker.wave.2"
        }
    }
    
    public var ergonomicTip: String {
        switch self {
        case .standardDesk: return "Desk height should allow elbows to bend at a 90-degree angle while typing."
        case .standingDesk: return "Alternate between sitting and standing every 30-45 minutes to boost circulation."
        case .ergonomicChair: return "Adjust backrest tilt and lumbar support to sit flat with your feet fully on the ground."
        case .monitor34: return "The top of the monitor screen should be at or slightly below eye level, at an arm's distance."
        case .laptop: return "Use a laptop riser along with an external keyboard and mouse to prevent neck strain."
        case .deskLamp: return "Place the light source to the side of your monitor to minimize screen glare and eye fatigue."
        case .keyboard: return "Keep the keyboard flat or slightly tilted away from you to keep your wrists in a neutral position."
        case .mouse: return "Keep the mouse close to the keyboard and avoid resting your wrist on hard desk edges."
        case .plant: return "Introducing green plants nearby reduces mental fatigue and cleans surrounding workspace air."
        case .speakers: return "Place speakers at ear level, angled inward at 60 degrees to create a sweet spot."
        }
    }
    
    public var assetName: String {
        return self.rawValue
    }
}
