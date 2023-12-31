//
//  File.swift
//  WeatherX-Project
//
//  Created by t2023-m0067 on 2023/09/25.
//

import Foundation

struct API {
    
    // Info.plist에서 API Key 가져오기
    static var apiKey: String {
        // 생성한 .plist 파일 경로 불러오기
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            fatalError("Couldn't find file 'KeyList.plist'.")
        }
            
        // .plist를 딕셔너리로 받아오기
        let plist = NSDictionary(contentsOfFile: filePath)
            
        // 딕셔너리에서 값 찾기
        guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
            fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'KeyList.plist'.")
        }
        return value
    }
    
    // 현재 날씨 api url 정보
    static let weatherApiUrl = "https://api.openweathermap.org/data/2.5/weather"
    // 5일치 3시간 간격 날씨 api url 정보
    static let forecastApiUrl = "https://api.openweathermap.org/data/2.5/forecast"
    
    static let location = "q=Seoul" // Gangneung, Seoul
    static let key = "appid=\(apiKey)"
    static let unit = "units=metric"
    static let lang = "lang=kr"
    
    private init() {}
}
