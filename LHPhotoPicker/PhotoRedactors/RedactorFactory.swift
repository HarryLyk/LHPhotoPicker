//
//  BaseRedactor.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 10.12.2020.
//

import UIKit

enum RedactorType {
    case crop
    case filter ///not used yet
}

class RedactorFactory {
    
    var redactorType: RedactorType
    var cropRedactor: CropRedactor?
    //var filterRedactor: FilterRedactor?
    
    deinit {
        print("RedactorFactory deinit was called ")
    }
    
    init(sourceController: UICollectionViewController, baseImage: UIImageView, redactorType: RedactorType){
        switch redactorType {
        case .crop:
            print("ask for crop redactor")
            self.redactorType = redactorType
            self.cropRedactor = CropRedactor(sourceController: sourceController, baseImage: baseImage)
        case .filter:
            self.redactorType = redactorType
            print("ask for filter redctor")
        }
    }
    
    func applyEdit() -> UIImageView? {
        switch redactorType {
        case .crop:
            return cropRedactor?.applyEdit()
        case .filter:
            print("filter redactor applyEdit")
            return nil
        }
    }
    
    func cancelEdit() {
        switch redactorType {
        case .crop:
            print("crop redactor cancel was called")
            cropRedactor?.cancelEdit()
        case .filter:
            print("filter redactor cancelEdit was called")
        }
    }
}
