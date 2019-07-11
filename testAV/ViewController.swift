//
//  ViewController.swift
//  testAV
//
//  Created by Rico Kristanto on 11/07/19.
//  Copyright © 2019 Rico Kristanto. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //preparing variables
    let captureSession = AVCaptureSession()
    var previewView = PreviewView()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput = AVCapturePhotoOutput()
    var outputImageView = UIImageView()
    
    //makethe status bar become light style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var dots : [UIView] = []
    var id = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ask  permision when we open the app
        askCameraPermission { (granted) in
            //if we grant  the permission
            if granted {
                // start setting view
                DispatchQueue.main.async {
                    self.setupView()
                }
            }
        }
        //start configuring  session
        DispatchQueue.global().async {
            self.configuringSession()
        }
        
        //start setup live preview and start session
        DispatchQueue.main.async {
            self.previewView.videoPreviewLayer.session = self.captureSession
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //when the view will disapper we stop the camera session
        self.captureSession.stopRunning()
    }
    func setupView() {
        //seting up the backgrtound color
        view.backgroundColor = .black
        
        //setting preview view for camera
        previewView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 650)
        view.addSubview(previewView)
        
        //setting button
        let xPosition = (UIScreen.main.bounds.width/2.0) - 40
        let yPosition = UIScreen.main.bounds.height - 170
        let buttonRect = CGRect(x: xPosition, y: yPosition, width: 80, height: 80)
        let buttonShoot = UIButton(frame: buttonRect)
        
        buttonShoot.backgroundColor = .white
        buttonShoot.layer.cornerRadius = buttonShoot.frame.width/2.0
        buttonShoot.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonShootDidTap))
        buttonShoot.addGestureRecognizer(tap)
        
        view.addSubview(buttonShoot)
        //show image for photo view
        outputImageView.frame = CGRect(x: (xPosition/2) - 25, y: yPosition+10, width: 50, height: 50)
        outputImageView.layer.borderColor = UIColor.gray.cgColor
        outputImageView.layer.borderWidth = 1
        outputImageView.layer.masksToBounds = true
        outputImageView.contentMode = .scaleAspectFill
        
        view.addSubview(outputImageView)
        
    }
    
    func  configuringSession() {
        //start to prepare tobegin the configuration
        captureSession.beginConfiguration()
        //preparing camera dewvice
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        //prepraring  the input forf session
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),captureSession.canAddInput(videoDeviceInput) else { return }
        
        captureSession.addInput(videoDeviceInput)
        //preparing the output of the session
        guard captureSession.canAddOutput(photoOutput) else {
            return
        }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        
        //commit configuration
        captureSession.commitConfiguration()
        
    }
    
    //handle button event when the button did tap
    @objc func buttonShootDidTap() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func askCameraPermission(completion: @escaping ((Bool)->Void)) {
        //ask for requet access for  video
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            //if user notgrant the permission remind user to reenable the camera fromsettings
            if !granted {
                let alert = UIAlertController(title: "Message", message: "If you want to use this feature please give permission  to open camera from  settings", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    completion(false)
                })
                alert.addAction(alertAction)
                self.present(alert,animated: true, completion: nil)
            } else {
                completion(true)
            }
        }
    }
}


//create4 view for placing the camera live preview
class PreviewView: UIView {
    override class var layerClass: AnyClass{
        return AVCaptureVideoPreviewLayer.self
    }
    
    //convenience wrapper to get layer as its statically known type
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    //handle photo that captured on the sssion
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        outputImageView.image = image
    }
    
}

