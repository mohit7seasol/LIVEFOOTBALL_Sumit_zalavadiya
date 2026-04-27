//
//  LinesUpsViewXIB.swift
//  Football2
//
//  Created by Parthiv Akbari on 01/05/25.
//

import UIKit

class LinesUpsViewXIB: UIView {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var lblShirtNum: UILabel!
    @IBOutlet weak var lblNAme: UILabel!
    
    override init(frame: CGRect) {
           super.init(frame: frame)
           setUp()
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
           setUp()
       }
       
       func setUp(){
           Bundle.main.loadNibNamed("LinesUpsViewXIB", owner: self)
           addSubview(mainView)
           mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           mainView.frame = self.bounds
       }
    
   
    

}
