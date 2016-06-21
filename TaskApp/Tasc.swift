//
//  Tasc.swift
//  TaskApp
//
//  Created by 上村 宙生 on 2016/06/20.
//  Copyright © 2016年 huemura. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // タイトル
    dynamic var category_id:Int = 0
    
    // 内容
    dynamic var contents = ""
    
    /// 日時
    dynamic var date = NSDate()
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}