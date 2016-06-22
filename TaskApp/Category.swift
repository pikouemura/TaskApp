//
//  Category.swift
//  TaskApp
//
//  Created by 上村 宙生 on 2016/06/21.
//  Copyright © 2016年 huemura. All rights reserved.
//

import RealmSwift

class Category: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 1
    
    // カテゴリー名
    dynamic var name = ""
    
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}