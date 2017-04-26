//
//  CameraController.swift
//  DemoCI
//
//  Created by Wizard Li on 5/30/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import AVFoundation
import UIKit
import GLKit

let CameraControllerDidStartSession = "CameraControllerDidStartSession"
let CameraControllerDidStopSession = "CameraControllerDidStopSession"

let CameraControlObservableSettingLensPosition = "CameraControlObservableSettingLensPosition"
let CameraControlObservableSettingExposureTargetOffset = "CameraControlObservableSettingExposureTargetOffset"
let CameraControlObservableSettingExposureDuration = "CameraControlObservableSettingExposureDuration"
let CameraControlObservableSettingISO = "CameraControlObservableSettingISO"
let CameraControlObservableSettingWBGains = "CameraControlObservableSettingWBGains"
let CameraControlObservableSettingAdjustingFocus = "CameraControlObservableSettingAdjustingFocus"
let CameraControlObservableSettingAdjustingExposure = "CameraControlObservableSettingAdjustingExposure"
let CameraControlObservableSettingAdjustingWhiteBalance = "CameraControlObservableSettingAdjustingWhiteBalance"

protocol CameraControllerDelegate : class {
    func cameraController(_ cameraController:CameraController, didDetectFaces faces:Array<(id:Int,frame:CGRect)>)
    func cameraContorller(_ cameraController:CameraController, didOutputImage image: CIImage)
}

enum CameraControllePreviewType {
    case previewLayer
    case manual
}

@objc protocol CameraSettingValueObserver {
    func cameraSetting(_ setting:String, valueChanged value:AnyObject)
}

extension AVCaptureWhiteBalanceGains {
    mutating func clampGainsToRange(_ minVal:Float, maxVal:Float) {
        blueGain = max(min(blueGain, maxVal), minVal)
        redGain = max(min(redGain, maxVal), minVal)
        greenGain = max(min(greenGain, maxVal), minVal)
    }
}

class WhiteBalanceValues {
    let temperature:Float
    let tint:Float
    
    init(temperature:Float, tint:Float) {
        self.temperature = temperature
        self.tint = tint
    }
    
    convenience init(temperatureAndTintValues:AVCaptureWhiteBalanceTemperatureAndTintValues) {
        self.init(temperature: temperatureAndTintValues.temperature, tint:temperatureAndTintValues.tint)
    }
}

class CameraController: NSObject {
    
    weak var delegate:CameraControllerDelegate?
    var previewType:CameraControllePreviewType
    
    var previewLayer:AVCaptureVideoPreviewLayer?
    
    var enableBracketedCapture:Bool = false {
        didSet {
            // TODO: if true, prepare for capture
        }
    }
    
    // MARK: Private properties
    
    fileprivate var sessionQueue:DispatchQueue = DispatchQueue(label: "com.example.session_access_queue", attributes: [])
    
    fileprivate var session:AVCaptureSession!
    fileprivate var currentCameraDevice:AVCaptureDevice!
    
    fileprivate var backCameraDevice:AVCaptureDevice?
    fileprivate var frontCameraDevice:AVCaptureDevice?
    
    fileprivate var stillCameraOutput:AVCaptureStillImageOutput!
    fileprivate var videoOutput:AVCaptureVideoDataOutput!
    fileprivate var metadataOutput:AVCaptureMetadataOutput!
    
    fileprivate var lensPositionContext = 0
    fileprivate var adjustingFocusContext = 0
    fileprivate var adjustingExposureContext = 0
    fileprivate var adjustingWhiteBalanceContext = 0
    fileprivate var exposureDuration = 0
    fileprivate var ISO = 0
    fileprivate var exposureTargetOffsetContext = 0
    fileprivate var deviceWhiteBalanceGainsContext = 0
    
    fileprivate var controlObservers = [String: [AnyObject]]()
    
    // MARK: - Initialization
    
    required init(previewType:CameraControllePreviewType, delegate:CameraControllerDelegate) {
        self.delegate = delegate
        self.previewType = previewType
        
        super.init()
        
        initializeSession()
    }
    
    convenience init(delegate:CameraControllerDelegate) {
        self.init(previewType: .previewLayer, delegate: delegate)
    }
    
    
    func initializeSession() {
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        if previewType == .previewLayer {
            previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        }
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(
                forMediaType: AVMediaTypeVideo,
                completionHandler: { granted in
                    if granted {
                        self.configureSession()
                    }
                    else {
                        self.showAccessDeniedMessage()
                    }
                }
            )
        case .authorized:
            configureSession()
        case .denied, .restricted:
            showAccessDeniedMessage()
        }
    }
    
    // MARK: - Camera Control
    
    func startRunning() {
        performConfiguration {
            self.observeValues()
            self.session.startRunning()
            NotificationCenter.default.post(name: Notification.Name(rawValue: CameraControllerDidStartSession), object: self)
        }
    }
    
    func stopRunning() {
        performConfiguration {
            self.unobserveValues()
            self.session.stopRunning()
        }
    }
    
    func registerObserver<T>(_ observer:T, property:String) where T:NSObject, T:CameraSettingValueObserver {
        var propertyObservers = controlObservers[property]
        if propertyObservers == nil {
            propertyObservers = [AnyObject]()
        }
        
        propertyObservers?.append(observer)
        controlObservers[property] = propertyObservers
    }
    
    func unregisterObserver<T>(_ observer:T, property:String) where T:NSObject, T:CameraSettingValueObserver {
        if let propertyObservers = controlObservers[property] {
            let filteredPropertyObservers = propertyObservers.filter {
                ($0 as! NSObject) != observer
            }
            controlObservers[property] = filteredPropertyObservers
        }
    }
    
    // MARK: Focus
    
    func enableContinuousAutoFocus() {
        performConfigurationOnCurrentCameraDevice { currentDevice in
            if currentDevice.isFocusModeSupported(.continuousAutoFocus) {
                currentDevice.focusMode = .continuousAutoFocus
            }
        }
    }
    
    func isContinuousAutoFocusEnabled() -> Bool {
        return currentCameraDevice!.focusMode == .continuousAutoFocus
    }
    
    func lockFocusAtPointOfInterest(_ pointInView:CGPoint) {
        let pointInCamera = previewLayer!.captureDevicePointOfInterest(for: pointInView)
        performConfigurationOnCurrentCameraDevice { currentDevice in
            if currentDevice.isFocusPointOfInterestSupported {
                currentDevice.focusPointOfInterest = pointInCamera
                currentDevice.focusMode = .autoFocus
            }
        }
    }
    
    func lockFocusAtLensPosition(_ lensPosition:CGFloat) {
        performConfigurationOnCurrentCameraDevice { currentDevice in
            currentDevice.setFocusModeLockedWithLensPosition(Float(lensPosition)) { _ in }
        }
    }
    
    func currentLensPosition() -> Float? {
        return self.currentCameraDevice?.lensPosition
    }
    
    // MARK: Exposure
    
    func enableContinuousAutoExposure() {
        performConfigurationOnCurrentCameraDevice { currentDevice in
            if currentDevice.isExposureModeSupported(.continuousAutoExposure) {
                currentDevice.exposureMode = .continuousAutoExposure
            }
        }
    }
    
    func isContinuousAutoExposureEnabled() -> Bool {
        return currentCameraDevice!.exposureMode == .continuousAutoExposure
    }
    
    func lockExposureAtPointOfInterest(_ pointInView:CGPoint) {
        let pointInCamera = previewLayer!.captureDevicePointOfInterest(for: pointInView)
        performConfigurationOnCurrentCameraDevice { currentDevice in
            if currentDevice.isExposurePointOfInterestSupported {
                currentDevice.exposurePointOfInterest = pointInCamera
                currentDevice.exposureMode = .autoExpose
            }
        }
    }
    
    func setCustomExposureWithISO(_ iso:Float) {
        performConfigurationOnCurrentCameraDevice { currentDevice in
            currentDevice.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, iso: iso, completionHandler: nil)
        }
    }
    
    func setCustomExposureWithDuration(_ duration:Float) {
        performConfigurationOnCurrentCameraDevice { currentDevice in
            let activeFormat = currentDevice.activeFormat
            let finalDuration = CMTimeMakeWithSeconds(Float64(duration), 1_000_000)
            let durationRange = CMTimeRangeFromTimeToTime((activeFormat?.minExposureDuration)!, (activeFormat?.maxExposureDuration)!)
            
            if CMTimeRangeContainsTime(durationRange, finalDuration) {
                currentDevice.setExposureModeCustomWithDuration(finalDuration, iso: AVCaptureISOCurrent, completionHandler: nil)
            }
        }
    }
    
    func setExposureTargetBias(_ bias:Float) {
        performConfigurationOnCurrentCameraDevice { currentDevice in
            currentDevice.setExposureTargetBias(bias, completionHandler: nil)
        }
    }
    
    func currentExposureDuration() -> Float? {
        guard let exposureDuration = currentCameraDevice?.exposureDuration else { return nil }
        return Float(CMTimeGetSeconds(exposureDuration))
    }
    
    func currentISO() -> Float? {
        return currentCameraDevice?.iso
    }
    
    func currentExposureTargetOffset() -> Float? {
        return currentCameraDevice?.exposureTargetOffset
    }
    
    // MARK: White balance
    
    func enableContinuousAutoWhiteBalance() {
        performConfigurationOnCurrentCameraDevice { (currentDevice) in
            if currentDevice.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                currentDevice.whiteBalanceMode = .continuousAutoWhiteBalance
            }
        }
    }
    
    func isContinuousAutoWhiteBalanceEnabled() -> Bool {
        return currentCameraDevice!.whiteBalanceMode == .continuousAutoWhiteBalance
    }
    
    func setCustomWhiteBalanceWithTemperature(_ temperature:Float) {
        
        performConfigurationOnCurrentCameraDevice { (currentDevice) in
            if currentDevice.isWhiteBalanceModeSupported(.locked) {
                let currentGains = currentDevice.deviceWhiteBalanceGains
                let currentTint = currentDevice.temperatureAndTintValues(forDeviceWhiteBalanceGains: currentGains).tint
                let temperatureAndTintValues = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: temperature, tint: currentTint)
                
                var deviceGains = currentDevice.deviceWhiteBalanceGains(for: temperatureAndTintValues)
                let maxWhiteBalanceGain = currentDevice.maxWhiteBalanceGain
                deviceGains.clampGainsToRange(1, maxVal: maxWhiteBalanceGain)
                
                currentDevice.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(deviceGains) {
                    (timestamp:CMTime) -> Void in
                }
            }
        }
    }
    
    func setCustomWhiteBalanceWithTint(_ tint:Float) {
        
        performConfigurationOnCurrentCameraDevice { (currentDevice) in
            if currentDevice.isWhiteBalanceModeSupported(.locked) {
                let maxWhiteBalanceGain = currentDevice.maxWhiteBalanceGain
                var currentGains = currentDevice.deviceWhiteBalanceGains
                currentGains.clampGainsToRange(1, maxVal: maxWhiteBalanceGain)
                let currentTemperature = currentDevice.temperatureAndTintValues(forDeviceWhiteBalanceGains: currentGains).temperature
                let temperatureAndTintValues = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: currentTemperature, tint: tint)
                
                var deviceGains = currentDevice.deviceWhiteBalanceGains(for: temperatureAndTintValues)
                deviceGains.clampGainsToRange(1, maxVal: maxWhiteBalanceGain)
                
                currentDevice.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(deviceGains) {
                    (timestamp:CMTime) -> Void in
                }
            }
        }
    }
    
    func currentTemperature() -> Float? {
        guard let gains = currentCameraDevice?.deviceWhiteBalanceGains else { return nil }
        
        let tempAndTint = currentCameraDevice?.temperatureAndTintValues(forDeviceWhiteBalanceGains: gains)
        return tempAndTint?.temperature
    }
    
    
    func currentTint() -> Float? {
        guard let gains = currentCameraDevice?.deviceWhiteBalanceGains else { return nil }
        let tempAndTint = currentCameraDevice?.temperatureAndTintValues(forDeviceWhiteBalanceGains: gains)
        return tempAndTint?.tint
    }
    
    // MARK: Still image capture
    
    func captureStillImage(completionHandler handler:@escaping ((_ image:UIImage, _ metadata:NSDictionary) -> Void)) {
        if enableBracketedCapture {
            bracketedCaptureStillImage(completionHandler:handler);
        }
        else {
            captureSingleStillImage(completionHandler:handler)
        }
    }
    
    /*!
     Capture a photo
     
     :param: handler executed on the main queue
     */
    func captureSingleStillImage(completionHandler handler: @escaping ((_ image:UIImage, _ metadata:NSDictionary) -> Void)) {
        
        sessionQueue.async {
            
            let connection = self.stillCameraOutput.connection(withMediaType: AVMediaTypeVideo)
            
            connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            
            self.stillCameraOutput.captureStillImageAsynchronously(from: connection) {
                (imageDataSampleBuffer, error) in
                
                if error == nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                    
                    let _metadata = CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer!, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate)) as NSDictionary?
                    
                    if let image = UIImage(data: imageData!),
                        let metadata = _metadata {
                        DispatchQueue.main.async { () -> Void in
                            handler(image, metadata)
                        }
                    }
                }
                else {
                    print("error while capturing still image: \(error)")
                }
            }
        }
    }
    
    func bracketedCaptureStillImage(completionHandler handler: @escaping ((_ image:UIImage, _ metadata:NSDictionary) -> Void)) {
        sessionQueue.async {
            
            let connection = self.stillCameraOutput.connection(withMediaType: AVMediaTypeVideo)
            connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            
            let settings = [-1.0, 0.0, 1.0].map { bias in
                AVCaptureAutoExposureBracketedStillImageSettings.autoExposureSettings(withExposureTargetBias: bias)
            }
            
            self.stillCameraOutput.captureStillImageBracketAsynchronously(from: connection, withSettingsArray: settings, completionHandler: {
                (sampleBuffer, captureSettings, error) -> Void in
                
                // TODO: stitch images
                
                if error == nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    
                    let _metadata = CMCopyDictionaryOfAttachments(nil, sampleBuffer!, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate)) as NSDictionary?
                    
                    if let image = UIImage(data: imageData!),
                        let metadata = _metadata {
                        DispatchQueue.main.async { () -> Void in
                            handler(image, metadata)
                        }
                    }
                }
                else {
                    NSLog("error while capturing still image: \(error)")
                }
            })
        }
    }
    
    
    // MARK: - Notifications
    
    func subjectAreaDidChange(_ notification:Notification) {
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        var key = ""
        guard let change = change,
            var newValue = change[NSKeyValueChangeKey.newKey]
            else { return }
        
        switch context {
        case .some(&lensPositionContext):
            key = CameraControlObservableSettingLensPosition
            
        case .some(&exposureDuration):
            key = CameraControlObservableSettingExposureDuration
            
        case .some(&ISO):
            key = CameraControlObservableSettingISO
            
        case .some(&deviceWhiteBalanceGainsContext):
            key = CameraControlObservableSettingWBGains
            
            if let newNSValue = newValue as? NSValue {
                var gains:AVCaptureWhiteBalanceGains? = nil
                newNSValue.getValue(&gains)
                if let gains = gains,
                    let newTemperatureAndTint = currentCameraDevice?.temperatureAndTintValues(forDeviceWhiteBalanceGains: gains) {
                    newValue = WhiteBalanceValues(temperatureAndTintValues: newTemperatureAndTint)
                }
            }
        case .some(&adjustingFocusContext):
            key = CameraControlObservableSettingAdjustingFocus
        case .some(&adjustingExposureContext):
            key = CameraControlObservableSettingAdjustingExposure
        case .some(&adjustingWhiteBalanceContext):
            key = CameraControlObservableSettingAdjustingWhiteBalance
        default:
            key = "unknown context"
        }
        
        notifyObservers(key, value: newValue as AnyObject)
    }
}

// MARK: - Delegate methods

extension CameraController: AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        self.delegate?.cameraContorller(self, didOutputImage: image)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        var faces = Array<(id:Int,frame:CGRect)>()
        
        for metadataObject in metadataObjects as! [AVMetadataObject] {
            if metadataObject.type == AVMetadataObjectTypeFace {
                if let faceObject = metadataObject as? AVMetadataFaceObject {
                    let transformedMetadataObject = previewLayer!.transformedMetadataObject(for: metadataObject)
                    let face:(id: Int, frame: CGRect) = (faceObject.faceID, transformedMetadataObject!.bounds)
                    faces.append(face)
                }
            }
        }
        
        if let delegate = self.delegate {
            DispatchQueue.main.async {
                delegate.cameraController(self, didDetectFaces: faces)
            }
        }
    }
}



// MARK: - Private

private extension CameraController {
    
    func performConfiguration(_ block: @escaping (() -> Void)) {
        sessionQueue.async { () -> Void in
            block()
        }
    }
    
    func performConfigurationOnCurrentCameraDevice(_ block: @escaping ((_ currentDevice:AVCaptureDevice) -> Void)) {
        if let currentDevice = self.currentCameraDevice {
            performConfiguration { () -> Void in
                var error:NSError?
                do {
                    try currentDevice.lockForConfiguration()
                    block(currentDevice)
                    currentDevice.unlockForConfiguration()
                } catch let error1 as NSError {
                    error = error1
                    print("\(String(describing: error))")
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    func configureSession() {
        configureDeviceInput()
        configureStillImageCameraOutput()
        configureFaceDetection()
        
        if previewType == .manual {
            configureVideoOutput()
        }
    }
    
    func configureDeviceInput() {
        
        performConfiguration { () -> Void in
            
            let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            for device in availableCameraDevices as! [AVCaptureDevice] {
                if device.position == .back {
                    self.backCameraDevice = device
                }
                else if device.position == .front {
                    self.frontCameraDevice = device
                }
            }
            
            
            // let's set the back camera as the initial device
            
            self.currentCameraDevice = self.backCameraDevice
            var error:NSError?
            
            let possibleCameraInput: AnyObject?
            do {
                possibleCameraInput = try AVCaptureDeviceInput(device: self.currentCameraDevice)
            } catch let error1 as NSError {
                error = error1
                possibleCameraInput = nil
                print("\(error)")
            } catch {
                fatalError()
            }
            if let backCameraInput = possibleCameraInput as? AVCaptureDeviceInput {
                if self.session.canAddInput(backCameraInput) {
                    self.session.addInput(backCameraInput)
                }
            }
        }
    }
    
    func configureStillImageCameraOutput() {
        performConfiguration { () -> Void in
            self.stillCameraOutput = AVCaptureStillImageOutput()
            self.stillCameraOutput.outputSettings = [
                AVVideoCodecKey  : AVVideoCodecJPEG,
                AVVideoQualityKey: 0.9
            ]
            
            if self.session.canAddOutput(self.stillCameraOutput) {
                self.session.addOutput(self.stillCameraOutput)
            }
        }
    }
    
    func configureVideoOutput() {
        performConfiguration { () -> Void in
            self.videoOutput = AVCaptureVideoDataOutput()
            self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }
        }
    }
    
    func configureFaceDetection() {
        performConfiguration { () -> Void in
            self.metadataOutput = AVCaptureMetadataOutput()
            self.metadataOutput.setMetadataObjectsDelegate(self, queue: self.sessionQueue)
            
            if self.session.canAddOutput(self.metadataOutput) {
                self.session.addOutput(self.metadataOutput)
            }
            
            if (self.metadataOutput.availableMetadataObjectTypes as! [String]).contains(AVMetadataObjectTypeFace) {
                self.metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
            }
        }
    }
    
    func observeValues() {
        currentCameraDevice?.addObserver(self, forKeyPath: "lensPosition", options: .new, context: &lensPositionContext)
        currentCameraDevice?.addObserver(self, forKeyPath: "adjustingFocus", options: .new, context: &adjustingFocusContext)
        currentCameraDevice?.addObserver(self, forKeyPath: "adjustingExposure", options: .new, context: &adjustingExposureContext)
        currentCameraDevice?.addObserver(self, forKeyPath: "adjustingWhiteBalance", options: .new, context: &adjustingWhiteBalanceContext)
        currentCameraDevice?.addObserver(self, forKeyPath: "exposureDuration", options: .new, context: &exposureDuration)
        currentCameraDevice?.addObserver(self, forKeyPath: "ISO", options: .new, context: &ISO)
        currentCameraDevice?.addObserver(self, forKeyPath: "deviceWhiteBalanceGains", options: .new, context: &deviceWhiteBalanceGainsContext)
    }
    
    func unobserveValues() {
        currentCameraDevice?.removeObserver(self, forKeyPath: "lensPosition", context: &lensPositionContext)
        currentCameraDevice?.removeObserver(self, forKeyPath: "adjustingFocus", context: &adjustingFocusContext)
        currentCameraDevice?.removeObserver(self, forKeyPath: "adjustingExposure", context: &adjustingExposureContext)
        currentCameraDevice?.removeObserver(self, forKeyPath: "adjustingWhiteBalance", context: &adjustingWhiteBalanceContext)
        currentCameraDevice?.removeObserver(self, forKeyPath: "exposureDuration", context: &exposureDuration)
        currentCameraDevice?.removeObserver(self, forKeyPath: "ISO", context: &ISO)
        currentCameraDevice?.removeObserver(self, forKeyPath: "deviceWhiteBalanceGains", context: &deviceWhiteBalanceGainsContext)
    }
    
    func showAccessDeniedMessage() {
    }
    
    func notifyObservers(_ key:String, value:AnyObject) {
        if let lensPositionObservers = controlObservers[key] {
            for obj in lensPositionObservers as [AnyObject] {
                if let observer = obj as? CameraSettingValueObserver {
                    notifyObserver(observer, setting: key, value: value)
                }
            }
        }
    }
    
    
    func notifyObserver<T>(_ observer:T, setting:String, value:AnyObject) where T:CameraSettingValueObserver {
        observer.cameraSetting(setting, valueChanged: value)
    }
}

