import SwiftUI

struct NoDataView: View {
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
      Text("아직 저장된 단어가 없어요.")
        .font(.sdbold16)
        .padding(.top,10)
      Text("AI와 대화하며 워치에게 단어를 물어보세요")
        .font(.sdmedium14)
    }
  }
}

#Preview {
  NoDataView()
}
