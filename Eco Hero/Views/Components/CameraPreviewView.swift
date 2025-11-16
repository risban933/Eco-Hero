//
//  CameraPreviewView.swift
//  Eco Hero
//
//  Created by Rishabh Bansal on 11/15/25.
//

import AVFoundation
import SwiftUI

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewHostView {
        let view = CameraPreviewHostView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: CameraPreviewHostView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

final class CameraPreviewHostView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
