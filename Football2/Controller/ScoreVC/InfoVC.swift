//
//  InfoVC.swift
//  Football2
//
//  Created by Parthiv Akbari on 30/04/25.
//

import UIKit

class InfoVC: BaseVC {
    
    @IBOutlet weak var lblMatchName: UILabel!
    @IBOutlet weak var lblSeries: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblVenue: UILabel!    
    
    var index = -1
    var m_id:String?
    var l_id:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMatchInfo()
    }
    
    func fetchMatchInfo() {
        // Define the API URL
        let url = URL(string: matchInfo)!
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Define the parameters
        let parameters: [String: Any] = [
            "spt_typ": 2,
            "l_id": l_id!,
            "m_id": m_id!
        ]
        
        // Set the HTTP body
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        // Create the URL session
        let session = URLSession.shared
        
        // Create the data task
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // Parse the JSON response
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let statusCode = json["statusCode"] as? Int, statusCode == 200,
                   let result = json["result"] as? [String: Any] {
                    
                    // Extract the values
                    let mName = result["m_name"] as? String ?? "N/A"
                    let lName = result["l_name"] as? String ?? "N/A"
                    let venue = result["venue"] as? String ?? "N/A"
                    let startTimeTimestamp = result["strt_time_ts"] as? TimeInterval ?? 0
                    
                    // Convert timestamp to date
                    let startTime = Date(timeIntervalSince1970: startTimeTimestamp)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .short
                    let startTimeString = dateFormatter.string(from: startTime)
                    
                    let result = self.convertTimestamp(Int(startTimeTimestamp))
                    let date =  result.formattedDate
                    let time  = result.formattedTime
                    
                    
                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        self.lblMatchName.text = mName
                        self.lblSeries.text = lName
                        self.lblVenue.text = venue
                        self.lblDate.text = date
                        self.lblTime.text = time
                        //                           self.startTimeLabel.text = startTimeString
                    }
                } else {
                    print("Invalid response")
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        // Start the task
        task.resume()
    }
    
}
