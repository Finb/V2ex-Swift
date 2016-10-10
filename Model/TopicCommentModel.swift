//
//  TopicCommentModel.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/24/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

import Alamofire
import Ji
import YYText
import Kingfisher

protocol V2CommentAttachmentImageTapDelegate : class {
    func V2CommentAttachmentImageSingleTap(_ imageView:V2CommentAttachmentImage)
}
/// 评论中的图片
class V2CommentAttachmentImage:AnimatedImageView {
    /// 父容器中第几张图片
    var index:Int = 0
    
    /// 图片地址
    var imageURL:String?
    
    weak var delegate : V2CommentAttachmentImageTapDelegate?
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        self.autoPlayAnimatedImage = false;
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if self.image != nil {
            return
        }
        if  let imageURL = self.imageURL , let URL = URL(string: imageURL) {
            self.kf.setImage(with: URL, placeholder: nil, options: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                if let image = image {
                    if image.size.width < 80 && image.size.height < 80 {
                        self.contentMode = .bottomLeft
                    }
                }
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let tapCount = touch?.tapCount
        if let tapCount = tapCount {
            if tapCount == 1 {
                self.handleSingleTap(touch!)
            }
        }
        //取消后续的事件响应
        self.next?.touchesCancelled(touches, with: event)
    }
    func handleSingleTap(_ touch:UITouch){
        self.delegate?.V2CommentAttachmentImageSingleTap(self)
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
    var images:NSMutableArray = NSMutableArray()
    //楼层
    var number:Int = 0
    
    var textAttributedString:NSMutableAttributedString?
    required init(rootNode: JiNode) {
        super.init()
        
        let id = rootNode.xPath("table/tr/td[3]/div[1]/div[attribute::id]").first?["id"]
        if let id = id {
            if id.hasPrefix("thank_area_") {
                self.replyId = id.replacingOccurrences(of: "thank_area_", with: "")
            }
        }
        
        self.avata = rootNode.xPath("table/tr/td[1]/img").first?["src"]
        
        self.userName = rootNode.xPath("table/tr/td[3]/strong/a").first?.content
        
        self.date = rootNode.xPath("table/tr/td[3]/span").first?.content
        
        if let str = rootNode.xPath("table/tr/td[3]/div[@class='fr']/span").first?.content  , let no =  Int(str){
            self.number = no;
        }
        
        if let favorite = rootNode.xPath("table/tr/td[3]/span[2]").first?.content {
            let array = favorite.components(separatedBy: " ")
            if array.count == 2 {
                if let i = Int(array[1]){
                    self.favorites = i
                }
            }
        }
        
        //构造评论内容
        let commentAttributedString:NSMutableAttributedString = NSMutableAttributedString(string: "")
        let nodes = rootNode.xPath("table/tr/td[3]/div[@class='reply_content']/node()")
        self.preformAttributedString(commentAttributedString, nodes: nodes)
        let textContainer = YYTextContainer(size: CGSize(width: SCREEN_WIDTH - 24, height: 9999))
        self.textLayout = YYTextLayout(container: textContainer, text: commentAttributedString)
        
        self.textAttributedString = commentAttributedString
    }
    func preformAttributedString(_ commentAttributedString:NSMutableAttributedString,nodes:[JiNode]) {
        for element in nodes {
            
            if element.name == "text" , let content = element.content{//普通文本
                commentAttributedString.append(NSMutableAttributedString(string: content,attributes: [NSFontAttributeName:v2ScaleFont(14) , NSForegroundColorAttributeName:V2EXColor.colors.v2_TopicListTitleColor]))
                commentAttributedString.yy_lineSpacing = 5
            }
                
                
            else if element.name == "img" ,let imageURL = element["src"]  {//图片
                let image = V2CommentAttachmentImage()
                image.imageURL = imageURL
                let imageAttributedString = NSMutableAttributedString.yy_attachmentString(withContent: image, contentMode: .scaleAspectFit , attachmentSize: CGSize(width: 80,height: 80), alignTo: v2ScaleFont(14), alignment: .bottom)
                
                commentAttributedString.append(imageAttributedString)
                
                image.index = self.images.count
                self.images.add(imageURL)
            }
                
                
            else if element.name == "a" ,let content = element.content,let url = element["href"]{//超链接
                //递归处理所有子节点,主要是处理下 a标签下包含的img标签
                let subNodes = element.xPath("./node()")
                if subNodes.first?.name != "text" && subNodes.count > 0 {
                    self.preformAttributedString(commentAttributedString, nodes: subNodes)
                }
                if content.Lenght > 0 {
                    let attr = NSMutableAttributedString(string: content ,attributes: [NSFontAttributeName:v2ScaleFont(14)])
                    attr.yy_setTextHighlight(NSMakeRange(0, content.Lenght),
                                                  color: V2EXColor.colors.v2_LinkColor,
                                                  backgroundColor: UIColor(white: 0.95, alpha: 1),
                                                  userInfo: ["url":url],
                                                  tapAction: { (view, text, range, rect) -> Void in
                                                    if let highlight = text.yy_attribute(YYTextHighlightAttributeName, at: UInt(range.location)) ,let url = (highlight as AnyObject).userInfo["url"] as? String  {
                                                        AnalyzeURLHelper.Analyze(url)
                                                    }
                                                    
                        }, longPressAction: nil)
                    commentAttributedString.append(attr)
                }
            }
                
                
            else if let content = element.content{//其他
                commentAttributedString.append(NSMutableAttributedString(string: content,attributes: [NSForegroundColorAttributeName:V2EXColor.colors.v2_TopicListTitleColor]))
            }
        }
    }
}

//MARK: - Request
extension TopicCommentModel {
    class func replyWithTopicId(_ topic:TopicDetailModel, content:String,
                                completionHandler: @escaping (V2Response) -> Void){
        let url = V2EXURL + "t/" + topic.topicId!
        
        V2User.sharedInstance.getOnce(url) { (response) -> Void in
            if response.success {
                let prames = [
                    "content":content,
                    "once":V2User.sharedInstance.once!
                ] as [String:Any]
                
                Alamofire.request(url, method: .post, parameters: prames, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
                    if let location = response.response?.allHeaderFields["Etag"] as? String{
                        if location.Lenght > 0 {
                            completionHandler(V2Response(success: true))
                        }
                        else {
                            completionHandler(V2Response(success: false, message: "回帖失败"))
                        }
                        
                        //不管成功还是失败，更新一下once
                        if let jiHtml = response .result.value{
                            V2User.sharedInstance.once = jiHtml.xPath("//*[@name='once'][1]")?.first?["value"]
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
    
    class func replyThankWithReplyId(_ replyId:String , token:String ,completionHandler: @escaping (V2Response) -> Void) {
        let url  = V2EXURL + "thank/reply/" + replyId + "?t=" + token
        Alamofire.request(url, method: .post, headers: MOBILE_CLIENT_HEADERS).responseString { (response: DataResponse<String>) -> Void in
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


//MARK: - Method
extension TopicCommentModel {
    /**
     用某一条评论，获取和这条评论有关的所有评论
     
     - parameter array: 所有的评论数组
     - parameter firstComment: 这条评论
     
     - returns: 某一条评论相关的评论，里面包含它自己
     */
    class func getRelevantCommentsInArray(_ allCommentsArray:[TopicCommentModel], firstComment:TopicCommentModel) -> [TopicCommentModel] {
        
        var relevantComments:[TopicCommentModel] = []
        
        var users = getUsersInComment(firstComment)
        users.insert(firstComment.userName!)
        
        for comment in allCommentsArray {
            
            //判断评论中是否只@了其他用户，是的话则证明这条评论是和别人讲的，不属于当前对话
            let commentUsers = getUsersInComment(comment)
            let intersectUsers = commentUsers.intersection(users)
            if commentUsers.count > 0 && intersectUsers.count <= 0 {
                continue;
            }
            
            if let username = comment.userName {
                if users.contains(username) {
                    relevantComments.append(comment)
                }
            }
            //只找到点击的位置，之后就不找了
            if comment == firstComment {
                break;
            }
        }
        
        return relevantComments
    }
    
    //获取评论中 @ 了多少用户
    class func getUsersInComment(_ comment:TopicCommentModel) -> Set<String>  {
        
        //获取到所有YYTextHighlight ，用以之后获取 这条评论@了多少用户
        var textHighlights:[YYTextHighlight] = []
        comment.textAttributedString!.enumerateAttribute(YYTextHighlightAttributeName, in: NSMakeRange(0, comment.textAttributedString!.length), options: []) { (attribute, range, stop) -> Void in
            if let highlight = attribute as? YYTextHighlight {
                textHighlights.append(highlight)
            }
        }
        
        //获取这条评论 @ 了多少用户
        var users:Set<String> = []
        for highlight in textHighlights {
            if let url = highlight.userInfo?["url"] as? String{
                let result = AnalyzURLResultType(url: url)
                if case .member(let member) = result {
                    users.insert(member.username)
                }
            }
        }
        
        return users
    }
}
