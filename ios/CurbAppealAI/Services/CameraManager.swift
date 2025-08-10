import AVFoundation
import UIKit
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    @Published var cameraState: CameraState = .notAuthorized
    @Published var capturedImage: UIImage?
    
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    } else {
                        self.cameraState = .notAuthorized
                    }
                }
            }
        case .denied, .restricted:
            cameraState = .notAuthorized
        @unknown default:
            cameraState = .notAuthorized
        }
    }
    
    private func setupCamera() {
        cameraState = .configuring
        
        session.sessionPreset = .photo
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            cameraState = .notAuthorized
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.cameraState = .ready
                }
            }
            
        } catch {
            cameraState = .notAuthorized
        }
    }
    
    func capturePhoto() {
        guard cameraState == .ready else { return }
        
        cameraState = .capturing
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
            cameraState = .ready
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            cameraState = .ready
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.cameraState = .processing
        }
    }
}