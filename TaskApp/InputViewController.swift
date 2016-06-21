//
//  inputViewController.swift
//  TaskApp
//
//  Created by 上村 宙生 on 2016/06/20.
//  Copyright © 2016年 huemura. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    var task:Task!
    
    var categoryAry:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:"dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
        
        //カテゴリ一覧取得
        getAllCategory()
        
        var pickerView = UIPickerView()
        pickerView.delegate = self
        categoryTextField.inputView = pickerView
        
        titleTextField.text = task.title
//        categoryTextField.text = task.category
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
//            self.task.category = self.categoryTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
        
        setNotification(task)
        
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // タスクのローカル通知を設定する
    func setNotification(task: Task) {
        
        // すでに同じタスクが登録されていたらキャンセルする
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
            if notification.userInfo!["id"] as! Int == task.id {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                break   // breakに来るとforループから抜け出せる
            }
        }
        
        let notification = UILocalNotification()
        
        notification.fireDate = task.date
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "\(task.title)"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["id":task.id]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryAry.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryAry[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categoryAry[row]
    }
    
    func getAllCategory() {
        for _category in try! Realm().objects(Category).sorted("id", ascending: false) {
            print(categoryAry)
            print(_category.name)
            categoryAry.append(_category.name)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
