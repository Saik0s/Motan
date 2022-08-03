//
//  SettingsView
//  Motion
//
//  Created by Igor Tarasenko on 03/08/2022.
//

import SwiftUI

struct Direction: Hashable, CustomStringConvertible {
  let roll, pitch, yaw: Double

  static var zero: Direction { Direction(roll: 0, pitch: 0, yaw: 0)}

  var description: String {
    "Direction(roll: \(roll.prettyString), pitch: \(pitch.prettyString), yaw: \(yaw.prettyString))"
  }
}

struct SettingsView: View {
  @ObservedObject var store: AppStore
  @ObservedObject var motionEngine: MotionEngine

  var data: MotionData { store.motionEngine.data }

  @State var baseDirection: Direction = .zero

  @State var minPitch: Double = 0
  @State var maxPitch: Double = 0
  @State var minYaw: Double = 0
  @State var maxYaw: Double = 0

  var offsetXPercentFromCenter: Double {
    let full = maxYaw - minYaw
    let movedDistance = baseDirection.yaw - data.yaw
    return movedDistance / full
  }

  var offsetYPercentFromCenter: Double {
    let full = maxPitch - minPitch
    let movedDistance = baseDirection.pitch - data.pitch
    return movedDistance / full
  }

  init(store: AppStore) {
    self.store = store
    motionEngine = store.motionEngine
  }

  var body: some View {
    ZStack {
      VStack {
        Text("""
             direction:
               pitch: \(data.pitch.prettyString)
               roll: \(data.roll.prettyString)
               yaw: \(data.yaw.prettyString)
             center: \(String(describing: baseDirection))
             minPitch: \(minPitch.prettyString)
             maxPitch: \(maxPitch.prettyString)
             minYaw: \(minYaw.prettyString)
             maxYaw: \(maxYaw.prettyString)
             """)
      }
      GeometryReader { proxy in
        Circle()
          .fill(Color.green)
          .frame(width: 50, height: 50)
          .offset(
            x: offsetXPercentFromCenter * proxy.size.width,
            y: offsetYPercentFromCenter * proxy.size.height
            )
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }

      Button {
        baseDirection = Direction(roll: store.motionEngine.data.roll, pitch: store.motionEngine.data.pitch, yaw: store.motionEngine.data.yaw)
      } label: {
        Text("Set current as center").foregroundColor(.white).padding().background(Color.blue).cornerRadius(5)
      }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
      .onChange(of: store.motionEngine.data) { data in
      if data.pitch < minPitch { minPitch = data.pitch }
        if data.pitch > maxPitch { maxPitch = data.pitch }
        if data.yaw < minYaw { minYaw = data.yaw }
        if data.yaw > maxYaw { maxYaw = data.yaw }
      }
  }
}
