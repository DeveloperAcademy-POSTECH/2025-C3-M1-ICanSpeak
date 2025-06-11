import SwiftUI

struct NoDataView: View {
  let text1:String
  let text2:String
  
  var body: some View {
    VStack(spacing:5){
      
      ZStack{
        Circle()
          .fill(Color.primary1)
          .frame(width:48, height:48)
        HStack(spacing:3){
          Circle()
            .fill(Color.primary4)
            .frame(width:10, height:10)
          ZStack {
                      RoundedRectangle(cornerRadius: 0)
                          .frame(width: 10, height: 3)
                          .rotationEffect(.degrees(-60))
                      RoundedRectangle(cornerRadius: 0)
                          .frame(width: 6, height: 3)
                          .rotationEffect(.degrees(30))
                          .offset(x: 0, y: 4.5)
                  }
          .foregroundColor(.primary4)
          Rectangle()
            .fill(Color.primary4)
            .frame(width:10, height:10)
        }
      }
      Text(text1)
        .font(.sdbold16)
        .padding(.top,10)
      Text(text2)
        .font(.sdmedium14)
    }
  }
}
