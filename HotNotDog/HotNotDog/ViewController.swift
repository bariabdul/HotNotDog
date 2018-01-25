//
//  ViewController.swift
//  HotNotDog
//
//  Created by Bari Abdul on 1/24/18.
//  Copyright © 2018 Bari Abdul. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBAction func cameraTapped(_ sender: Any) {
       present(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        //imagePicker.sourceType = .photoLibrary //for phones local photos
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
           imageView.image = userPickedImage
           
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert image to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) {(request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process the image")
            }
            //print(results)
            if let first = results.first {
                if first.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hot Dog!"
                } else {
                    self.navigationItem.title = "Not Hod Dog!"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try! handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

