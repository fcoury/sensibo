//
//  Measurements.swift
//  SensiboClient
//
//  Created by Felipe Coury on 19/2/21.
//  Copyright © 2021 Felipe Coury. All rights reserved.
//

import Foundation

public class Time: Codable {
  public let secondsAgo: Int?
  public let time: String?

  public init(secondsAgo: Int? = nil, time: String? = nil) {
    self.secondsAgo = secondsAgo
    self.time = time
  }
}

public class Measurements: Codable {
    public let temperature: Float
    public let humidity: Float?
    public let time: Time
    public let rssi: Int

    public init(temperature: Float, humidity: Float? = nil, time: Time, rssi: Int) {
      self.temperature = temperature
      self.humidity = humidity
      self.time = time
      self.rssi = rssi
    }
}
