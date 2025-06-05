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
    enum Korean {
        case bold
        case semibold
        case medium
        case regular
        case light
        case monserrat
        
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
            case .monserrat:
                return "Montserrat-Bold"
            }
        }
    }
    
    static func sfCompact(type: Korean, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }
    
    static func monserrat(type: Korean, size: CGFloat) -> Font {
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
    
    //MARK: Monserrat
    static var montBold28: Font {
        return .monserrat(type: .monserrat, size: 28)
    }
    
    static var montBold17: Font {
        return .monserrat(type: .monserrat, size: 17)
    }
    
    static var montBold14: Font {
        return .monserrat(type: .monserrat, size: 14)
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
                return "AppleSDGothicNeoEB"
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
    
    static func sdGothic(type: SdGothic, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }

    //MARK: SD Gothic 변수들
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
    
    static var sdregular15: Font {
        return .sdGothic(type: .regular, size: 15)
    }
    
    static var sdregular12: Font {
        return .sdGothic(type: .regular, size: 12)
    }
    

    static var sdbold16: Font {
        return .sdGothic(type: .bold, size: 16)
    }
    
    static var sdextra30: Font {
        return .sdGothic(type: .extrabold, size: 30)
    }
    
}
