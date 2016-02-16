//
//  AuthenticationModel.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/3/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//

import Foundation

class AuthenticationModel {
    
    private var _userFullName : String?
    var userFullName : String? {
        get{return _userFullName}
        set{_userFullName = newValue}
    }
    
    private var _guidToken : String?
    var guidToken : String? {
        get{return _guidToken}
        set{_guidToken = newValue}
    }
    
    private var _appVersion : String?
    var appVersion  : String? {
        get{return _appVersion}
        set{_appVersion = newValue}
    }
    
    private var _personId : Int64?
    var personId  : Int64? {
        get{return _personId}
        set{_personId = newValue}
    }
    
    
    init(userFullName : String?,guidToken : String?,appVersion : String?,personId : Int64?){
        self._userFullName = userFullName
        self._guidToken = guidToken
        self._appVersion = appVersion
        self._personId = personId
       
    }
    
    init(){
    }
    
}