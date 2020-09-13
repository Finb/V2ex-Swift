//
//  AgreementViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 2020/9/13.
//  Copyright © 2020 Fin. All rights reserved.
//

import UIKit

class AgreementViewController: UIViewController {
    let textLabel:UILabel = {
        let label = UILabel()
        let text = """
        V2EX 是创意工作者们的社区。这里目前汇聚了超过 400,000 名主要来自互联网行业、游戏行业和媒体行业的创意工作者。V2EX 希望能够成为创意工作者们的生活和事业的一部分。

        希望大家能够多多分享自己正在做的有趣事物、交流想法，在这里找到朋友甚至新的机会。并且，最重要的是，在这一切的过程中，保持对他人的友善。

        为了保持这里的良好氛围，V2EX 有自己的明确规则：

        • 这里绝对不讨论任何有关盗版软件、音乐、电影如何获得的问题
        • 这里绝对不会全文转载任何文章，而只会以链接方式分享1
        • 这里绝对不会有任何教人如何钻空子的讨论
        • 这里感激和崇尚美的事物
        • 这里尊重原创
        • 这里反对中文互联网上的无信息量习惯如“顶”，“沙发”，“前排”，“留名”，“路过”，“不明觉厉”2
        • 这里禁止发布人身攻击、仇恨、暴力、侮辱性的言辞、暴露他人隐私的“人肉贴”
        • 当你在网上发帖时，请考虑到你所做的一切，会受到你所在地区法律的管辖
        • V2EX 不反对文章的原作者自己全文转载自己写的原创文章
        • “路过”，“沙发”之类的 0 信息量回复会被自动规则阻挡或者被管理员删除。和讨论主题完全无关的回复，尤其是在技术类讨论主题下出现的话，会被管理员删除。
        """
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributedText = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor : V2EXColor.colors.v2_TopicListTitleColor,
            .font : v2Font(15),
            .paragraphStyle: style])
        label.attributedText = attributedText
        label.numberOfLines = 0
        return label
    }()
    let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("userAgreement")
        
        self.view.backgroundColor = V2EXColor.colors.v2_backgroundColor
        
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(SCREEN_WIDTH - 20)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: 20 + textLabel.bounds.size.height)
    }
}
