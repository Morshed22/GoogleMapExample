//
//  MakerInfoView.swift
//  GGMaP
//
//  Created by Morshed Alam on 1/30/17.
//  Copyright © 2017 Morshed Alam. All rights reserved.
//

import UIKit

class MakerInfoView: UIView {

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var duration: UILabel!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIView{

    class func viewFromNibName(_ name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views?.first as? UIView
    }

}
