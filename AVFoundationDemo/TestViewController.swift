//
//  TestViewController.swift
//  AVFoundationDemo
//
//  Created by Mjwon on 2017/9/29.
//  Copyright © 2017年 Nemo. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    
    let dataSource:[[String:Any]] = [["title":"videoPlayView的使用","vc":ViewController()],["title":"AVPlayer使用","vc":AVPlayerViewController()]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.tableView)
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = ViewController()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    lazy var tableView: UITableView = {
        let t = UITableView.init(frame: XCGRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGH))
        t.delegate = self
        t.dataSource = self
        return t
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TestViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "testCell")
        
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "testCell")
        }
        cell?.textLabel?.text = dataSource[indexPath.row]["title"] as? String
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = dataSource[indexPath.row]["vc"] as? UIViewController
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
}

