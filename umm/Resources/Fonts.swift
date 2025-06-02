//
//  Font.swift
//  umm
//
//  Created by Youbin on 6/2/25.
//

import Foundation
import SwiftUI

extension Font {
    //MARK: - SF Compact : 영어,숫자
    enum SfCompact {
        case bold
        case semibold
        case medium
        case regular
        case light
        
        var value: String {
            switch self {
            /// SF Compact
            case .bold:
                return "SFCompactText-Bold"
            case .semibold:
                return "SFCompactText-SemiBold"
            case .medium:
                return "SFCompactText-Medium"
            case .regular:
                return "SFCompactText-Regular"
            case .light:
                return "SFCompactText-Light"
            }
        }
    }
    
    static func sfCompact(type: SfCompact, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }
    
    //MARK: SF Compact 변수들
    static var sfbold20: Font {
        return .sfCompact(type: .bold, size: 20)
    }
    
    static var sfmedium16: Font {
        return .sfCompact(type: .medium, size: 16)
    }

    
    //MARK: - Apple SD Gothic Neo : 한글
    enum SdGothic{
        case bold
        case semibold
        case medium
        case regular
        case light
        
        var value: String {
            switch self {
            /// Apple SD Gothic Neo
            case .bold:
                return "AppleSDGothicNeoB"
            case .semibold:
                return "AppleSDGothicNeoSB"
            case .medium:
                return "AppleSDGothicNeoM"
            case .regular:
                return "AppleSDGothicNeoR"
            case .light:
                return "AppleSDGothicNeoL"
            }
        }
    }
    
    static func sdGothic(type: SfCompact, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }

    //MARK: SD Gothic 변수들
    static var sdregular12: Font {
        return .sdGothic(type: .regular, size: 12)
    }
    
    static var sdregular16: Font {
        return .sdGothic(type: .regular, size: 16)
    }
    
    static var sdmedium16: Font {
        return .sdGothic(type: .medium, size: 16)
    }
}
