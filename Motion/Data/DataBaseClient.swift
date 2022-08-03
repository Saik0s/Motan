//
//  DataBaseClient.swift
//  Motion
//
//  Created by Igor Tarasenko on 02/08/2022.
//

import Foundation
import CodableCSV

struct DataBaseClient {
  var appendData: (_ filename: String, _ data: MotionData) throws -> Void
}

extension DataBaseClient {
  static func live() throws -> DataBaseClient {
    let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let queue = DispatchQueue(label: "csvWriter")

    return DataBaseClient { filename, data in
      queue.async {
        let fileURL = documentsURL.appendingPathComponent(filename)
        let header = ["time", "roll", "pitch", "yaw"]
        let row = [Date().timeIntervalSince1970, data.roll, data.pitch, data.yaw].map { String(format: "%.2f", $0) }
        let rows = [header, row]
        do {
          try CSVWriter.encode(rows: rows, into: fileURL, append: false)
        } catch {
          print(error)
        }
      }
    }
  }
}
