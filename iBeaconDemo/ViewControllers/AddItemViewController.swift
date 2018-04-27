//
//  AddItemViewController.swift
//  iBeaconDemo
//
//  Created by 曹雪松 on 2018/4/27.
//  Copyright © 2018 曹雪松. All rights reserved.
//

import UIKit

protocol AddBeacon {
    func addBeacon(item: Item)
}

class AddItemViewController: UIViewController {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtUUID: UITextField!
    @IBOutlet weak var txtMajor: UITextField!
    @IBOutlet weak var txtMinor: UITextField!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var btnAdd: UIButton!
    
    var delegate: AddBeacon?
    let allIcons = Icons.allIcons
    var icon = Icons.bag // 选中图标
    
    let uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 默认设置
        btnAdd.isEnabled = false
        imgIcon.image = icon.image()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        view.endEditing(true)
    }

    /// 输入框编辑结束 控制控件状态
    ///
    /// - Parameter sender: 输入框
    @IBAction func textFieldEditingChanged(_ sender: UITextField)
    {
        let nameValid = (txtName.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0)
        var uuidValid = false
        let uuidString = txtUUID.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if uuidString.count > 0 {
            uuidValid = (uuidRegex.numberOfMatches(in: uuidString, options: [], range: NSMakeRange(0, uuidString.count)) > 0)
        }
        txtUUID.textColor = uuidValid ? .black : .red
        btnAdd.isEnabled = (nameValid && uuidValid)
    }
    
    @IBAction func btnAdd_Pressed(_ sender: UIButton)
    {
        let uuidString = txtUUID.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let uuid = UUID(uuidString: uuidString) else { return }
        let major = Int(txtMajor.text!) ?? 0
        let minor = Int(txtMinor.text!) ?? 0
        let name = txtName.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let newItem = Item(name: name, icon: icon.rawValue, uuid: uuid, majorValue: major, minorValue: minor)
        // 通知代理
        delegate?.addBeacon(item: newItem)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCancel_Pressed(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
}

extension AddItemViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        icon = Icons.icon(forTag: indexPath.row)
        imgIcon.image = icon.image()
    }
}

extension AddItemViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return allIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconCell
        cell.icon = allIcons[indexPath.row]
        return cell
    }
}

extension AddItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
