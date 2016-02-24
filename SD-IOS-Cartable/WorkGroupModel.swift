//
//  WorkGroupModel.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/24/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//

import Foundation

class WorkGroupModel {
    
    private var _workGroupId : Int?
    var workGroupId : Int? {
        get{return _workGroupId}
        set{_workGroupId = newValue}
    }
    
    private var _workGroupTitle : String?
    var workGroupTitle : String? {
        get{return _workGroupTitle}
        set{_workGroupTitle = newValue}
    }
    
    
    init(workGroupId : Int?,workGroupTitle : String?){
        self._workGroupTitle = workGroupTitle
        self._workGroupId = workGroupId
        
    }
    
    init(){
    }
    
}