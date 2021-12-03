//
//  MainViewController.swift
//  GSTCalculatror
//
//  Created by Anas Mansuri on 25/06/19.
//  Copyright © 2019 Anas Mansuri. All rights reserved.
//

import UIKit

enum VALIDATIONMESSAGE: String{
    case Amount = "Enter Amount"
    case GSTrate = "Enter GST"
}

class MainViewController: UIViewController {

    @IBOutlet weak var buttonGSTExclusive: UIButton!
    @IBOutlet weak var buttonGSTInclusive: UIButton!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtGSTrate: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblTypeofgstValue: UILabel!
    @IBOutlet weak var lblTotalGstAmount: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var lblFinalResultWithgst: UILabel!
    
    var activeTextField: UITextField? = nil
    var keyboardHeight: CGFloat = 216
    var isExclusive : Bool = false
    var isInclusive : Bool = false
    
    let autocompleteTableView =  UITableView(frame: CGRect(x: 10 , y: 350, width: UIScreen.main.bounds.size.width - 20 , height: 180), style: .plain)
    
    var gstrateArray = ["5%","12%","18%","28%"]
    var selectedGSTRate :String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addKeyboardNotifications()
    }
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupUI(){
        txtAmount.delegate = self
        txtGSTrate.delegate = self
        
        txtAmount.tag = 1001
        txtGSTrate.tag = 1002
        
        buttonGSTInclusive.isSelected = true
        buttonGSTInclusive.setImage(UIImage(named: "ic_radio_selected"), for: .normal)
        
        selectedGSTRate = ""
        resultView.isHidden = true
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.isHidden = true
        autocompleteTableView.layer.borderWidth = 1.0
        autocompleteTableView.layer.borderColor = UIColor.darkText.cgColor
        self.view.addSubview(autocompleteTableView)
        autocompleteTableView.register(UINib(nibName: "AutosuggestTableCell", bundle: Bundle.main), forCellReuseIdentifier: "AutosuggestTableCell")
    }

    
    //MARK:- validation
    func validate() -> String? {
        var validationMessage : String?
        
        if txtAmount.text!.isEmpty {
            validationMessage = NSLocalizedString(VALIDATIONMESSAGE.Amount.rawValue, comment: "")
        }else if txtGSTrate.text!.isEmpty {
            validationMessage = NSLocalizedString(VALIDATIONMESSAGE.GSTrate.rawValue, comment: "")
        }

        return validationMessage
    }
    
    func showErrorAlertView(_ message : String) {
        showAlertView(message, title: "Validation Error")
    }
    
    func showAlertView(_ message : String, title : String = "GST Calculator") {
        let alert = UIAlertController(title: title, message: message, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- GST CALCULATION FUNCTIONS
    
    /* Formula GST With Exclusion Amount*/
    //    GST Amount = ( Original Cost * GST% ) / 100
    //    Net Price = Original Cost + GST Amount
    
    func calculateGSTPriceExculsion(amount:String, gstvalue:String){
        guard let amountDouble = Double(amount)else{return}
        guard let gstDouble = Double(gstvalue) else{return}
        
        let gstPrice = String((amountDouble * gstDouble) / 100)
        
        if let doubleValue = Double(gstPrice){
            
            let gstAmount = String(format: "%.2f",doubleValue)
            lblTotalGstAmount.text = "₹" + gstAmount
            
            let finalAmount = String(Double(amountDouble) + Double(doubleValue))
            guard let finlaAmountDouble = Double(finalAmount)else{return}
            let finalAmountStr = String(format: "%.2f",finlaAmountDouble)
            if let tempVal = Double(finalAmountStr){
                lblFinalResultWithgst.text = "₹" + String(format: "%.2f",round(tempVal)) //String(round(tempVal))
            }
            lblTypeofgstValue.text = "Post-GST Amount"
        }
        
        resultView.isHidden = false
    }
    
     /* Formula GST With Inculusin of GST Amount*/
     // GST Amount = Original Cost – (Original Cost * (100 / (100 + GST% ) ) )
    // Net Price = Original Cost – GST Amount
    func calculateGSTPriceWithInculsion(amount:String, gstvalue:String){
        guard let amountDouble = Double(amount)else{return}
        guard let gstDouble = Double(gstvalue) else{return}
        
        let multiplyValue = String (amountDouble * (100 / (100 + gstDouble)))
        
        guard let multiplyDouble = Double(multiplyValue)else{return}
        let amountSubstract = String (amountDouble - multiplyDouble)
        
        if let doubleValue = Double(amountSubstract){
            
            let gstAmount = String(format: "%.2f",doubleValue)
            lblTotalGstAmount.text = "₹ " + gstAmount
            
            let finalAmount = String(Double(amountDouble) - Double(doubleValue))
            guard let finlaAmountDouble = Double(finalAmount)else{return}
            let finalAmountStr = String(format: "%.2f",finlaAmountDouble)
            
            lblFinalResultWithgst.text = "₹ " + finalAmountStr
            lblTypeofgstValue.text = "Pre-GST Amount"
        }
        
        resultView.isHidden = false
    }
    
    
    //MARK:- Actions
    
    @IBAction func buttonGSTEXclusive_clicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            buttonGSTExclusive.setImage(UIImage(named: "ic_radio_selected"), for: .normal)
            buttonGSTInclusive.setImage(UIImage(named: "ic_radio_unselected"), for: .normal)
            isExclusive = true
            isInclusive = false
        }else{
            buttonGSTExclusive.setImage(UIImage(named: "ic_radio_unselected"), for: .normal)
            isExclusive = false
            isInclusive = false
        }
        resultView.isHidden = true
    }
    
    
    @IBAction func buttonInclusive_clicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            buttonGSTInclusive.setImage(UIImage(named: "ic_radio_selected"), for: .normal)
            buttonGSTExclusive.setImage(UIImage(named: "ic_radio_unselected"), for: .normal)
            isExclusive = false
            isInclusive = true
        }else{
            buttonGSTInclusive.setImage(UIImage(named: "ic_radio_unselected"), for: .normal)
            isExclusive = false
            isInclusive = false
        }
        resultView.isHidden = true
    }
    
    @IBAction func buttonCalculate_clikced(_ sender: UIButton) {
        if let validationMessage = validate() {
            showErrorAlertView(validationMessage)
        }else{
            let gstval = selectedGSTRate.replacingOccurrences(of: "%", with: "")
            if isExclusive{
                calculateGSTPriceExculsion(amount: txtAmount.text!, gstvalue: gstval)
            }else if isInclusive {
                calculateGSTPriceWithInculsion(amount: txtAmount.text!, gstvalue: gstval)
            }else{
                calculateGSTPriceWithInculsion(amount: txtAmount.text!, gstvalue: gstval)
            }
        }
    }
}


extension MainViewController: UITextFieldDelegate {
   
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1002{
            self.view.endEditing(true)
            autocompleteTableView.isHidden = false
            self.view.bringSubviewToFront(autocompleteTableView)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        self.view.endEditing(true)
        autocompleteTableView.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn:"0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = activeTextField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height , right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
    }
}


extension MainViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gstrateArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let autoCompleteRowIdentifier = "AutosuggestTableCell"
        let cell = autocompleteTableView.dequeueReusableCell(withIdentifier: autoCompleteRowIdentifier, for: indexPath) as! AutosuggestTableCell
        cell.lblgstrate.text = gstrateArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGSTRate = gstrateArray[indexPath.row]
        txtGSTrate.text = selectedGSTRate
        autocompleteTableView.isHidden = true
    }
}

