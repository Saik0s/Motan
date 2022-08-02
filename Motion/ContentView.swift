//
//  ContentView.swift
//  Motion
//
//  Created by Igor Tarasenko on 02/08/2022.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var store: AppStore
  @ObservedObject var motionEngine: MotionEngine

  var data: MotionData { motionEngine.data }

  init(store: AppStore) {
    self.store = store
    motionEngine = store.motionEngine
  }

  var body: some View {
    ZStack {
      Text(motionEngine.data.prettyDescription)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.system(size: 10))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .opacity(0.5)

      VStack(spacing: 30) {
        Text("Pitch").padding().background(Color.yellow).cornerRadius(15)
          .transformEffect(.init(rotationAngle: data.pitch))
        Text("Roll").padding().background(Color.green).cornerRadius(15)
          .transformEffect(.init(rotationAngle: data.roll))
        Text("yaw").padding().background(Color.blue).cornerRadius(15)
          .transformEffect(.init(rotationAngle: data.yaw))
      }
      .font(.system(size: 30))

      HStack {
        if !motionEngine.data.isManagerConnected {
          Button(action: { motionEngine.start()  }, label: { Text("Start").padding().background(Color.green).cornerRadius(5) })
        } else {
          Button(action: { motionEngine.stop()  }, label: { Text("Stop").padding().background(Color.red).cornerRadius(5) })
        }
      }
      .foregroundColor(.white)
      .padding()
      .frame(maxHeight: .infinity, alignment: .bottom)
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(store: AppStore())
  }
}
