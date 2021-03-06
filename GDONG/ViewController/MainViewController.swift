//
//  MainViewController.swift
//  GDONG
//
//  Created by 이연서 on 2021/04/09.
//

import UIKit
import Tabman
import Pageboy
import CoreLocation
import NVActivityIndicatorView

class MainViewController : TabmanViewController {
    
    @IBOutlet var search: UIBarButtonItem!
    
    @IBOutlet var add: UIBarButtonItem!
    
    var itemBoard = [Board]()
    
    var locationString: String?
    
    var latitude: Double?
    var longitude: Double?
    
    
    var viewControllers: Array<UIViewController> = []
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 50, height: 50),
                                            type: .ballPulse,
                                            color: .black,
                                            padding: 0)
    
    @IBAction func search(_ sender: Any) {
        guard let searchVC = self.storyboard?.instantiateViewController(identifier: "searchButton") as? SearchViewController else { return }
        self.navigationController?.pushViewController(searchVC, animated: true)
        //performSegue(withIdentifier: "searchButton", sender: self)
    }
    
    @IBAction func add(_ sender: Any) {
        let createItemVC = UIStoryboard.init(name: "CreateNewItem", bundle: nil).instantiateViewController(withIdentifier: "CreateNewItemViewController")
        createItemVC.modalPresentationStyle = .fullScreen
        self.present(createItemVC, animated: true, completion: nil)
        
      
    }
    
    func getLocation(longitude: Double?, latitude: Double?, complete: @escaping (String) -> (Void)){
        
        //처음 위치 설정 x 후 함수 호출시 default location setting
        if let latitude = latitude, let longitude = longitude {
            if(latitude == -1 || longitude == -1){
                complete("위치 로딩 중")
//                self.alertViewController(title: "위치 정보 실패", message: "사용자의 위치 값을 설정해주세요. 위치 설정으로 이동합니다.", completion: { (response) in
//                    if(response == "OK"){
//                        self.goToLocationSetting()
//                    }
//                })
            }
            
            let findLocation = CLLocation(latitude: latitude, longitude: longitude)
            let geocoder = CLGeocoder()
            let locale = Locale(identifier: "Ko-kr")
            
            geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(place, error) in
                if let address: [CLPlacemark] = place {
                    if let name: String = address.last?.name{
                        print(name)
                        complete(name)
                    }
                }
            })
        }
    }
    
    
    func goToLocationSetting(){
        let storyBoard = UIStoryboard(name: "UserInfo", bundle: nil)
        guard let profileEditVC = storyBoard.instantiateViewController(identifier: "editProfile") as? EditProfileViewController else { return }
        guard let profileVC = storyBoard.instantiateViewController(identifier: "ProfileViewController") as? ProfileViewController else { return }
        let navigationController = UINavigationController(rootViewController: profileVC)
        navigationController.pushViewController(profileEditVC, animated: false)
        self.navigationController?.pushViewController(navigationController, animated: false)
//        UIApplication.shared.windows.first?.rootViewController = navigationController
//        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //locationString update
        print("get location : \(longitude) \(latitude)")
        
        UserService.shared.getUserInfo(completion: {
            response in
            if(self.longitude == nil || self.latitude == nil){
                self.longitude = response.location.coordinates[0]
                self.latitude = response.location.coordinates[1]
            }
            self.getLocation(longitude: self.longitude, latitude: self.latitude, complete: { [self] (response) in
                self.locationString = response
                let LocationBarButton: UIBarButtonItem = UIBarButtonItem(title: locationString, style: .plain, target: nil, action: nil)
                LocationBarButton.tintColor = .darkGray
                navigationItem.leftBarButtonItem = LocationBarButton
            })
        })
      
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view array에 추가
        let buyViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyViewController") as! BuyViewController
        let sellViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SellViewController") as! SellViewController
        
                
        viewControllers.append(buyViewController)
        viewControllers.append(sellViewController)
        
        self.dataSource = self

        // Create bar
        let bar = TMBar.ButtonBar()
        settingTabBar(ctBar: bar)
        bar.layout.transitionStyle = .snap // Customize
        bar.layout.contentMode = .fit

        // Add to view
        addBar(bar, dataSource: self, at: .top)
        
        search.tintColor = .black
        add.tintColor = .black


    }
    
    func settingTabBar(ctBar: TMBar.ButtonBar){
        ctBar.layout.transitionStyle = .snap //customize
        ctBar.layout.contentMode = .fit
        ctBar.backgroundView.style = .blur(style: .extraLight)
        ctBar.layout.interButtonSpacing = 20
        ctBar.buttons.customize({ (button) in
            button.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            button.selectedTintColor = UIColor.black
            
            button.font = UIFont.systemFont(ofSize: 16)
            button.selectedFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        })
        
        //인디케이터
        ctBar.indicator.weight = .custom(value: 5)
        ctBar.indicator.tintColor = UIColor.black
    }

    
}

extension MainViewController : PageboyViewControllerDataSource, TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
        
        switch index {
        case 0:
            item.title = "구매글"
        case 1:
            item.title = "판매글"
        default:
            break
        }
        
        return item
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}






