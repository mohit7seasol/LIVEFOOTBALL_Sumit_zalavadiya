//
//  UserDefaults+RUI.swift
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.
//

import Foundation

extension UserDefaults {
    
    // MARK: Set Custom Object in UserDefaults
    public func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    // MARK: Get Custom Object from UserDefaults
    public func get<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
    
    enum Keys {
        static let isAppLaunchFirstTime = "isAppLaunchFirstTime"
        static let selectedDecoderPriority = "selectedDecoderPriority"
        static let defaultPlaylist = "defaultPlaylist"
    }
    
    var isAppLaunchFirstTime: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isAppLaunchFirstTime)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isAppLaunchFirstTime)
        }
    }
    
    var selectedDecoderPriority: Int {
        get {
            return integer(forKey: Keys.selectedDecoderPriority)
        }
        set {
            set(newValue, forKey: Keys.selectedDecoderPriority)
        }
    }
    
    func savePlaylist(_ playlist: [String]) {
        set(playlist, forKey: Keys.defaultPlaylist)
    }
    
    func loadPlaylist() -> [String] {
        return array(forKey: Keys.defaultPlaylist) as? [String] ?? ["Bollywood Video", "Family", "Movies", "Album Song"]
    }
}


