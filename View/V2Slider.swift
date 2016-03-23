//
//  V2Slider.swift
//  V2ex-Swift
//
//  Created by huangfeng on 3/10/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit

class V2Slider: UISlider {
    var valueChanged : ( (value:Float) -> Void )?
    
    init(){
        super.init(frame: CGRectZero)
        self.minimumValue = 0
        self.maximumValue = 16
        self.value = (V2Style.sharedInstance.fontScale - 0.8 ) / 0.5 * 10
        self.addTarget(self, action: #selector(V2Slider.valueChanged(_:)), forControlEvents: [.ValueChanged])
        
        self.KVOController.observe(V2EXColor.sharedInstance, keyPath: "style", options: [.Initial,.New]) {_ in
            self.minimumTrackTintColor = V2EXColor.colors.v2_TopicListTitleColor
            self.maximumTrackTintColor = V2EXColor.colors.v2_backgroundColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func valueChanged(sender:UISlider) {
        sender.value = Float(Int(sender.value))
        valueChanged?(value: sender.value)
    }
}
