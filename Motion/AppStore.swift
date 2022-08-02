//
//  AppStore.swift
//  Motion
//
//  Created by Igor Tarasenko on 02/08/2022.
//

import Combine

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

struct MotionData: Hashable {
  struct Quaternion: Hashable { var x, y, z, w: Double }
  struct XYZ: Hashable { var x, y, z: Double }

  var isManagerConnected = false
  var isDeviceMotionActive = false
  var isDeviceMotionAvailable = false

  var quaternion: Quaternion = .zero
  var roll: Double = 0
  var pitch: Double = 0
  var yaw: Double = 0
  var gravityAcceleration: XYZ = .zero
  var rotationRate: XYZ = .zero
  var userAcceleration: XYZ = .zero
  var heading: Double = 0
  var magneticFieldVector: XYZ = .zero
  var magneticFieldAccuracy: Int32 = 0

  var prettyDescription: String {
    """
    Manager Connected: \(isManagerConnected)
    Device Motion Active: \(isDeviceMotionActive)
    Device Motion Available: \(isDeviceMotionAvailable)
    Quaternion:
        x: \(quaternion.x)
        y: \(quaternion.y)
        z: \(quaternion.z)
        w: \(quaternion.w)
    Attitude:
        pitch: \(pitch)
        roll: \(roll)
        yaw: \(yaw)
    Gravitational Acceleration:
        x: \(gravityAcceleration.x)
        y: \(gravityAcceleration.y)
        z: \(gravityAcceleration.z)
    Rotation Rate:
        x: \(rotationRate.x)
        y: \(rotationRate.y)
        z: \(rotationRate.z)
    Acceleration:
        x: \(userAcceleration.x)
        y: \(userAcceleration.y)
        z: \(userAcceleration.z)
    Magnetic Field:
        field: \(magneticFieldVector)
        accuracy: \(magneticFieldAccuracy)
    Heading:
        \(heading)
    """
  }
}

extension MotionData.Quaternion {
  static var zero: Self {
    .init(x: 0, y: 0, z: 0, w: 0)
  }
}

extension MotionData.XYZ {
  static var zero: Self {
    .init(x: 0, y: 0, z: 0)
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
    let session = AVAudioSession.sharedInstance()
    try! session.setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
    guard let availableInputs = session.availableInputs else { return }
    for input in availableInputs {
      print(input)
      print(input.portType)
      if input.portType == .bluetoothHFP {
        // Do your stuff...
      }
    }

    motionManager.startDeviceMotionUpdates(to: .current ?? .main) { [weak self] motion, error in
      print(motion?.description ?? error?.localizedDescription ?? "")

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
  }
}

final class AppStore: ObservableObject {
  let motionEngine: MotionEngine

  init(motionEngine: MotionEngine = MotionEngine()) {
    self.motionEngine = motionEngine
  }
}
