//
//  AnnotationView.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 01.06.2021.
//

import UIKit


class AnnotationView: UIView {
    
    var titleLabel: UILabel!
    var distanceLabel: UILabel!
    var infoButton: UIButton!
    
    var blurView: UIVisualEffectView!
    
    weak var annotation: AnnotationEntity!
    
    var showCallback: (() -> Void)?
    
    var lastFrame: CGRect!
    
    init(frame: CGRect, annotation: AnnotationEntity) {
        super.init(frame: frame)
        
        self.annotation = annotation
        
        setupContainer()
        setupUI()
        
        infoButton.addTarget(self, action: #selector(showDetails), for: .touchUpInside)
        
        lastFrame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContainer() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(blurView)
        blurView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        blurView.layer.cornerRadius = 20
        blurView.layer.masksToBounds = true
    }
    
    func setupUI() {
        let padding: CGFloat = 15
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        
        distanceLabel = UILabel()
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = .systemFont(ofSize: 13, weight: .regular)
        distanceLabel.textColor = .secondaryLabel
        distanceLabel.textAlignment = .left
        
        infoButton = UIButton(type: .detailDisclosure)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.contentView.addSubview(infoButton)
        blurView.contentView.addSubview(titleLabel)
        blurView.contentView.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            infoButton.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),
            infoButton.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -padding),
            infoButton.heightAnchor.constraint(equalToConstant: 30),
            infoButton.widthAnchor.constraint(equalToConstant: 30),
            
            distanceLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: padding),
            distanceLabel.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -8),
            distanceLabel.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -padding),
            distanceLabel.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: distanceLabel.topAnchor, constant: -8),
        ])
    }
    
    @objc func showDetails() {
        self.showCallback?()
    }
}
