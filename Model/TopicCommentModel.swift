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
    
    weak var attachmentDelegate : V2CommentAttachmentImageTapDelegate?
    
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
            self.kf.setImage(with: URL, placeholder: nil, options: nil, completionHandler: { (result) -> () in
                switch result {
                case .success(let imageResult):
                    let image = imageResult.image
                    if image.size.width < 80 && image.size.height < 80 {
                        self.contentMode = .bottomLeft
                    }
                default:
                    break
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
        self.attachmentDelegate?.V2CommentAttachmentImageSingleTap(self)
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
            
            let urlHandler: (_ attributedString:NSMutableAttributedString, _ url:String, _ url:String)->() = {attributedString,title,url in
                let attr = NSMutableAttributedString(string: title ,attributes: [NSAttributedString.Key.font:v2ScaleFont(14)])
                attr.yy_setTextHighlight(NSMakeRange(0, title.Lenght),
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
            
            if element.name == "text" , let content = element.content{//普通文本
                commentAttributedString.append(NSMutableAttributedString(string: content,attributes: [NSAttributedString.Key.font:v2ScaleFont(14) , NSAttributedString.Key.foregroundColor:V2EXColor.colors.v2_TopicListTitleColor]))
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
                    urlHandler(commentAttributedString,content,url)
                }
            }
                
            else if element.name == "br" {
                commentAttributedString.yy_appendString("\n")
            }
                
            else if element.children.first?.name == "iframe", let src = element.children.first?["src"] , src.Lenght > 0 {
                // youtube 视频
                urlHandler(commentAttributedString,src,src)
            }
            else if let content = element.content{//其他
                
                commentAttributedString.append(NSMutableAttributedString(string: content,attributes: [NSAttributedString.Key.foregroundColor:V2EXColor.colors.v2_TopicListTitleColor]))
            }
        }
    }
}

//MARK: - Request
extension TopicCommentModel {
    class func replyWithTopicId(_ topic:TopicDetailModel, content:String,
                                completionHandler: @escaping (V2Response) -> Void){
        let requestPath = "t/" + topic.topicId!
        let url = V2EXURL + requestPath
        
        V2User.sharedInstance.getOnce(url) { (response) -> Void in
            if response.success {
                let prames = [
                    "content":content,
                    "once":V2User.sharedInstance.once!
                ] as [String:Any]
                
                Alamofire.request(url, method: .post, parameters: prames, headers: MOBILE_CLIENT_HEADERS).responseJiHtml { (response) -> Void in
                    let url = response.response?.url
                    if url?.path.hasSuffix(requestPath) == true && url?.fragment?.hasPrefix("reply") == true{   
                       completionHandler(V2Response(success: true))
                    }
                    else if let problems = response.result.value?.xPath("//*[@class='problem']/ul/li") {
                        let problemStr = problems.map{ $0.content ?? "回帖失败" }.joined(separator: "\n")
                        completionHandler(V2Response(success: false,message: problemStr))
                    }
                    else{
                        completionHandler(V2Response(success: false,message: "请求失败"))
                    }
                    //不管成功还是失败，更新一下once
                    if let jiHtml = response .result.value{
                        V2User.sharedInstance.once = jiHtml.xPath("//*[@name='once'][1]")?.first?["value"]
                    }
                }
            }
            else{
                completionHandler(V2Response(success: false,message: "获取once失败，请重试"))
            }
        }
    }
    
    class func replyThankWithReplyId(_ replyId:String , token:String ,completionHandler: @escaping (V2Response) -> Void) {
        
        _ = TopicApi.provider.requestAPI(.thankReply(replyId: replyId, once: token))
            .filterResponseError().subscribe(onNext: { (response) in
            if response["success"].boolValue {
                completionHandler(V2Response(success: true))
            }
            else{
                completionHandler(V2Response(success: false))
            }
        }, onError: { (error) in
            completionHandler(V2Response(success: false))
        })
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
        
        var users = getUsersOfComment(firstComment)

        //当前会话所有相关的用户（ B 回复 A， C 回复 B， D 回复 C， 查看D的对话时， D C B 为相关联用户）
        var relateUsers:Set<String> = users
        for comment in allCommentsArray {
            //被回复人所@的人也加进对话，但是不递归获取所有关系链（可能获取到无意义的数据）
            if let username = comment.userName, users.contains(username) {
                let commentUsers = getUsersOfComment(comment)
                relateUsers = relateUsers.union(commentUsers)
            }
            //只找到点击的位置，之后就不找了
            if comment == firstComment {
                break;
            }
        }
        
        users.insert(firstComment.userName!)
        
        for comment in allCommentsArray {
            //判断评论中是否@的所有用户和会话相关联的用户无关，是的话则证明这条评论是和别人讲的，不属于当前对话
            let commentUsers = getUsersOfComment(comment)
            let intersectUsers = commentUsers.intersection(relateUsers)
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
    class func getUsersOfComment(_ comment:TopicCommentModel) -> Set<String>  {
        
        //获取到所有YYTextHighlight ，用以之后获取 这条评论@了多少用户
        var textHighlights:[YYTextHighlight] = []
        comment.textAttributedString!.enumerateAttribute(NSAttributedString.Key(rawValue: YYTextHighlightAttributeName), in: NSMakeRange(0, comment.textAttributedString!.length), options: []) { (attribute, range, stop) -> Void in
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
