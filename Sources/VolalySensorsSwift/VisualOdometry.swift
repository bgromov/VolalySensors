//
//  VisualOdometry-iOS.swift
//  VolalySensorsSwift
//
//  Created by Boris Gromov on 29.06.2020.
//  


import Foundation
import ARKit
import simd
import Combine

import Transform

public extension Volaly {
    // Inspired by https://stackoverflow.com/a/58368793/13647455
    class Vo: NSObject, ObservableObject, ARSessionDelegate {
        public let arSession: ARSession
        public let arConfig: ARWorldTrackingConfiguration

        private var lastTrackingState: ARCamera.TrackingState = .notAvailable
        private var originAdjusted: Bool = false

        private let appleToRosTf: Transform = Transform(simd_quatd(pitch: .pi/2, yaw: .pi/2))

        private let timerPublisher: Timer.TimerPublisher
        private var cancellable: AnyCancellable

        private let notificationGenerator = UINotificationFeedbackGenerator()

        @Published
        public var transform: Transform

        public init(queryInterval: TimeInterval = 0.05 /* 20 Hz */) {
            self.transform = Transform.identity

            arConfig = ARWorldTrackingConfiguration()
            arConfig.worldAlignment = .gravity

            // This option makes simulator crash
            #if !targetEnvironment(simulator)
                arConfig.isAutoFocusEnabled = true
            #endif

            arSession = ARSession()

            timerPublisher = Timer.publish(every: queryInterval, on: .current, in: .default)
            cancellable = AnyCancellable({})

            super.init()

            arSession.delegate = self

            self.setupArSession()
        }

        private func setupArSession() {
            arSession.run(arConfig, options: [.resetTracking, .removeExistingAnchors])

            cancellable = timerPublisher
                .autoconnect()
                .sink { _ in
                    guard let cam = self.arSession.currentFrame?.camera else { return }

                    let camTf = Transform(simd_double4x4(cam.transform))
                    self.transform = camTf * Transform(simd_quatd(yaw: .pi))
                }
        }

        public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            if case .limited(.initializing) = lastTrackingState {
                originAdjusted = false
            }

            if case .normal = camera.trackingState {
                if !originAdjusted {
                    arSession.setWorldOrigin(relativeTransform: simd_float4x4(appleToRosTf.matrix))
                    originAdjusted = true
                }
            }

            if case .limited(_) = camera.trackingState {
                if originAdjusted {
                    notificationGenerator.notificationOccurred(.error)
                }
            }

            lastTrackingState = camera.trackingState
        }
    }
}
