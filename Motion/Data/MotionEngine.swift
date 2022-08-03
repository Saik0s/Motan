//
//  MotionEngine.swift
//  Motion
//
//  Created by Igor Tarasenko on 02/08/2022.
//

import Combine
import Foundation
import CoreMotion
import AVFoundation

final class MotionManagerDelegate: NSObject, CMHeadphoneMotionManagerDelegate {
  let isConnected = CurrentValueSubject<Bool, Never>(false)

  // MARK: - CMHeadphoneMotionManagerDelegate
  func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
    print("\(#function)")
    isConnected.send(true)
  }

  func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
    print("\(#function)")
    isConnected.send(false)
  }
}

final class MotionEngine: ObservableObject  {
  @Published private(set) var data = MotionData()
  @Published private(set) var lastErrorMessage = ""

  private let motionManager = CMHeadphoneMotionManager()
  private let motionManagerDelegate = MotionManagerDelegate()

  private var disposeBag = Set<AnyCancellable>()

  init() {
    prepare()
  }

  func start() {
    motionManager.startDeviceMotionUpdates(to: .current ?? .main) { [weak self] motion, error in
      if let error = error {
        self?.lastErrorMessage = error.localizedDescription
      }

      guard let motion = motion else {
        return
      }

      var newData = self?.data ?? .init()
      newData.quaternion.x = motion.attitude.quaternion.x
      newData.quaternion.y = motion.attitude.quaternion.y
      newData.quaternion.z = motion.attitude.quaternion.z
      newData.quaternion.w = motion.attitude.quaternion.w
      newData.pitch = motion.attitude.pitch
      newData.roll = motion.attitude.roll
      newData.yaw = motion.attitude.yaw
      newData.gravityAcceleration.x = motion.gravity.x
      newData.gravityAcceleration.y = motion.gravity.y
      newData.gravityAcceleration.z = motion.gravity.z
      newData.rotationRate.x = motion.rotationRate.x
      newData.rotationRate.y = motion.rotationRate.y
      newData.rotationRate.z = motion.rotationRate.z
      newData.userAcceleration.x = motion.userAcceleration.x
      newData.userAcceleration.y = motion.userAcceleration.y
      newData.userAcceleration.z = motion.userAcceleration.z
      newData.magneticFieldVector.x = motion.magneticField.field.x
      newData.magneticFieldVector.y = motion.magneticField.field.y
      newData.magneticFieldVector.z = motion.magneticField.field.z
      newData.magneticFieldAccuracy = motion.magneticField.accuracy.rawValue
      newData.heading = motion.heading
      self?.data = newData
    }
  }

  func stop() {
    motionManager.stopDeviceMotionUpdates()
  }

  private func prepare() {
    motionManager.delegate = motionManagerDelegate

    motionManagerDelegate.isConnected
      .assign(to: \.data.isManagerConnected, on: self)
      .store(in: &disposeBag)

    motionManager.publisher(for: \.isDeviceMotionActive, options: [.new])
      .assign(to: \.data.isDeviceMotionActive, on: self)
      .store(in: &disposeBag)

    motionManager.publisher(for: \.isDeviceMotionAvailable, options: [.new])
      .assign(to: \.data.isDeviceMotionActive, on: self)
      .store(in: &disposeBag)

    // Check if airpods are connected
    let session = AVAudioSession.sharedInstance()
    try! session.setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
    let areAirPodsConnected = session.availableInputs?.contains { $0.portType == .bluetoothHFP } ?? false
    if areAirPodsConnected == false {
      print("*******************")
      print("Airpods are not connected")
      print("*******************")
      try! session.setActive(true)
//      DispatchQueue.main.asyncAf {
        try! session.setActive(false)
//      }
    }
  }
}
