//
//  addCharacterViewController.swift
//  MWU
//
//  Created by Abe on R 4/02/24.
//  Copyright © Reiwa 4 Kyushu Sangyo University. All rights reserved.
//

import UIKit
import PhotosUI

class AddCharacterViewController: UIViewController {
    
    @IBOutlet weak var characterImageView: UIImageView!
    var cancelButton: UIBarButtonItem!
    
    private lazy var picker: PHPickerViewController = {
            var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            configuration.filter = .images
            configuration.selectionLimit = 1
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            return picker
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(cancelButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        // フォトライブラリを表示
        present(picker, animated: true, completion: nil)
    }
    
    @objc
    func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesButton(_ sender: UIButton) {
        
    }
    
    @IBAction func retryButton(_ sender: UIButton) {
        present(picker, animated: true, completion: nil)
    }
    
    
}

extension AddCharacterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 画像が選択されたらPickerを閉じて，選択した画像を反映
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] item, error in
                if error != nil {
                    print("error.localizedDescription")
                } else if let image = item as? UIImage {
                    DispatchQueue.main.async {
                        self?.characterImageView.image = image
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
}
