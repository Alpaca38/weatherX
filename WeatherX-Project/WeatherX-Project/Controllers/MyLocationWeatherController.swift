//
//  ViewController.swift
//  WeatherX-Project
//
//  Created by Insu on 2023/09/25.
//

enum DependingLoaction {
    case myLocation
    case saveLocation
    case addLocation
}

import UIKit
import SnapKit
import Then

class MyLocationWeatherController: UIViewController {
    
    let locationImage: UIImage = .init(systemName: "location.fill")!
    
    lazy var bottomView = UIView().then {
        $0.addSubview(stackView)
        $0.backgroundColor = .white
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let mapViewButton = UIButton(type: .custom).then {
        $0.frame.size.height = 40
        $0.setImage(UIImage(systemName: "map"), for: .normal)
        $0.tintColor = .black
    }

    private let pageControl = UIPageControl()
    
    let menuViewButton = UIButton(type: .custom).then {
        $0.frame.size.height = 40
        $0.tintColor = .black
        $0.setImage(UIImage(systemName: "menucard"), for: .normal)
    }
    
    lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [mapViewButton, pageControl, menuViewButton])
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.spacing = 30
        return sv
    }()
    
    // MARK: - Properties
    
    var networking = Networking.shared
    
    // 받아온 데이터를 저장 할 프로퍼티
    var weatherResponse: WeatherResponse?
    var weather: Weather?
    var main: Main?
    var name: String?
    //    var city:
    var forecastResponse: ForecastResponse?
    
    private var scrollView = UIScrollView()
    
    //        private let mainWeatherView = MainWeatherViewController()
    let tableView = WeatherBottomView()
    private var dependingLocation: DependingLoaction = .myLocation

    private func mapViewButtonAction() {
        mapViewButton.addTarget(self, action: #selector(mapViewItemTapped), for: .touchUpInside)
    }

    private func menuViewButtonAction() {
        menuViewButton.addTarget(self, action: #selector(menuViewItemTapped), for: .touchUpInside)
    }
    
    // 뷰컨 배열 모음 MainWeatherViewController
    lazy var viewArray: [UIScrollView] = [scrollView]
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        snpLayout()
        networkingWeather()
        mapViewButtonAction()
        menuViewButtonAction()
        pageControllerSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setup() {
        //            view.addSubview(mainWeatherView.view)
        view.addSubview(bottomView)
        view.addSubview(scrollView)
        scrollView.addSubview(tableView)
        
        scrollView.delegate = self
        scrollView.isDirectionalLockEnabled = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        view.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.9411764706, blue: 1, alpha: 1)
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 20
    }
    
    private func pageControllerSetup() {
        pageControl.numberOfPages = viewArray.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        // 현재 페이지 표시 색상을 검정색으로 설정
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.setIndicatorImage(locationImage, forPage: 0)
    }
    
    private func snpLayout() {
        
        bottomView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
            $0.width.equalToSuperview()
        }
        
        let topView = WeatherTopView()
        scrollView.addSubview(topView)
        
        topView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.height.equalTo(650)
            make.width.equalTo(365)
        }
        
        let middleView = WeatherMiddleView()
        scrollView.addSubview(middleView)
        middleView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.top).offset(-60)
            make.leading.equalTo(scrollView.snp.leading)
            make.trailing.equalTo(scrollView.snp.trailing)
            make.height.equalTo(450)
            make.width.equalTo(365)
        }
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(50)
            $0.leading.equalTo(scrollView.snp.leading).offset(16)
            $0.trailing.equalTo(scrollView.snp.trailing).offset(-16)
            $0.bottom.equalTo(scrollView.snp_bottomMargin).offset(-30)
            
            // 스크롤뷰 내부 객체에 대해서는 반드시 크기 지정(스크롤 뷰가 가변적 크기이기 때문에)
            $0.height.equalTo(350)
            $0.width.equalTo(365)
        }
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 2000)
    }
    
    private func networkingWeather() {
        
        // data fetch
        networking.getWeather { result in
            switch result {
                case .success(let weatherResponse):
                    DispatchQueue.main.async {
                        self.weatherResponse = weatherResponse
                        self.weather = weatherResponse.weather.first
                        self.main = weatherResponse.main
                        self.name = weatherResponse.name
                    }
                case .failure:
                    print("weatherResponse error")
            }
        }
        
        networking.getforecastWeather { result in
            switch result {
                case .success(let forecastResponse):
                    DispatchQueue.main.async {
                        self.forecastResponse = forecastResponse
                    }
                case .failure:
                    print("forecastResponse error")
            }
        }
    }
        
    // MARK: - Helpers
        
    // MARK: - Actions
        
    @objc func mapViewItemTapped() {
        let mapVC = MapViewController()
        navigationController?.pushViewController(mapVC, animated: true)
    }
        
    @objc func menuViewItemTapped() {
        let listVC = WeatherListViewController()
        navigationController?.pushViewController(listVC, animated: true)
    }
}
    
// MARK: - UIScrollViewDelegate

extension MyLocationWeatherController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}
