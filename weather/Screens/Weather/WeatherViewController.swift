//
//  WeatherViewController.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: Summary UI
    
    @IBOutlet weak var summary: UIStackView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // MARK: Details UI
    
    @IBOutlet weak var details: UIStackView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    
    private var viewModel: WeatherViewModel!
    private var weatherConditions: UIStackView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = WeatherViewModel()
        viewModel.onWeatherLoad = { [weak self] () in
            self?.spinner.stopAnimating()
            self?.configureCurrentWeatherUI()
        }
        
        title = "Weather App"
        
        spinner.startAnimating()
        configureCurrentWeatherUI()
    }
    
    // MARK: - IBAction
    
    @IBSegueAction func onSearch(_ coder: NSCoder) -> SearchViewController? {
        let controller = SearchViewController(coder: coder)!
        controller.onCityLocation = { [weak self] (location) in
            self?.viewModel.location = location
            self?.viewModel.storeLocation()
            self?.navigationController?.popViewController(animated: true)
            
            Task { [weak self] in await self?.viewModel.getCurrentWeather() }
        }
        return controller
    }
    
    // MARK: - Private
    
    func configureCurrentWeatherUI() {
        cityLabel.text = viewModel.weatherLocation
        temperatureLabel.text = viewModel.temperature
        humidityLabel.text = "Humidity: \(viewModel.humidity)"
        minTemperatureLabel.text = "Low: \(viewModel.minTemperature)"
        maxTemperatureLabel.text = "High: \(viewModel.maxTemperature)"
        
        // Visibility
        summary.isHidden = viewModel.currentWeather == nil || !spinner.isHidden
        details.isHidden = summary.isHidden
        errorLabel.isHidden = !summary.isHidden || !spinner.isHidden
        
        configureWeatherConditionsUI()
    }

    func configureWeatherConditionsUI() {
        weatherConditions?.removeFromSuperview()
        
        guard let conditions = viewModel.currentWeather?.conditions else { return }
        
        weatherConditions = UIStackView()
        weatherConditions!.spacing = 8
        weatherConditions!.axis = .vertical
        
        for condition in conditions {
            let view = WeatherConditionView()
            weatherConditions?.addArrangedSubview(view)
            
            view.label.text = condition.description
            
            // we only need a weak view reference as the superview holds a strong reference and if it's released
            // it means this icon is not desired by the UI anymore.
            Task { [weak self, weak view] in
                if let image = await self?.viewModel.getWeatherConditionIcon(name: condition.icon) {
                    view?.icon.image = image
                }
            }
        }
        
        summary.addArrangedSubview(weatherConditions!)
    }
}
