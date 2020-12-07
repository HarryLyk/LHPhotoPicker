//
//  PhotoSwiperControls.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 07.12.2020.
//

import UIKit

extension PhotoSwiperController {
    
    func setupSelectPhotoButtonConstraints() {
        btnSelectPhoto.translatesAutoresizingMaskIntoConstraints = false
        btnSelectPhoto.heightAnchor.constraint(equalToConstant: 25).isActive = true
        btnSelectPhoto.widthAnchor.constraint(equalToConstant: 25).isActive = true
        btnSelectPhoto.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        btnSelectPhoto.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
    }
    
    func setupMainButtonConstrains() {
        btnApply.translatesAutoresizingMaskIntoConstraints = false
        btnApply.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        btnApply.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnApply.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnApplyBottomAnchor = btnApply.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        btnApplyBottomAnchor.isActive = true
        
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        btnCancel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnCancelBottonAnchor = btnCancel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        btnCancelBottonAnchor.isActive = true
        
        btnCrop.translatesAutoresizingMaskIntoConstraints = false
        btnCrop.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnCrop.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnCrop.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        btnCropBottomAnchor = btnCrop.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        btnCropBottomAnchor.isActive = true
        
    }
    
    ///this button will appear after Edit button pressed. It's bottom constraints not allowing thise buttons to appear on start screen
    func setupEditButtonConstrains(){
        btnApplyEdit.translatesAutoresizingMaskIntoConstraints = false
        btnApplyEdit.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        btnApplyEdit.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnApplyEdit.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnApplyEditBottomAnchor = btnApplyEdit.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
        btnApplyEditBottomAnchor.isActive = true
        
        btnCancelEdit.translatesAutoresizingMaskIntoConstraints = false
        btnCancelEdit.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        btnCancelEdit.widthAnchor.constraint(equalToConstant: 80).isActive = true
        btnCancelEdit.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btnCancelEditBottomAnchor = btnCancelEdit.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
        btnCancelEditBottomAnchor.isActive = true
        
    }
    
    ///show edit buttons and hide main buttons
    func showEditButtonsWithAnimation() {
        btnApply.isUserInteractionEnabled = false
        btnCrop.isUserInteractionEnabled = false
        btnCancel.isUserInteractionEnabled = false
        btnApplyEdit.isUserInteractionEnabled = true
        btnCancelEdit.isUserInteractionEnabled = true
        
        
        btnApplyBottomAnchor.constant = 50
        btnCancelBottonAnchor.constant = 50
        btnCropBottomAnchor.constant = 50
        
        btnApplyEditBottomAnchor.constant = -30
        btnCancelEditBottomAnchor.constant = -30
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    ///show main buttons and hide edit buttons
    func showMainButtonsWithAnimation() {
        btnApply.isUserInteractionEnabled = true
        btnCrop.isUserInteractionEnabled = true
        btnCancel.isUserInteractionEnabled = true
        btnApplyEdit.isUserInteractionEnabled = false
        btnCancelEdit.isUserInteractionEnabled = false
        
        btnApplyBottomAnchor.constant = -30
        btnCancelBottonAnchor.constant = -30
        btnCropBottomAnchor.constant = -30
        
        btnApplyEditBottomAnchor.constant = 50
        btnCancelEditBottomAnchor.constant = 50
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

}
