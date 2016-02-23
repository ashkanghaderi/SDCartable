//
//  PersonDevicesModel.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/23/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//

import Foundation

class PersonDevicesModel {
    
    private var _deviceAliasName : String?
    var deviceAliasName : String? {
        get{return _deviceAliasName}
        set{_deviceAliasName = newValue}
    }
    
    private var _failureDescription : String?
    var failureDescription : String? {
        get{return _failureDescription}
        set{_failureDescription = newValue}
    }
    
    private var _qcSerial : String?
    var qcSerial  : String? {
        get{return _qcSerial}
        set{_qcSerial = newValue}
    }
    
    
    
    init(deviceAliasName : String?,failureDescription : String?,qcSerial : String?){
        self._deviceAliasName = deviceAliasName
        self._failureDescription = failureDescription
        self._qcSerial = qcSerial
        
    }
    
    init(){
    }

}