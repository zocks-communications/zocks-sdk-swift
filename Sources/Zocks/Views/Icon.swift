//
//  IconView.swift
//  
//
//  Created by János Kranczler on 2023. 01. 20..
//

import Foundation
import SwiftUI

public enum Icons: String, CaseIterable {
    
    case arrowDown = "\u{e800}"
    case arrowLeft = "\u{e801}"
    case arrowRight = "\u{e802}"
    case arrowUp = "\u{e803}"
    case paperClip = "\u{e804}"
    case audio = "\u{e805}"
    case callEnd = "\u{e806}"
    case cameraOff = "\u{e807}"
    case cameraOn = "\u{e808}"
    case cameraSwitch = "\u{e809}"
    case checkMark = "\u{e80a}"
    case chevronDown = "\u{e80b}"
    case chevronLeft = "\u{e80c}"
    case chevronRight = "\u{e80d}"
    case chevronUp = "\u{e80e}"
    case close = "\u{e80f}"
    case emoji = "\u{e810}"
    case expand = "\u{e811}"
    case gridOff = "\u{e812}"
    case gridOn = "\u{e813}"
    case hamburger = "\u{e814}"
    case landscape = "\u{e815}"
    case logOut = "\u{e816}"
    case messageWithDot = "\u{e817}"
    case message = "\u{e818}"
    case micOff = "\u{e819}"
    case micOn = "\u{e81a}"
    case others = "\u{e81b}"
    case participants = "\u{e81c}"
    case portrait = "\u{e81d}"
    case raisedHand = "\u{e81e}"
    case screenShare = "\u{e81f}"
    case send = "\u{e820}"
    case share = "\u{e822}"
    case shrink = "\u{e823}"
    case soundWaveOff = "\u{e824}"
    case soundWaveOn = "\u{e825}"
    case speakerViewOff = "\u{e826}"
    case speakerViewOn = "\u{e827}"
    case wifi = "\u{e828}"
    case zocks = "\u{e829}"
    case appleLogo = "\u{e82a}"
    case facebookLogo = "\u{e82e}"
    case googleLogo = "\u{e82f}"
    case audioDeviceBluetooth = "\u{e830}"
    case audioDeviceSpeaker = "\u{e831}"
    case audioDeviceEarpiece = "\u{e832}"

}

let fontName = "fontello"

public struct Icon: View {
    
    let icon: Icons
    let size: Float
    let color: Color?
    
    public init(icon: Icons, size: Float = 24.0, color: Color? = .white) {
        self.icon = icon
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        Text(icon.rawValue)
            .font(Font.custom(fontName, size: CGFloat(size), relativeTo: .body))
            .foregroundColor(color)
    }
    
}
