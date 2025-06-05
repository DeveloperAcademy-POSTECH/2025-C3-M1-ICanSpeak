//
//  BackgorounView.swift
//  umm
//
//  Created by MINJEONG on 6/5/25.
//

import SwiftUI

struct BackgorounView: View {
    var body: some View {
        ZStack {
            Color.primary0
                .ignoresSafeArea()
            Image("배경UMM")
                .offset(y:280)
        }
    }
}

#Preview {
    BackgorounView()
}
