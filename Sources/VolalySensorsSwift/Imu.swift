//
//  Imu-iOS.swift
//  VolalySensorsSwift
//
//  Created by Boris Gromov on 29.06.2020.
//  


import Foundation
import CoreMotion
import simd

import Transform

extension Volaly {
    // Inspired by https://stackoverflow.com/a/58368793/13647455
    public class Imu: ObservableObject {
        private let motionQueue: OperationQueue
        private let motionManager = CMMotionManager()

        private func transformFromAppleInertial(roll: Double, pitch: Double, yaw: Double) -> Transform {
            return Transform(simd_quatd(roll: roll, pitch: -pitch, yaw: yaw))
        }

        @Published
        public var transform: Transform

        public init(updateInterval: TimeInterval = 0.05 /* 20 Hz */) {
            motionQueue = OperationQueue()
            motionQueue.maxConcurrentOperationCount = 1

            self.transform = Transform.identity

            motionManager.deviceMotionUpdateInterval = updateInterval
            motionManager.startDeviceMotionUpdates(to: motionQueue) { (motionData: CMDeviceMotion!, error) in
                guard error == nil else {
                    print("CoreMotion error:", error!)
                    return
                }

                let (roll, pitch, yaw) = (motionData.attitude.roll, motionData.attitude.pitch, motionData.attitude.yaw)
                self.transform = self.transformFromAppleInertial(roll: roll, pitch: pitch, yaw: yaw)
            }
        }
    }
}
