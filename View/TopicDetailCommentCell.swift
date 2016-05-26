//
//  TopicDetailCommentCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/20/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import YYText

class TopicDetailCommentCell: UITableViewCell{
    /// 头像
    var avatarImageView: UIImageView?
    /// 用户名
    var userNameLabel: UILabel?
    /// 日期 和 最后发送人
    var dateLabel: UILabel?

    /// 回复正文
    var commentLabel: YYLabel?
    
    /// 装上面定义的那些元素的容器
    var contentPanel:UIView?
    
    //评论喜欢数
    var favoriteIconView:UIImageView?
    var favoriteLabel:UILabel?
    
    weak var itemModel:TopicCommentModel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func setup()->Void{
        self.backgroundColor=V2EXColor.colors.v2_backgroundColor;
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = V2EXColor.colors.v2_backgroundColor
        self.selectedBackgroundView = selectedBackgroundView
        
        self.contentPanel = UIView();
        self.contentPanel!.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
        self.contentView .addSubview(self.contentPanel!);
        self.contentPanel!.snp_makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
        }
        
        self.avatarImageView = UIImageView();
        self.avatarImageView!.contentMode=UIViewContentMode.ScaleAspectFit;
        self.avatarImageView!.layer.cornerRadius = 3;
        self.avatarImageView!.layer.masksToBounds = true;
        self.contentPanel!.addSubview(self.avatarImageView!);
        self.avatarImageView!.snp_makeConstraints{ (make) -> Void in
            make.left.top.equalTo(self.contentView).offset(12);
            make.width.height.equalTo(35);
        }
        
        self.userNameLabel = UILabel();
        self.userNameLabel!.textColor = V2EXColor.colors.v2_TopicListUserNameColor;
        self.userNameLabel!.font=v2Font(14);
        self.contentPanel! .addSubview(self.userNameLabel!);
        self.userNameLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView!.snp_right).offset(10);
            make.top.equalTo(self.avatarImageView!);
        }
        
        self.favoriteIconView = UIImageView(image: UIImage.imageUsedTemplateMode("ic_favorite_18pt")!)
        self.favoriteIconView?.tintColor = V2EXColor.colors.v2_TopicListDateColor;
        self.favoriteIconView?.contentMode = .ScaleAspectFit
        self.contentPanel?.addSubview(self.favoriteIconView!)
        self.favoriteIconView!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.userNameLabel!);
            make.left.equalTo(self.userNameLabel!.snp_right).offset(10)
            make.width.height.equalTo(10)
        }
        self.favoriteIconView!.hidden = true
        
        self.favoriteLabel = UILabel()
        self.favoriteLabel!.textColor = V2EXColor.colors.v2_TopicListDateColor;
        self.favoriteLabel!.font = v2Font(10)
        self.contentPanel!.addSubview(self.favoriteLabel!)
        self.favoriteLabel!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.favoriteIconView!.snp_right).offset(3)
            make.centerY.equalTo(self.favoriteIconView!)
        }
        
        self.dateLabel = UILabel();
        self.dateLabel!.textColor=V2EXColor.colors.v2_TopicListDateColor;
        self.dateLabel!.font=v2Font(12);
        self.contentPanel?.addSubview(self.dateLabel!);
        self.dateLabel!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView!);
            make.left.equalTo(self.userNameLabel!);
        }
        
        self.commentLabel = YYLabel();
        self.commentLabel!.textColor=V2EXColor.colors.v2_TopicListTitleColor;
        self.commentLabel!.font = v2Font(14);
        self.commentLabel!.numberOfLines = 0;
        self.commentLabel!.displaysAsynchronously = true
        self.contentPanel?.addSubview(self.commentLabel!);
        self.commentLabel!.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView!.snp_bottom).offset(12);
            make.left.equalTo(self.avatarImageView!);
            make.right.equalTo(self.contentPanel!).offset(-12);
            make.bottom.equalTo(self.contentPanel!.snp_bottom).offset(-12)
        }
        
        self.contentPanel!.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.contentView.snp_bottom).offset(-SEPARATOR_HEIGHT);
        }
        
        self.avatarImageView!.backgroundColor = self.contentPanel!.backgroundColor
        self.userNameLabel!.backgroundColor = self.contentPanel!.backgroundColor
        self.dateLabel!.backgroundColor = self.contentPanel!.backgroundColor
        self.commentLabel!.backgroundColor = self.contentPanel!.backgroundColor
        self.favoriteIconView!.backgroundColor = self.contentPanel!.backgroundColor
        self.favoriteLabel!.backgroundColor = self.contentPanel!.backgroundColor
        
        //点击用户头像，跳转到用户主页
        self.avatarImageView!.userInteractionEnabled = true
        self.userNameLabel!.userInteractionEnabled = true
        var userNameTap = UITapGestureRecognizer(target: self, action: #selector(TopicDetailCommentCell.userNameTap(_:)))
        self.avatarImageView!.addGestureRecognizer(userNameTap)
        userNameTap = UITapGestureRecognizer(target: self, action: #selector(TopicDetailCommentCell.userNameTap(_:)))
        self.userNameLabel!.addGestureRecognizer(userNameTap)
        
        //长按手势
        self.contentView .addGestureRecognizer(
            UILongPressGestureRecognizer(target: self,
                action: #selector(TopicDetailCommentCell.longPressHandle(_:))
            )
        )
    }
    func userNameTap(sender:UITapGestureRecognizer) {
        if let _ = self.itemModel , username = itemModel?.userName {
            let memberViewController = MemberViewController()
            memberViewController.username = username
            V2Client.sharedInstance.topNavigationController.pushViewController(memberViewController, animated: true)
        }
    }
    func bind(model:TopicCommentModel){
        
        
        self.userNameLabel?.text = model.userName;
        self.dateLabel?.text = model.date

        
        if model != self.itemModel {
            //如果新旧model相同,则不需要赋值
            //不然layout需要重新绘制，会造成刷新闪烁
            if let layout = model.textLayout {
                self.commentLabel?.textLayout = layout
                if layout.attachments != nil {
                    for attachment in layout.attachments {
                        if let attachment = attachment as? YYTextAttachment ,  let image = attachment.content as? V2CommentAttachmentImage{
                            image.delegate = self
                        }
                    }
                }
            }
        }
        
        if let avata = model.avata {
            self.avatarImageView?.fin_setImageWithUrl(NSURL(string: "https:" + avata)!, placeholderImage: nil, imageModificationClosure: fin_defaultImageModification())
        }
        
        self.favoriteIconView!.hidden = model.favorites <= 0
        self.favoriteLabel!.text = model.favorites <= 0 ? "" : "\(model.favorites)"
        
        self.itemModel = model
    }
}

//MARK: - 点击图片
extension TopicDetailCommentCell : V2CommentAttachmentImageTapDelegate ,V2PhotoBrowserDelegate {
    func V2CommentAttachmentImageSingleTap(imageView: V2CommentAttachmentImage) {
        let photoBrowser = V2PhotoBrowser(delegate: self)
        photoBrowser.currentPageIndex = imageView.index
        V2Client.sharedInstance.topNavigationController.presentViewController(photoBrowser, animated: true, completion: nil)
    }
    
    //V2PhotoBrowser Delegate
    func numberOfPhotosInPhotoBrowser(photoBrowser: V2PhotoBrowser) -> Int {
        return self.itemModel!.images.count
    }
    func photoAtIndexInPhotoBrowser(photoBrowser: V2PhotoBrowser, index: Int) -> V2Photo {
        let photo = V2Photo(url: NSURL(string: self.itemModel!.images[index] as! String)!)
        return photo
    }
    func guideContentModeInPhotoBrowser(photoBrowser: V2PhotoBrowser, index: Int) -> UIViewContentMode {
        if let attachment = self.itemModel!.textLayout!.attachments[index]as? YYTextAttachment , image = attachment.content  as? V2CommentAttachmentImage{
            return image.contentMode
        }
        return .Center
    }
    func guideFrameInPhotoBrowser(photoBrowser: V2PhotoBrowser, index: Int) -> CGRect {
        if let attachment = self.itemModel!.textLayout!.attachments[index]as? YYTextAttachment , image = attachment.content  as? V2CommentAttachmentImage{
            return image .convertRect(image.bounds, toView: UIApplication.sharedApplication().keyWindow!)
        }
        return CGRectZero
    }
    func guideImageInPhotoBrowser(photoBrowser: V2PhotoBrowser, index: Int) -> UIImage? {
        if let attachment = self.itemModel!.textLayout!.attachments[index]as? YYTextAttachment , image = attachment.content  as? V2CommentAttachmentImage{
            return image.image
        }
        return nil
    }
}

//MARK: - 长按复制功能
extension TopicDetailCommentCell {
    func longPressHandle(longPress:UILongPressGestureRecognizer) -> Void {
        if (longPress.state == .Began) {
            self.becomeFirstResponder()
            
            let item = UIMenuItem(title: "复制", action: #selector(TopicDetailCommentCell.copyText))
            
            let menuController = UIMenuController.sharedMenuController()
            menuController.menuItems = [item]
            menuController.arrowDirection = .Down
            menuController.setTargetRect(self.frame, inView: self.superview!)
            menuController.setMenuVisible(true, animated: true);
        }
        
    }
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if (action == #selector(TopicDetailCommentCell.copyText)){
            return true
        }
        return super.canPerformAction(action, withSender: sender);
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func copyText() -> Void {
        UIPasteboard.generalPasteboard().string = self.itemModel?.textLayout?.text.string
    }
}
