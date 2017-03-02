//
//  ViewController.swift
//  MarioWorld
//
//  Created by Oleg Shulakov on 02.03.17.
//  Copyright © 2017 Oleg Shulakov. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader

class ViewController: UIViewController, QRCodeReaderViewControllerDelegate {
    
    @IBOutlet weak var buttonScan: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    private var configDict = Dictionary<String, Dictionary<String, AnyObject>>()
    
    var player : AVAudioPlayer! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: Dictionary<String, AnyObject>] {
            // use swift dictionary as normal
            self.configDict = dict
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.scanAction(self)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
    })
    
    @IBAction func scanAction(_ sender: AnyObject) {
        if player != nil {
            player.stop()
            player = nil
        }
        
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let value = result?.value {
                print(value)
                let image = UIImage(named: value)
                self.imageView.image = image
                
                if let dictImage = self.configDict[value] {
                    if let track = dictImage["track"] as? String {
                        let soundFilename = Bundle.main.path(forResource: track, ofType: nil)
                        if let soundFilenameUnwrapped = soundFilename {
                            let soundURL = URL.init(fileURLWithPath: soundFilenameUnwrapped)
                            do {
                                print(soundURL)
                                self.player = try AVAudioPlayer(contentsOf: soundURL)
                                self.player.play()
                            } catch {
                                print("error")
                            }
                        }
                        
                    }
                }
            }
            
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            print("Switching capturing to: \(cameraName)")
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
}

