//
//  DataBaseClient.swift
//  Motion
//
//  Created by Igor Tarasenko on 02/08/2022.
//

import Foundation
import CodableCSV

struct DataBaseClient {
  var appendData: (_filename: String, _ data: MotionData) -> Void
}

extension MotionData: Codable {

}

extension DataBaseClient {
  static var live: DataBaseClient {
    let encoder = CSVEncoder {
      $0.headers = MotionData.CodingKeys.allCases.map { $0.rawValue }
    }
    let data = try encoder.encode(value, into: Data.self)
  }
}
