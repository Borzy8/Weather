//
//  DetailViewController.swift
//  Weather
//
//  Created by Borzy on 21.09.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var forecastResults: [Forecast] = [];

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwind(sender: UIButton) {
        dismiss(animated: true, completion: nil);
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let forecastResult = forecastResults[indexPath.row];
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BigCell", for: indexPath) as! BigDetailTableViewCell;
            
            cell.customImageView.image = forecastResult.icon;
            cell.temperatureLabel.text = forecastResult.temperature;
            
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SmallCell", for: indexPath) as! DetailTableViewCell;
            
            cell.dateLabel.text = forecastResult.date;
            cell.customImageView.image = forecastResult.icon;
            cell.temperatureLabel.text = forecastResult.temperature;
            
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 190;
        } else {
            return 70;
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil;
    }
}
