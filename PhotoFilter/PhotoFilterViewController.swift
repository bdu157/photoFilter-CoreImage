//
//  ViewController.swift
//  PhotoFilter
//
//  Created by Dongwoo Pae on 9/18/19.
//  Copyright © 2019 Dongwoo Pae. All rights reserved.
//

import UIKit
import Photos

class PhotoFilterViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    
    // MARK - properties
    
    //we can do this in background thread so it wont hinder main ui update
    var originalimage: UIImage? {
        didSet {
            guard let originalImage = self.originalimage else {return} //once we selected image we run it
            
            //height and width
            var scaledSize = imageView.bounds.size
            
            // 1x, 2x, 3x(10x max)
            let scale = UIScreen.main.scale  //screen size
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            self.scaledImage = originalImage.imageByScaling(toSize: scaledSize) //when originalimage gets available then make scaledImage
        }
    }
    
    var scaledImage: UIImage? {
        didSet {
            self.updateImage()
        }
    }
    
    private let context = CIContext(options: nil)
    private let filter = CIFilter(name: "CIColorControls")!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - IBAction
    @IBAction func choosePhoto(_ sender: Any) {
        self.presentImagePickerController()
    }
    
    @IBAction func changeBrightness(_ sender: Any) {
        self.updateImage()
    }
    
    @IBAction func changeContrast(_ sender: Any) {
        self.updateImage()
    }
    
    @IBAction func changeSaturation(_ sender: Any) {
        self.updateImage()
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        //we are using original to filter
        guard let originalImage = originalimage else {return}
        let processedImage = self.image(byFiltering: originalImage)
        
        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else {return}
        }
        
        //let the library know we are going to make changes
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAsset(from: processedImage)
        }) { (success, error) in
            if let error = error {
                NSLog("error:\(error)")
                return
            }
            DispatchQueue.main.async {
                //call the alert for sucessfully saving the filtered image
                self.presentSuccessfulSaveAlert()
            }
        }
    }
    
    // MARK: - Private functions/methods
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
            else {
                NSLog("no library")
                return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func image(byFiltering image: UIImage) -> UIImage {
        
        //uiimage -> cgimage -> ciimage
        guard let cgImage = image.cgImage else {return image}
        let ciImage = CIImage(cgImage: cgImage)
        
        //Set the values of the filter's paremeters
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(saturationSlider.value, forKey: "inputSaturation")
        filter.setValue(brightnessSlider.value, forKey: "inputBrightness")
        filter.setValue(contrastSlider.value, forKey: "inputContrast")
        
        // the metadata to be processed. not the actual filtered image
        //ciimage -> cgimage -> uiimage
        guard let outputCIImage = filter.outputImage else {return image}
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {return image}
        return UIImage(cgImage: outputCGImage)
    }
    
    
    //changed it to scaled image
    private func updateImage() {
        if let scaledImage = self.scaledImage {
            imageView.image = self.image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    
    private func presentSuccessfulSaveAlert() {
        let alert = UIAlertController(title: "saved", message: "the image is being saved", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.originalimage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//main take away
/*
 1. knowing how to use documentation for coreimage documentation
 2. convert between uiimage and ciimage
 3. being able to coreimage filter to images
 4. being able to connect to uicontrols (all sliders set up) that call our filter function
 */

