//
//  APIManger.swift
//  Video Player
//
//  Created by 7SEASOL-6 on 30/07/24.
//

import Foundation
import SystemConfiguration
import Alamofire
import CoreMedia

var COOKIE = "intercom-id-h3v14f8j=6ad7b0d4-68fc-4bbf-926d-cec72cf82c2e; intercom-device-id-h3v14f8j=8a0422ed-9bc9-4f78-bd77-aed57b4a63d9; __Host-next-auth.csrf-token=50896a1f3b8b65889203f032e4d41bf020e9639492f382fe5880463e0f7da994%7Cc63f1f98b495340ff5997810e209f8faeca2aaa6081e56108cfa4b0eadfcc275; __stripe_mid=767587e6-2d29-45bd-93c4-0aeef4ff96d1305ad0; __Secure-next-auth.callback-url=https%3A%2F%2Fplaygroundai.com%2Fcreate%3F; __Secure-next-auth.session-token=7152d431-e6b3-42d8-8c41-77d5c9ba7973; mp_6b1350e8b0f49e807d55acabb72f5739_mixpanel=%7B%22distinct_id%22%3A%20%22clf6ln8wm07z0s601xt7vg6wg%22%2C%22%24device_id%22%3A%20%22186da3796d8780-0544afa55355b-1b525635-240000-186da3796d9e5d%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22%24initial_referrer%22%3A%20%22https%3A%2F%2Fwww.google.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22www.google.com%22%2C%22%24user_id%22%3A%20%22clf6ln8wm07z0s601xt7vg6wg%22%2C%22email%22%3A%20%22sagar.l%40jksol.com%22%7D; __stripe_sid=c7baf5d4-e96a-42fa-96e5-1010cfff98cd8dfaf1; intercom-session-h3v14f8j=NVhWWGxmdEdVc1p3SlJqR25MSXBCUGFEQnRucWFoR1pGelJPSmxwNFBMNFozelFObWFjdmkzaWZqUUIyTW9sQy0tY09pVE5odEtOQUZyQmVkbFZLVVhTQT09--e02619a73f80752bf38181f2a5bd9503688b20e4"

public class APIManager {
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    
    class func toJson(_ dict:[String:Any]) -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString!
    }

    func networkErrorMsg() {
        showAlertMessage(titleStr: "Error", messageStr: "You are not connected to the internet")
        //("Error", message: "You are not connected to the internet") {}
    }

    func getJsonHeader() -> HTTPHeaders {
        return ["X-RapidAPI-Host": "","X-RapidAPI-Key": ""]
    }
    func getJsonHeader1() -> HTTPHeaders {
        return ["content-type":"application/json",
                      "cookie":COOKIE]
    }

    func getMultipartHeader() -> HTTPHeaders {
        return ["Content-Type":"multipart/form-data", "Accept":"application/json"]
    }

    func getMultipartHeaderWithRawData() -> HTTPHeaders {
        return ["Content-Type":"multipart/form-data", "Accept":"application/json"]
    }

    // MARK: APIs
    func POST_MULTIPART_API(api: String, param: [String: Any], image: Data?, isShowLoader: Bool, _ completion: @escaping (_ data: Data?) -> Void) {
        if !APIManager.isConnectedToNetwork() {
            APIManager().networkErrorMsg()
            return
        }

       // isShowLoader ? (showLoader()) : nil
        let headerParams = getMultipartHeader()

        AF.upload(multipartFormData: { multipartFormData in
            if let image = image {
                multipartFormData.append(image, withName: "image",fileName: "image.jpg", mimeType: "image/jpg")
            }
            for (key, value) in param {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: api, usingThreshold: UInt64.init(), method: .post, headers: headerParams).responseData { response in
          //  isShowLoader ? (removeLoader()) : nil
            switch response.result {
                case .success(_):
                    if let data = response.data {
                        completion(data)
                        return
                    }
                    break

                case .failure(let error):
                   // displayToast(error.localizedDescription)
                    break
            }
        }
    }

    func POST_API(api: String, param: [String: Any], isShowLoader: Bool, _ completion: @escaping (_ data: Data?) -> Void) {
        if !APIManager.isConnectedToNetwork() {
            APIManager().networkErrorMsg()
            return
        }

      //  isShowLoader ? (showLoader()) : nil
         let headerParams = getJsonHeader1() // getMultipartHeader()

        AF.request(api, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headerParams).responseData { response in
          //  isShowLoader ? (removeLoader()) : nil
            switch response.result {
                case .success(_):
                    if let data = response.data {
                        completion(data)
                        return
                    }
                    break

                case .failure(let error):
                   // displayToast(error.localizedDescription)
                    completion(nil)
                    break
            }
        }
    }
    
    func GET_API(api: String, isShowLoader: Bool, _ completion: @escaping (_ data: Data?) -> Void) {
        if !APIManager.isConnectedToNetwork() {
            APIManager().networkErrorMsg()
            return
        }
        
     //   isShowLoader ? (showLoader()) : nil
        let headerParams = getJsonHeader()
        
        AF.request(api, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headerParams).responseData { response in
         //   isShowLoader ? (removeLoader()) : nil
            switch response.result {
                case .success(_):
                    if let data = response.data {
                        completion(data)
                        return
                    }
                    break
                
                case .failure(let error):
                   // displayToast(error.localizedDescription)
                    break
            }
        }
    }
    
    // MARK: Download
    func DOWNLOAD_ANY_FILE(url: String, isShowLoader: Bool, _ complition: @escaping (_ data: String) -> Void) {
        if !APIManager.isConnectedToNetwork() {
            APIManager().networkErrorMsg()
            return
        }

      //  isShowLoader ? (showLoader()) : nil
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask, options: DownloadRequest.Options.removePreviousFile)

        AF.download(url, interceptor: nil, to: destination).downloadProgress { progress in
            debugPrint(progress.fractionCompleted)
        }.response { response in
          //  isShowLoader ? (removeLoader()) : nil
            if response.error == nil, let filePath = response.fileURL?.path {
                complition(filePath)
            }
        }
    }
    /*
    func showToast(message: String){
        DispatchQueue.main.async {
            let windows = UIApplication.shared.windows
            windows.first?.makeToast(message)
        }
    }
    */
    // MARK: - GET APIs -
    func GET_DATA_API(api: String, params: NSDictionary, _ completion: @escaping ( _ data: Data?) -> Void) {
        AF.request(api, method: .get, parameters: params as? Parameters).responseData { response in
            switch response.result {
            case .success(let data):
                completion(data)
                break
                
            case .failure(let error):
                
//                self.showToast(message: error.localizedDescription)
                break
            }
        }
    }
    
    
}
