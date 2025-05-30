//
//  FirstDetectView.swift
//  WatchTest29th Watch App
//
//  Created by MINJEONG on 5/29/25.
//

import SwiftUI

struct UmmDetectView: View {
    
    var body: some View {
        ZStack{
            Circle()
                .foregroundColor(.orange).opacity(0.4)
            
                .frame(width: 133, height: 133)
            Circle()
                .foregroundColor(.orange).opacity(0.7)
            
                .frame(width: 112, height: 112)
            Circle()
                .foregroundColor(.orange)
                .frame(width: 84, height: 84)
            
            VStack {
                Spacer()
                HStack(spacing: 5) {
                    Text("Umm")
                        .font(.system(size: 20))
                        .bold()
                }
                Spacer()
            }
        }
        
    }
}


#Preview {
    UmmDetectView()
}
