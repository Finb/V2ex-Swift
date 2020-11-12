//
//  TopicDetailCommentCell.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/20/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import YYText
import SnapKit

class TopicDetailCommentCell: UITableViewCell{
    /// 头像
    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.contentMode=UIView.ContentMode.scaleAspectFit
        avatarImageView.layer.cornerRadius = 3
        avatarImageView.layer.masksToBounds = true
        return avatarImageView
    }()
    /// 用户名
    var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.font=v2Font(14)
        return userNameLabel
    }()
    var authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.font=v2Font(12)
        return authorLabel
    }()
    /// 日期 和 最后发送人
    var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font=v2Font(12)
        return dateLabel
    }()

    /// 回复正文
    var commentLabel: YYLabel = {
        let commentLabel = YYLabel();
        commentLabel.font = v2Font(14);
        commentLabel.numberOfLines = 0;
        commentLabel.displaysAsynchronously = true
        return commentLabel
    }()
    
    /// 装上面定义的那些元素的容器
    var contentPanel: UIView = {
        let view = UIView()
        return view
    }()
    
    //评论喜欢数
    var favoriteIconView:UIImageView = {
        let favoriteIconView = UIImageView(image: UIImage.imageUsedTemplateMode("ic_favorite_18pt")!)
        favoriteIconView.contentMode = .scaleAspectFit
        favoriteIconView.isHidden = true
        return favoriteIconView
    }()

    var favoriteLabel:UILabel = {
        let favoriteLabel = UILabel()
        favoriteLabel.font = v2Font(10)
        return favoriteLabel
    }()
    var itemModel:TopicCommentModel?
    
    var isAuthor:Bool = false {
        didSet {
            self.authorLabel.text = isAuthor ? "• 楼主" : ""
        }
    }
    
    //文本高度约束
    //因YYLabel自适应高度不完善，最好还是在在绑定数据时，手动更新
    //如果换成UILabel或其他自适应高度Label控件，则不需要这一步
    var textLabelHeight: Constraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.setup();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup()->Void{
        let selectedBackgroundView = UIView()
        self.selectedBackgroundView = selectedBackgroundView
        
        self.contentView.addSubview(self.contentPanel);
        self.contentPanel.addSubview(self.avatarImageView);
        self.contentPanel.addSubview(self.userNameLabel);
        self.contentPanel.addSubview(self.authorLabel);
        self.contentPanel.addSubview(self.favoriteIconView)
        self.contentPanel.addSubview(self.favoriteLabel)
        self.contentPanel.addSubview(self.dateLabel);
        self.contentPanel.addSubview(self.commentLabel);

        self.setupLayout()
        
        //点击用户头像，跳转到用户主页
        self.avatarImageView.isUserInteractionEnabled = true
        self.userNameLabel.isUserInteractionEnabled = true
        var userNameTap = UITapGestureRecognizer(target: self, action: #selector(TopicDetailCommentCell.userNameTap(_:)))
        self.avatarImageView.addGestureRecognizer(userNameTap)
        userNameTap = UITapGestureRecognizer(target: self, action: #selector(TopicDetailCommentCell.userNameTap(_:)))
        self.userNameLabel.addGestureRecognizer(userNameTap)
        
        //长按手势
        self.contentView .addGestureRecognizer(
            UILongPressGestureRecognizer(target: self,
                action: #selector(TopicDetailCommentCell.longPressHandle(_:))
            )
        )
        
        self.themeChangedHandler = {[weak self] _ in
            self?.userNameLabel.textColor = V2EXColor.colors.v2_TopicListUserNameColor
            self?.authorLabel.textColor = V2EXColor.colors.v2_TopicListUserNameColor
            self?.dateLabel.textColor=V2EXColor.colors.v2_TopicListDateColor
            self?.commentLabel.textColor=V2EXColor.colors.v2_TopicListTitleColor;
            self?.contentPanel.backgroundColor = V2EXColor.colors.v2_CellWhiteBackgroundColor
            self?.favoriteIconView.tintColor = V2EXColor.colors.v2_TopicListDateColor;
            self?.favoriteLabel.textColor = V2EXColor.colors.v2_TopicListDateColor;
            self?.backgroundColor = V2EXColor.colors.v2_backgroundColor;
            self?.selectedBackgroundView?.backgroundColor = V2EXColor.colors.v2_backgroundColor
            
            self?.avatarImageView.backgroundColor = self?.contentPanel.backgroundColor
            self?.userNameLabel.backgroundColor = self?.contentPanel.backgroundColor
            self?.authorLabel.backgroundColor = self?.contentPanel.backgroundColor
            self?.dateLabel.backgroundColor = self?.contentPanel.backgroundColor
            self?.commentLabel.backgroundColor = self?.contentPanel.backgroundColor
            self?.favoriteIconView.backgroundColor = self?.contentPanel.backgroundColor
            self?.favoriteLabel.backgroundColor = self?.contentPanel.backgroundColor
        }
    }
    func setupLayout(){
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self.contentView);
        }
        self.avatarImageView.snp.makeConstraints{ (make) -> Void in
            make.left.top.equalToSuperview().offset(12);
            make.width.height.equalTo(35);
        }
        self.userNameLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.avatarImageView.snp.right).offset(10);
            make.top.equalTo(self.avatarImageView);
        }
        self.authorLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.userNameLabel.snp.right).offset(5);
            make.centerY.equalTo(self.userNameLabel);
        }
        self.favoriteIconView.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.authorLabel);
            make.left.equalTo(self.authorLabel.snp.right).offset(5)
            make.width.height.equalTo(10)
        }
        self.favoriteLabel.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.favoriteIconView.snp.right).offset(3)
            make.centerY.equalTo(self.favoriteIconView)
        }
        self.dateLabel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.avatarImageView);
            make.left.equalTo(self.userNameLabel);
        }
        self.commentLabel.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(12);
            make.left.equalTo(self.avatarImageView);
            make.right.equalTo(self.contentPanel).offset(-12);
            
            self.textLabelHeight = make.height.equalTo(0).constraint
            
            make.bottom.equalTo(self.contentPanel.snp.bottom).offset(-12)
        }
        
        self.contentPanel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.contentView).offset(-SEPARATOR_HEIGHT);
        }
    }
    @objc func userNameTap(_ sender:UITapGestureRecognizer) {
        if let _ = self.itemModel , let username = itemModel?.userName {
            let memberViewController = MemberViewController()
            memberViewController.username = username
            V2Client.sharedInstance.topNavigationController.pushViewController(memberViewController, animated: true)
        }
    }
    func bind(_ model:TopicCommentModel){
        
        if let avata = model.avata?.avatarString {
            self.avatarImageView.fin_setImageWithUrl(URL(string: avata)!, placeholderImage: nil, imageModificationClosure: fin_defaultImageModification())
        }
        
        if self.itemModel?.number == model.number && self.itemModel?.userName == model.userName {
            return;
        }
        
        self.userNameLabel.text = model.userName;
        self.dateLabel.text = String(format: "%i楼  %@", model.number, model.date ?? "")
        
        if let layout = model.textLayout {
            self.commentLabel.textLayout = layout
            if layout.attachments != nil {
                for attachment in layout.attachments! {
                    if let image = attachment.content as? V2CommentAttachmentImage{
                        image.attachmentDelegate = self
                    }
                }
            }
            self.textLabelHeight?.update(offset: layout.textBoundingSize.height)
        }
        
        self.favoriteIconView.isHidden = model.favorites <= 0
        self.favoriteLabel.text = model.favorites <= 0 ? "" : "\(model.favorites)"
        
        self.itemModel = model
    }
}

//MARK: - 点击图片
extension TopicDetailCommentCell : V2CommentAttachmentImageTapDelegate ,V2PhotoBrowserDelegate {
    func V2CommentAttachmentImageSingleTap(_ imageView: V2CommentAttachmentImage) {
        let photoBrowser = V2PhotoBrowser(delegate: self)
        photoBrowser.currentPageIndex = imageView.index
        V2Client.sharedInstance.topNavigationController.present(photoBrowser, animated: true, completion: nil)
    }
    
    //V2PhotoBrowser Delegate
    func numberOfPhotosInPhotoBrowser(_ photoBrowser: V2PhotoBrowser) -> Int {
        return self.itemModel!.images.count
    }
    func photoAtIndexInPhotoBrowser(_ photoBrowser: V2PhotoBrowser, index: Int) -> V2Photo {
        let photo = V2Photo(url: URL(string: self.itemModel!.images[index] as! String)!)
        return photo
    }
    func guideContentModeInPhotoBrowser(_ photoBrowser: V2PhotoBrowser, index: Int) -> UIView.ContentMode {
        if let attachment = self.itemModel!.textLayout!.attachments?[index] , let image = attachment.content  as? V2CommentAttachmentImage{
            return image.contentMode
        }
        return .center
    }
    func guideFrameInPhotoBrowser(_ photoBrowser: V2PhotoBrowser, index: Int) -> CGRect {
        if let attachment = self.itemModel!.textLayout!.attachments?[index] , let image = attachment.content  as? V2CommentAttachmentImage{
            return image .convert(image.bounds, to: UIApplication.shared.keyWindow!)
        }
        return CGRect.zero
    }
    func guideImageInPhotoBrowser(_ photoBrowser: V2PhotoBrowser, index: Int) -> UIImage? {
        if let attachment = self.itemModel!.textLayout!.attachments?[index] , let image = attachment.content  as? V2CommentAttachmentImage{
            return image.image
        }
        return nil
    }
}

//MARK: - 长按复制功能
extension TopicDetailCommentCell {
    @objc func longPressHandle(_ longPress:UILongPressGestureRecognizer) -> Void {
        if (longPress.state == .began) {
            self.becomeFirstResponder()
            
            let item = UIMenuItem(title: "复制", action: #selector(TopicDetailCommentCell.copyText))
            
            let menuController = UIMenuController.shared
            menuController.menuItems = [item]
            menuController.arrowDirection = .down
            menuController.setTargetRect(self.frame, in: self.superview!)
            menuController.setMenuVisible(true, animated: true);
        }
        
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (action == #selector(TopicDetailCommentCell.copyText)){
            return true
        }
        return super.canPerformAction(action, withSender: sender);
    }
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    @objc func copyText() -> Void {
        UIPasteboard.general.string = self.itemModel?.textLayout?.text.string
    }
}
