//
//  TopicDetailModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/16/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import Alamofire
import Ji
import YYText

class TopicDetailModel:NSObject,BaseHtmlModelProtocol {
    var topicId:String?
    
    var avata: String?
    var nodeName: String?
    var nodeUrl: String?
    
    var userName: String?
    
    var topicTitle: String?
    var topicContent: String?
    var date: String?
    var favorites: String?
    
    var topicCommentTotalCount: String?
    
    var token:String?
    
    override init() {
        
    }
    required init(rootNode: JiNode) {
        let node = rootNode.xPath("./div[1]/a[2]").first
        self.nodeName = node?.content
        self.nodeUrl = node?["href"]
        
        self.avata = rootNode.xPath("./div[1]/div[1]/a/img").first?["src"]
        
        self.userName = rootNode.xPath("./div[1]/small/a").first?.content
        
        self.topicTitle = rootNode.xPath("./div[1]/h1").first?.content
        
        self.topicContent = rootNode.xPath("./div[@class='cell']/div").first?.rawContent
        
        self.date = rootNode.xPath("./div[1]/small/text()[2]").first?.content
        
        self.favorites = rootNode.xPath("./div[3]/div/span").first?.content
        
        let token = rootNode.xPath("div/div/a[@class='op'][1]").first?["href"]
        if let token = token {
            let array = token.componentsSeparatedByString("?t=")
            if array.count == 2 {
                self.token = array[1]
            }
        }
    }
    
    
    class func getTopicDetailById(
        topicId: String,
        completionHandler: V2ValueResponse<(TopicDetailModel?,[TopicCommentModel])> -> Void
        )->Void{
            
            let url = V2EXURL + "t/" + topicId + "?p=1"
            
            Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
                var topicModel: TopicDetailModel? = nil
                var topicCommentsArray : [TopicCommentModel] = []
                    if  let jiHtml = response.result.value {
                        //获取帖子内容
                        if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div/div[1]")?.first{
                            topicModel = TopicDetailModel(rootNode: aRootNode);
                            topicModel?.topicId = topicId
                        }
                        
                        //获取评论
                        if let aRootNode = jiHtml.xPath("//*[@id='Wrapper']/div/div[@class='box'][2]/div[attribute::id]"){
                            for aNode in aRootNode {
                                topicCommentsArray.append(TopicCommentModel(rootNode: aNode))
                            }
                        }
                        //获取评论总数
                        if let commentTotalCount = jiHtml.xPath("//*[@id='Wrapper']/div/div[3]/div[1]/span") {
                            topicModel?.topicCommentTotalCount = commentTotalCount.first?.content
                        }
                        
                        //更新通知数量
                        V2Client.sharedInstance.getNotificationsCount(jiHtml.rootNode!)
                    }

                let t = V2ValueResponse<(TopicDetailModel?,[TopicCommentModel])>(value:(topicModel,topicCommentsArray), success: response.result.isSuccess)
                
                completionHandler(t);
            }
            
    }
}

/// 评论中的图片
class V2CommentAttachmentImage:UIImageView {
    var imageURL:String?
    
    init(){
        super.init(frame: CGRectMake(0, 0, 80, 80))
        self.contentMode = .ScaleAspectFill
        self.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if self.image != nil {
            return
        }
        if  let imageURL = self.imageURL , let URL = NSURL(string: imageURL) {
            self.kf_setImageWithURL(URL)
        }
    }
}

class TopicCommentModel: NSObject,BaseHtmlModelProtocol {
    var replyId:String?
    var avata: String?
    var userName: String?
    var date: String?
    var comment: String?
    var favorites: Int = 0
    var textLayout:YYTextLayout?
    required init(rootNode: JiNode) {
        let id = rootNode.xPath("table/tr/td[3]/div[1]/div[attribute::id]").first?["id"]
        if let id = id {
            if id.hasPrefix("thank_area_") {
                self.replyId = id.stringByReplacingOccurrencesOfString("thank_area_", withString: "")
            }
        }
        
        self.avata = rootNode.xPath("table/tr/td[1]/img").first?["src"]
        
        self.userName = rootNode.xPath("table/tr/td[3]/strong/a").first?.content
        
        self.date = rootNode.xPath("table/tr/td[3]/span").first?.content
        
        if let favorite = rootNode.xPath("table/tr/td[3]/span[2]").first?.content {
            let array = favorite.componentsSeparatedByString(" ")
            if array.count == 2 {
                if let i = Int(array[1]){
                    self.favorites = i
                }
            }
        }
        
        //构造评论内容
        
        
        let commentAttributedString:NSMutableAttributedString = NSMutableAttributedString(string: "")
        let nodes = rootNode.xPath("table/tr/td[3]/div[@class='reply_content']/node()")
        for element in nodes {

            if element.name == "text" , let content = element.content{//普通文本
                commentAttributedString.appendAttributedString(NSMutableAttributedString(string: content,attributes: [NSFontAttributeName:v2Font(14) , NSForegroundColorAttributeName:V2EXColor.colors.v2_TopicListTitleColor]))
                commentAttributedString.yy_lineSpacing = 5
            }
                
                
            else if element.name == "img" ,let imageURL = element["src"]  {//图片
                let image = V2CommentAttachmentImage()
                image.imageURL = imageURL
                let imageAttributedString = NSMutableAttributedString.yy_attachmentStringWithContent(image, contentMode: .ScaleAspectFit , attachmentSize: CGSizeMake(80, 80), alignToFont: v2Font(14), alignment: .Bottom)
                imageAttributedString
                commentAttributedString.appendAttributedString(imageAttributedString)
            }
                
                
            else if element.name == "a" ,let content = element.content,let url = element["href"]{//超链接
                let attr = NSMutableAttributedString(string: content ,attributes: [NSFontAttributeName:v2Font(14)])
                attr.yy_setTextHighlightRange(NSMakeRange(0, content.Lenght),
                    color: V2EXColor.colors.v2_LinkColor,
                    backgroundColor: UIColor(white: 0.95, alpha: 1),
                    userInfo: ["url":url],
                    tapAction: { (view, text, range, rect) -> Void in
                        if let highlight = text.yy_attribute(YYTextHighlightAttributeName, atIndex: UInt(range.location)) ,let url = highlight.userInfo["url"] as? String  {
                            AnalyzeURLHelper.Analyze(url)
                        }
                    
                    }, longPressAction: nil)
                commentAttributedString.appendAttributedString(attr)
            }
                
                
            else if let content = element.content{//其他
                commentAttributedString.appendAttributedString(NSMutableAttributedString(string: content,attributes: [NSForegroundColorAttributeName:V2EXColor.colors.v2_TopicListTitleColor]))
            }
        }
        let textContainer = YYTextContainer(size: CGSizeMake(SCREEN_WIDTH - 24, SCREEN_HEIGHT))
        self.textLayout = YYTextLayout(container: textContainer, text: commentAttributedString)
        self.textLayout?.textBoundingRect
    
    }
    
    
    class func replyWithTopicId(topic:TopicDetailModel, content:String,
        completionHandler: V2Response -> Void
        )
    {
        let url = V2EXURL + "t/" + topic.topicId!
        
        V2Client.sharedInstance.getOnce(url) { (response) -> Void in
            if response.success {
                let prames = [
                    "content":content,
                    "once":V2Client.sharedInstance.once!
                ]
                
                Alamofire.request(.POST, url, parameters: prames, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
                    if let location = response.response?.allHeaderFields["Etag"] as? String{
                        if location.Lenght > 0 {
                            completionHandler(V2Response(success: true))
                        }
                        else {
                            completionHandler(V2Response(success: false, message: "回帖失败"))
                        }
                        
                        //不管成功还是失败，更新一下once
                        if let jiHtml = response .result.value{
                            V2Client.sharedInstance.once = jiHtml.xPath("//*[@name='once'][1]")?.first?["value"]
                        }
                        return
                    }
                    completionHandler(V2Response(success: false,message: "请求失败"))
                }
            }
            else{
                completionHandler(V2Response(success: false,message: "获取once失败，请重试"))
            }
        }
    }
    
    class func replyThankWithReplyId(replyId:String , token:String ,completionHandler: V2Response -> Void) {
        let url  = V2EXURL + "thank/reply/" + replyId + "?t=" + token
        Alamofire.request(.POST, url, parameters: nil, encoding: .URL, headers: MOBILE_CLIENT_HEADERS).responseString { (response: Response<String,NSError>) -> Void in
            if response.result.isSuccess {
                if let result = response.result.value {
                    if result.Lenght == 0 {
                        completionHandler(V2Response(success: true))
                        return;
                    }
                }
            }
            completionHandler(V2Response(success: false))
        }
    }
}
