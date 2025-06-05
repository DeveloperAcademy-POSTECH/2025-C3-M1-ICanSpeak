//
//  Font.swift
//  umm
//
//  Created by Youbin on 6/2/25.
//

import Foundation
import SwiftUI

extension Font {
    //MARK: 영어,숫자
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
    
    static var sfbold14: Font {
        return .sfCompact(type: .bold, size: 14)
    }
    
    static var sfmedium16: Font {
        return .sfCompact(type: .medium, size: 16)
    }
    
    static var sfmedium12: Font {
        return .sfCompact(type: .medium, size: 16)
    }
    
    static var sfregular18: Font {
        return .sfCompact(type: .regular, size: 18)
    }
    
    static var sfregular15: Font {
        return .sfCompact(type: .regular, size: 15)
    }
    
    static var sfregular14: Font {
        return .sfCompact(type: .regular, size: 14)
    }
    
    static var sfregular12: Font {
        return .sfCompact(type: .regular, size: 12)
    }
    
    //MARK: - Apple SD Gothic Neo : 한글
    enum SdGothic{
        case extrabold
        case bold
        case semibold
        case medium
        case regular
        case light
        
        var value: String {
            switch self {
            /// Apple SD Gothic Neo
            case .extrabold:
                return "AppleSDGothicNeo-ExtraBold"
            case .bold:
                return "AppleSDGothicNeo-Bold"
            case .semibold:
                return "AppleSDGothicNeo-SemiBold"
            case .medium:
                return "AppleSDGothicNeo-Medium"
            case .regular:
                return "AppleSDGothicNeo-Regular"
            case .light:
                return "AppleSDGothicNeo-Light"
            }
        }
    }
    
    static func sdGothic(type: SdGothic, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }

    //MARK: SD Gothic 변수들
    static var sdextra30: Font {
        return .sdGothic(type: .extrabold, size: 30)
    }
    
    static var sdbold19: Font {
        return .sdGothic(type: .bold, size: 19)
    }
    
    static var sdbold16: Font {
        return .sdGothic(type: .bold, size: 16)
    }
    
    static var sdregular15: Font {
        return .sdGothic(type: .regular, size: 15)
    }
    
    static var sdmedium16: Font {
        return .sdGothic(type: .medium, size: 16)
    }
    
    static var sdmedium14: Font {
        return .sdGothic(type: .medium, size: 14)
    }
    
    static var sdregular16: Font {
        return .sdGothic(type: .regular, size: 16)
    }
    
    static var sdregular12: Font {
        return .sdGothic(type: .regular, size: 12)
    }
    
    //MARK: Monserrat
    enum Monserrat {
        case bold
        case medium
        
        var value: String {
            switch self {
            /// SF Compact
            case .bold:
                return "Montserrat-Bold"
            case .medium:
                return "Montserrat-Medium"
            }
        }
    }
    
    static func monserrat(type: Monserrat, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }
    static var montBold28: Font {
        return .monserrat(type: .bold, size: 28)
    }
    
    static var montBold17: Font {
        return .monserrat(type: .bold, size: 17)
    }
    
    static var montBold14: Font {
        return .monserrat(type: .bold, size: 14)
    }
    
    static var montMedium14: Font {
        return .monserrat(type: .medium, size: 14)
    }
    
}
