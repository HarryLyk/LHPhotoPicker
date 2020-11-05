//
//  PhotoSelectionViewModel.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 05.11.2020.
//

import Foundation
import RxSwift
import RxCocoa

class PhotoSelectionViewModel {
    
    ///this flag is true, cause we are trying to load photoes by default
    var isLoading: BehaviorRelay<Bool> = .init(value: true)
    
    private var disposeBag = DisposeBag()
    
    ///load photoes from local storage
    func loadPhotos() {
        
        //don't forget to check if user give us acces to load photoes
        
        //load photoes with error checking
    }
}
