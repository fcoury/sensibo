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
    public let batteryVoltage: String?
    public let temperature: Float
    public let humidity: Float?
    public let feelsLike: Float?
    public let time: Time
    public let rssi: Int
//    public let piezo: [String?]
//    public let pm25: Int?

    public init(batteryVoltage: String? = nil, temperature: Float, humidity: Float? = nil, feelsLike: Float? = nil, time: Time, rssi: Int) {
//        public init(batteryVoltage: String? = nil, temperature: Float, humidity: Float? = nil, feelsLike: Float? = nil, time: Time, rssi: Int, piezo: [String?], pm25: Int? = nil) {
      self.batteryVoltage = batteryVoltage
      self.temperature = temperature
      self.humidity = humidity
        self.feelsLike = feelsLike
      self.time = time
      self.rssi = rssi
    }
}
