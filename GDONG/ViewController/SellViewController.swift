//
//  SellViewController.swift
//  GDONG
//
//  Created by 이연서 on 2021/05/17.
//

import UIKit
import PagingTableView
import FirebaseFirestore
import DropDown
import NVActivityIndicatorView

class SellViewController: UIViewController, TableViewCellDelegate {
    
    let more_dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.width = 100
        dropDown.dataSource = ["게시글 삭제"]
        return dropDown
    }()
    
    //delete post
    func moreButton(cell: TableViewCell) {
        
        more_dropDown.anchorView = cell.moreButton
        more_dropDown.show()
        more_dropDown.backgroundColor = UIColor.white
        more_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if(index == 0){ // 게시글 삭제
                self.alertWithNoViewController(title: "게시글 삭제", message: "게시글을 삭제하시겠습니까?", completion: {(response) in
                    if(response == "OK"){
                        
                        guard let postId = contents[cell.indexPath![1]].postid else {
                            print("cant not find postid")
                            return
                        }
                        
                        print(postId)
                        checkPostDelete(postId: postId, completed: { (response) in
                            if(response == "OK") { //삭제 할 수 있을 때
                                print("선택한 셀 \(cell.indexPath!)")
                                //post 삭제
                                PostService.shared.deletePost(postId: postId)
                                contents.remove(at: cell.indexPath![1])
                                DispatchQueue.main.async {
                                    sellTableView.reloadData()
                                }
                                ChatListViewController().deleteChatRoom(postId: postId)
                                self.alertViewController(title: "삭제 완료", message: "게시글을 삭제하였습니다", completion: { (response) in})
                            }
                        })
               
                    }
                })
            }
//            else if(index == 1){ // 게시글 수정
//                let storyBoard = UIStoryboard(name: "CreateNewItem", bundle: nil)
//                let createVC = storyBoard.instantiateViewController(identifier: "CreateNewItemViewController") as? CreateNewItemViewController
//
//                let content = contents[cell.indexPath![1]]
//                createVC?.selected = content
//                createVC?.editMode = true
//
//            }
        }
    }
    
    func checkPostDelete(postId: Int, completed: @escaping (String)-> (Void)) {
        let document = Firestore.firestore().collection("Chats").document("\(postId)")
        document.getDocument { (document, error) in
            if let document = document, document.exists {
                
                guard let users = document.data()!["users"] as? [String] else {
                    print("no users string array in database")
                    return
                }
                
                if(users.count == 1){ //유저가 한명만 남았을 때(방장일때 밖에 없음) 방 삭제
                    print("user count is 1")
                    //채팅방 삭제
                    ChatListViewController().deleteChatRoom(postId: postId)
                    
                    //사람 chatList에서 나가기
                    ChatService.shared.quitChatList(postId: postId)
                    
                    //게시글 삭제
                    PostService.shared.deletePost(postId: postId)
                    completed("OK")
                }else { // 아직 유저 여러명일때
                    // 글쓴이인경우 == users[0]
                    guard let userEamil = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail) else { return }
                    print(userEamil)
                    if(users[0] == userEamil){
                        self.alertViewController(title: "글 삭제 실패", message: "채팅방에 다른 누군가가 있는경우 글을 삭제할 수 없습니다.", completion: {(response) in
                        })
                        completed("NOT OK")
                    }
                    
                    completed("NOT OK")
                }
       
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    @IBOutlet var sellTableView: PagingTableView!
    
    var itemBoard = [Board]()
    //페이징을 위한 새로운 변수 저장
    var contents = [Board]()

    var filtered = false
    
    //페이징을 위한 데이터 가공
    let numberOfItemsPerPage = 5 //지정한 개수마다 로딩

      func loadData(at page: Int, onComplete: @escaping ([Board]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          let firstIndex = page * self.numberOfItemsPerPage
          guard firstIndex < self.itemBoard.count else {
            onComplete([])
            return
          }
          let lastIndex = (page + 1) * self.numberOfItemsPerPage < self.itemBoard.count ?
            (page + 1) * self.numberOfItemsPerPage : self.itemBoard.count
            onComplete(Array(self.itemBoard[firstIndex ..< lastIndex]))
        }
      }
    
    
    //당겨서 새로고침시 갱신되어야 할 내용
    @objc func pullToRefresh(_ sender: UIRefreshControl) {
        
        self.sellTableView.refreshControl?.endRefreshing() // 당겨서 새로고침 종료
        self.sellTableView.reloadData() // Reload하여 뷰를 비워주기

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let index = sellTableView.indexPathForSelectedRow else {
            return
        }

        if let detailVC = segue.destination as? DetailNoteViewController {
            detailVC.oneBoard = contents[index.row]
        }
    }
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 10, y: UIScreen.main.bounds.height / 2, width: 50, height: 50),
                                               type: .ballPulse,
                                               color: .black,
                                               padding: 0)
    
    //headerview for filtering
    var HeaderView: UIView = {
        let headerView = UIView()
        var filterButton = UIButton()
        filterButton.setTitle(" 검색 필터", for: .normal)
        filterButton.setImage(UIImage(systemName: "square.fill.text.grid.1x2"), for: .normal)
        filterButton.tintColor = .black
        filterButton.setTitleColor(.black, for: .normal)
        headerView.addSubview(filterButton)
        filterButton.frame = CGRect(x: UIScreen.main.bounds.width - 100, y: 0, width: 100, height: 50)
        filterButton.addTarget(self, action: #selector(didTapFilteringButton), for: .touchUpInside)
        return headerView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        indicator.startAnimating()
        if filtered == false {
            indicator.startAnimating()
            PostService.shared.getAllPosts(sell: "true", completion: { [self] (response) in
                guard let response = response else {
                    return
                }
                
                //판매 글이 true인 글만 받아오기
                self.itemBoard = response
            })
            sellTableView.reloadData()
            indicator.stopAnimating()
        }else {
            print("filtering view controller 글에서 받아온 글 ")
            print(self.itemBoard)
            sellTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(indicator) //indicator
        
        // 테이블뷰와 테이블뷰 셀인 xib 파일과 연결
        let nibName = UINib(nibName: "TableViewCell", bundle: nil)

        sellTableView.register(nibName, forCellReuseIdentifier: "productCell")
        
        sellTableView.delegate = self
        sellTableView.dataSource = self
        sellTableView.pagingDelegate = self
        
        //당겨서 새로고침
        sellTableView.refreshControl = UIRefreshControl()
        sellTableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    
        
        HeaderView.frame = CGRect(x: 0, y: 0, width: view.width, height: 50)
        sellTableView.tableHeaderView = HeaderView

    }
    
    
    @objc func didTapFilteringButton(){
        let filteringVC = UIStoryboard.init(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "searchFilter") as! SearchFilteringViewController
        filteringVC.from = "sell"
        filteringVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(filteringVC, animated: true)
    }
    

}

extension SellViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myEmail = UserDefaults.standard.string(forKey: UserDefaultKey.userEmail)
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! TableViewCell
        guard contents.indices.contains(indexPath.row) else { return cell }

        cell.productNameLabel.text = contents[indexPath.row].title
        cell.productPriceLabel.text = "\(contents[indexPath.row].price ?? 0) 원"
        cell.delegate = self
        
        //내가 쓴 글이 아니라면
        if contents[indexPath.row].email != myEmail {
            
           cell.moreButton.isHidden = true
            cell.moreButton.isEnabled = false
        }

        let date: Date = DateUtil.parseDate(contents[indexPath.row].createdAt!)

        cell.timeLabel.text = BuyViewController.ondDayDateText(date: date)
        
        //categoryButton add
        cell.categoryButton.setTitle(contents[indexPath.row].category, for: .normal)
       
        cell.categoryButton.setTitleColor(UIColor.white, for: .normal)
        cell.categoryButton.backgroundColor = UIColor.darkGray
        cell.categoryButton.layer.cornerRadius = 5
        cell.categoryButton.titleEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        
    
        cell.peopleLabel.text = "\(contents[indexPath.row].nowPeople + 1) / \(contents[indexPath.row].needPeople ?? 0)"
        cell.indexPath = indexPath
        let indexImage =  contents[indexPath.row].images![0]
        let urlString = Config.baseUrl + "/static/\(indexImage)"
    
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
            cell.productImageView.sd_setImage(with: myURL, completed: nil)
        }
        
        return cell

    }
    
    // 디테일뷰 넘어가는 함수
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "detail", sender: nil)
        
    }

    
    
}

//페이징 함수 확장
extension SellViewController: PagingTableViewDelegate {

  func paginate(_ tableView: PagingTableView, to page: Int) {
    sellTableView.isLoading = true
    self.loadData(at: page) { contents in
        self.contents.append(contentsOf: contents)
    self.sellTableView.isLoading = false
    }
  }

}

