//
//  SearchViewController.swift
//  V2ex-Swift
//
//  Created by H on 6/11/18.
//  Copyright © 2018 Fin. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import MJRefresh

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var input : UITextField = UITextField()
    var tableView: UITableView!
    
    var data = Array<Hits>()
    var currentPage = 0
    var pageSize = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("search")
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        let searchIcon = UIImageView()
        searchIcon.image = UIImage(named: "ic_menu_search_48pt")
        searchIcon.frame = CGRect(x: 8, y: 8, width: 20, height: 20)
        self.input.textColor = V2EXColor.colors.v2_TopicListTitleColor
        self.input.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.input.borderStyle = .roundedRect
        self.input.placeholder = NSLocalizedString("search") + "..."
        self.input.keyboardType = .webSearch
        self.input.keyboardAppearance = .default
        self.input.clearButtonMode = UITextFieldViewMode.whileEditing
        self.input.leftViewMode = .always
        self.input.addSubview(searchIcon)
        self.input.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: self.input.frame.height))
        self.input.delegate = self
        // 默认获取到焦点
        self.input.becomeFirstResponder()
        
        self.tableView = UITableView()
        self.tableView.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "searchCell")
        
        self.view.addSubview(input)
        self.view.addSubview(tableView)
        
        input.snp.makeConstraints { (make) in
            make.top.equalTo(NavigationBarHeight + 5)
            make.left.equalTo(10)
            make.right.equalTo(self.view).offset(-10)
            make.height.equalTo(35)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(self.input.snp.bottom).offset(5)
        }
        let footer = V2RefreshFooter(refreshingBlock: {[weak self] () -> Void in
            self?.getNextPage(keyword: (self?.input.text)!)
        })
        footer?.centerOffset = -4
        self.tableView.mj_footer = footer
    }
    
    func getNextPage(keyword: String){
        if keyword == "" {
            self.tableView.mj_footer.endRefreshing()
            return;
        }
        
        ClientApi.provider.requestAPI(.search(keyword: keyword, from: self.currentPage * pageSize, size: self.pageSize))
            .mapResponseToObj(SearchResultModel.self)
            .subscribe(onNext: { (searchResultModel) in
                let total = searchResultModel.total
                if let hits = searchResultModel.hits {
                    let count = hits.count
                    self.data.append(contentsOf: hits)
                    self.currentPage += 1
                    self.tableView.reloadData()
                    if total == (self.currentPage - 1) * self.pageSize + count {
                        let refreshFooter = self.tableView.mj_footer as! V2RefreshFooter
                        // 为啥没有数据了，这个提示文字还是不出来呢。。
                        refreshFooter.noMoreDataStateString = "没更多帖子了"
                        refreshFooter.endRefreshingWithNoMoreData()
                    }
                }
            }, onError: { (error) in
                V2Error("搜索话题失败")
            });
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            getNextPage(keyword: textField.text!)
        }
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.input.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        cell.bind(data[indexPath.row]._source!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicDetailVC = TopicDetailViewController()
        topicDetailVC.topicId = (data[indexPath.row]._source?.id?.description)!
        self.navigationController?.pushViewController(topicDetailVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
