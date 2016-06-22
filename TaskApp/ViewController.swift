//
//  ViewController.swift
//  TaskApp
//
//  Created by 上村 宙生 on 2016/06/17.
//  Copyright © 2016年 huemura. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource , UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var categoryTextField: UITextField!

    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
    
    var keyboardShowFlag:Bool = false;
    
    //カテゴリ一覧
    var categoryAry:[String] = [""]
    var categoryIdAry:[Int] = [0]
    var categoryId:Int = 0;
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: false)   // ←追加
    
    let tblBackColor: UIColor = UIColor.clearColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.backgroundColor = tblBackColor
        
        
        //キーボードの開閉イベント取得
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "KeyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "KeyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:"dismissKeyboard")
        tapGesture.cancelsTouchesInView = false;
        self.view.addGestureRecognizer(tapGesture)
        
        //カテゴリ一覧取得
        getAllCategory()
        
        //テキストフィールドを選択するとPickerView
        var pickerView = UIPickerView()
        pickerView.delegate = self
        categoryTextField.inputView = pickerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count  // ←追加する
    }
    
    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = tblBackColor
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(keyboardShowFlag) {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        else {
            performSegueWithIdentifier("cellSegue",sender: nil) // ←追加する
        }
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            // データベースから削除する  // ←以降追加する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    // segue で画面遷移するに呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    func KeyboardDidShow(notification: NSNotification) {
        print("show")
        keyboardShowFlag = true
    }
    func KeyboardDidHide(notification: NSNotification) {
        print("false")
        keyboardShowFlag = false
    }
    
    //絞り込みボタン
    @IBAction func search(sender: AnyObject) {
        let word:String! = categoryTextField.text
        taskArray = try! Realm().objects(Task).filter("category CONTAINS '"+word+"'").sorted("date", ascending: false)
        tableView.reloadData()
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
        
        //カテゴリID取得
        categoryId = categoryIdAry[row]
        print(categoryId)
        //タスクをカテゴリで絞り込み
        if(categoryId == 0) {
            taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
        }
        else {
            taskArray = try! Realm().objects(Task).filter("category_id == "+String(categoryId)+" ").sorted("date", ascending: false)
        }
        tableView.reloadData()
    }
    func getAllCategory() {
        for _category in try! Realm().objects(Category).sorted("id", ascending: false) {
            categoryAry.append(_category.name)
            categoryIdAry.append(_category.id)
        }
    }
}

