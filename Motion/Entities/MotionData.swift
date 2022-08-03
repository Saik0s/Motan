//
//  MotionData.swift
//  Motion
//
//  Created by Igor Tarasenko on 03/08/2022.
//

struct MotionData: Hashable, Codable {
  struct Quaternion: Hashable, Codable { var x, y, z, w: Double }
  struct XYZ: Hashable, Codable { var x, y, z: Double }

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
        x: \(quaternion.x.prettyString)
        y: \(quaternion.y.prettyString)
        z: \(quaternion.z.prettyString)
        w: \(quaternion.w.prettyString)
    Attitude:
        pitch: \(pitch.prettyString)
        roll: \(roll.prettyString)
        yaw: \(yaw.prettyString)
    Gravitational Acceleration:
        x: \(gravityAcceleration.x.prettyString)
        y: \(gravityAcceleration.y.prettyString)
        z: \(gravityAcceleration.z.prettyString)
    Rotation Rate:
        x: \(rotationRate.x.prettyString)
        y: \(rotationRate.y.prettyString)
        z: \(rotationRate.z.prettyString)
    Acceleration:
        x: \(userAcceleration.x.prettyString)
        y: \(userAcceleration.y.prettyString)
        z: \(userAcceleration.z.prettyString)
    Magnetic Field:
        field: \(magneticFieldVector)
        accuracy: \(magneticFieldAccuracy)
    Heading:
        \(heading.prettyString)
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

