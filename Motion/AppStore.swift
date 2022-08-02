//
//  AppStore.swift
//  Motion
//
//  Created by Igor Tarasenko on 02/08/2022.
//

import Combine

final class AppStore: ObservableObject {
  let motionEngine: MotionEngine

  init(motionEngine: MotionEngine = MotionEngine()) {
    self.motionEngine = motionEngine
  }
}
