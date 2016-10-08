//
//  V2Slider.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/10/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class V2Slider: UISlider {
    var valueChanged : ( (_ value:Float) -> Void )?
    
    init(){
        super.init(frame: CGRect.zero)
        self.minimumValue = 0
        self.maximumValue = 16
        self.value = (V2Style.sharedInstance.fontScale - 0.8 ) / 0.5 * 10
        self.addTarget(self, action: #selector(V2Slider.valueChanged(_:)), for: [.valueChanged])
        
        self.thmemChangedHandler = {[weak self] (style) -> Void in
            self?.minimumTrackTintColor = V2EXColor.colors.v2_TopicListTitleColor
            self?.maximumTrackTintColor = V2EXColor.colors.v2_backgroundColor
        }
    }
    deinit {
        print("deinit")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func valueChanged(_ sender:UISlider) {
        sender.value = Float(Int(sender.value))
        valueChanged?(sender.value)
    }
}
