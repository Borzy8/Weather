//
//  ViewController.swift
//  Weather
//
//  Created by Borzy on 18.09.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import UIKit
import Alamofire
import Dispatch

class ForecastViewController: UIViewController, UISearchBarDelegate {
    
    
    var cities: [City] = []
    
    var startingScrollingOffset = CGPoint.zero
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetup()
        getForecast()
        
    }
    
    func getForecast() {
        for (index, city) in cities.enumerated() {
            
            var cityForecast = city.forecastResults
            let cityName = city.name
            let stringUrl = forecastUrl(_for: city.name)
            
            Alamofire.request(stringUrl).responseJSON{ response in
                
                if let HTTPResponse = response.response, HTTPResponse.statusCode == 404 {
                    
                    //If city not found or incorrect
                    self.cities.remove(at: index)
                    
                    return
                } else if let dict = response.value as? [String: AnyObject] {
                    city.forecastResults = self.parse(dictionary: dict)!
                    
                    self.collectionView.reloadData()
                    
                } else {
                    self.showError()
                }
                
                
            }
        }
    }
    
    func parse(dictionary: [String : AnyObject]) -> [Forecast]? {
        
        guard let results = dictionary["list"] as? [AnyObject] else { return nil }
        
        var allForecastResults: [Forecast] = []
        
        for resultDict in results {
            
            let forecast = Forecast()
            
            guard let resultDict = resultDict as? [String : AnyObject] else { return nil }
            guard let main = resultDict["main"] as? [String : AnyObject] else { return nil }
            
            if let temperature = main["temp"] as? Double, let pressure = main["pressure"] as? Double, let humidity = main["humidity"] as? Double {
                
                let tempCelsius = Int(round(temperature - 273.15))
                forecast.temperature = String(tempCelsius) + " C˚";
                forecast.humidity = String(Int(round(humidity))) + " %";
                forecast.pressure = String(Int(round(pressure))) + " mm";
                
                
            }
            
            guard let weatherArray = resultDict["weather"] as? [AnyObject] else { return nil }
            guard let weather = weatherArray[0] as? [String : AnyObject] else { return nil }
            
            
            if let icon = weather["icon"] as? String {
                forecast.icon = UIImage(named: WeatherIcon(iconName: icon).rawValue)
            }
            
            if let stringDate = resultDict["dt_txt"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.date(from: stringDate)!;
                
                let month = Calendar.current.component(Calendar.Component.month, from: date);
                let day = Calendar.current.component(Calendar.Component.day, from: date);
                let hour = Calendar.current.component(Calendar.Component.hour, from: date);
                
                forecast.date = "\(MonthString(numMonth: month).rawValue) \(day)"
                
                if hour == 9 || hour == 12 || hour == 15 || hour == 18 || hour == 21 {
                    allForecastResults.append(forecast)
                }
            }
        }
        
        let day1Date = allForecastResults[0].date
        let day1 = allForecastResults[0]
        let filtredArray1 = allForecastResults.filter{$0.date != day1Date}
        
        let day2Date = filtredArray1[0].date
        let day2 = filtredArray1[0]
        let filtredArray2 = filtredArray1.filter{$0.date != day2Date}
        
        let day3Date = filtredArray2[0].date
        let day3 = filtredArray2[0]
        let filtredArray3 = filtredArray2.filter{$0.date != day3Date}
        
        let day4Date = filtredArray3[0].date
        let day4 = filtredArray3[0]
        let filtredArray4 = filtredArray3.filter{$0.date != day4Date}
        
        let day5Date = filtredArray4[0].date
        let day5 = filtredArray4[0]
        
        let forecastResults: [Forecast] = [day1, day2, day3, day4, day5]
        
        
        return forecastResults
    }
    
    func forecastUrl(_for city: String) -> String {
        let apiKey = "APPID=1553d715cfba7ef6c41aec6c471098f9"
        let url = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&\(apiKey)"
        
        return url;
    }
    
    func viewSetup() {
        collectionView.showsHorizontalScrollIndicator = false;
        
        let kyiv = City(name: "Kyiv", forecastResults: []);
        let odessa = City(name: "Odessa", forecastResults: []);
        
        cities.append(kyiv);
        cities.append(odessa);
        
    }
    
    func showError() {
        let alert = UIAlertController(title: "Network error", message: "Please, check your internet connection.", preferredStyle: .alert);
        let okAction = UIAlertAction(title: "OK", style: .default){_ in
            self.performSegue(withIdentifier: "Exit", sender: nil);
        }
        alert.addAction(okAction);
        
        if let spinner = collectionView.viewWithTag(100) as?UIActivityIndicatorView {
            spinner.stopAnimating();
            spinner.removeFromSuperview();
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destinationController = segue.destination as! DetailViewController;
            let indexPath = collectionView.indexPathsForSelectedItems!.last!
            destinationController.forecastResults = cities[indexPath.row].forecastResults
        }
    }
    
    @IBAction func addAction(_ sender: AnyObject) {
        let searchView = UIView(frame: view.bounds)
        searchView.tag = 100;
        searchView.backgroundColor = UIColor(white: 0.0, alpha: 0.7);
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 100, width: 200, height: 44));
        
        searchBar.placeholder = "Enter new city..."
        searchBar.barTintColor = UIColor(white: 0.0, alpha: 0.4);
        searchBar.tintColor = UIColor(white: 1.0, alpha: 0.7);
        searchBar.backgroundColor = UIColor(white: 0.5, alpha: 0.5);
        let searchField = searchBar.value(forKey: "searchField") as! UITextField;
        searchField.textColor = UIColor(white: 1.0, alpha: 0.5);
        searchBar.searchBarStyle = .minimal;
        
        searchBar.center.x = view.center.x
        searchBar.center.y = view.center.y - 110;
        searchView.addSubview(searchBar);
        searchBar.delegate = self;
        
        view.addSubview(searchView);
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            let searchView = view.viewWithTag(100)!
            let escapedSearchText = searchBar.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            let newCity = City(name: escapedSearchText, forecastResults: [])
            cities.append(newCity);
            
            getForecast();
            
            searchView.removeFromSuperview();
            
            
        }
    }

}

extension ForecastViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if cities[0].forecastResults.isEmpty {
            
            let spinner = UIActivityIndicatorView()
            spinner.center = collectionView.center
            
            spinner.tag = 100;
            collectionView.addSubview(spinner);
            spinner.startAnimating();
            
            return 0
        } else {
            
            if let spinner = collectionView.viewWithTag(100) as? UIActivityIndicatorView {
                spinner.removeFromSuperview();
            }
            var count = 0;
            for city in cities {
                count = city.forecastResults.isEmpty ? count : count + 1;
            }
            
            return count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastCollectionViewCell
        
        let cityName = cities[indexPath.row].name;
        let forecastResult = cities[indexPath.row].forecastResults[0];
        
        cell.cityLabel.text = cityName.removingPercentEncoding
        cell.backgroundColor = UIColor(colorLiteralRed: 128/255, green: 128/255, blue: 128/255, alpha: 0.3)
        cell.imageView.image = forecastResult.icon;
        cell.temperatureLabel.text = forecastResult.temperature;
        cell.humidityLabel.text = forecastResult.humidity;
        cell.pressureLabel.text = forecastResult.pressure;
        
        cell.alpha = 0
        UIView.animate(withDuration: 0.6){
            cell.alpha = 1;
        }
        return cell;
        
    }
}

extension ForecastViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ratioW: Double = 333/375
        let ratioH: Double = 540/667
        
        return CGSize(width: collectionView.bounds.width * CGFloat(ratioW), height: collectionView.bounds.height * CGFloat(ratioH));
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        
        let cellWidth = getCellWidth()
        
        let leftInset = (collectionView.frame.width - CGFloat(cellWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
    }
    
    func getCellWidth() -> CGFloat {
        let cell = collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0))
        return cell.width
    }
}

extension ForecastViewController: UICollectionViewDelegate, UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startingScrollingOffset = scrollView.contentOffset
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cell = collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0));
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout;
        let cellWidthWithMinimumSpacing = cell.width + layout.minimumLineSpacing;
        
        let page: CGFloat;
        let proposedPage = scrollView.contentOffset.x  / cellWidthWithMinimumSpacing;
        
        let delta: CGFloat = scrollView.contentOffset.x > startingScrollingOffset.x ? 0.9 : 0.1
        if floor(proposedPage + delta) == floor(proposedPage) {
            page = floor(proposedPage)
        } else {
            page = floor(proposedPage + 1)
        }
        
        targetContentOffset.pointee = CGPoint(x: cellWidthWithMinimumSpacing * page, y: targetContentOffset.pointee.y)
    }
    
}
