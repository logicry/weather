//
//  WeatherConditionView.swift
//  weather
//
//  Created by Standa Musil on 5/23/23.
//

import UIKit

class WeatherConditionView: UIStackView {
    let icon = UIImageView()
    let label = UILabel()
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    private func configure() {
        axis = .horizontal
        spacing = 16
        
        icon.contentMode = .scaleAspectFit
        addArrangedSubview(icon)
        addArrangedSubview(label)
    }
}
