//
//  CategoryAddViewController.swift
//  TaskApp
//
//  Created by 上村 宙生 on 2016/06/21.
//  Copyright © 2016年 huemura. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryAddViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var categoryTextView: UITextField!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var categoryArray = try! Realm().objects(Category).sorted("id", ascending: false)   // ←追加
    
    let tblBackColor: UIColor = UIColor.clearColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        categoryTableView.rowHeight = 50
        categoryTableView.backgroundColor = tblBackColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count  // ←追加する
    }
    
    // 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath)
        
        cell.backgroundColor = tblBackColor
        
        // Cellに値を設定する.
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // データベースから削除する  // ←以降追加する
            try! realm.write {
                self.realm.delete(self.categoryArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    // 入力画面から戻ってきた時
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //カテゴリー追加
    @IBAction func categoryAdd(sender: AnyObject) {
        let _category:String! = categoryTextView.text
        if _category.characters.count > 0 {
            try! realm.write {
                let category:Category = Category()
                if categoryArray.count != 0 {
                    category.id = categoryArray.max("id")! + 1
                }
                print(_category)
                category.name = _category
                self.realm.add(category, update: true)
            }
            categoryTableView.reloadData()
        }
    }
}
