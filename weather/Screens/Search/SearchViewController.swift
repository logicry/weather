//
//  SearchViewController.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import UIKit

class SearchViewController: UIViewController {
    private let viewModel = SearchLocationViewModel()
    private var searchController: UISearchController!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var onCityLocation: ((Location) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Find a city"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Helper
    
    // Later we'd make this a standalone helper
    private func keyboardFrameFromNotification(_ notification: Notification) -> CGRect {
        let info  = notification.userInfo!
        let value: AnyObject = info[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject
        
        let rawFrame = value.cgRectValue
        return view.convert(rawFrame!, from: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let keyboardFrame = keyboardFrameFromNotification(notification)
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
        
        scrollView.contentInset = contentInsets
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
    }
    
    // MARK: - IBAction
    
    @IBAction func onSearch(_ sender: Any) {
        cityTextField.resignFirstResponder()
        errorLabel.isHidden = true
        searchButton.isHidden = true
        spinner.startAnimating()
        
        Task { [weak self] in
            if let location = await self?.viewModel.getLocation(of: self?.cityTextField.text ?? "") {
                self?.onCityLocation?(location)
            } else {
                self?.errorLabel.isHidden = false
            }
            
            self?.spinner.stopAnimating()
            self?.searchButton.isHidden = false
        }
    }

}
