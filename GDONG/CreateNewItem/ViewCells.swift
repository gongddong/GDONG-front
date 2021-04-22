//
//  ViewCells.swift
//  GDONG
//
//  Created by Woochan Park on 2021/04/23.
//

import UIKit

class PhotoCell: UITableViewCell {

  @IBAction func AddPhoto(_ sender: UIButton) {
    
    
  }
  override func awakeFromNib() {
      super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class TextViewCell: UITableViewCell {
  
  @IBOutlet weak var textView: UITextView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.setPlaceHolderText()
  }
  
  func setPlaceHolderText() {
    textView.text = "이 곳에 글 내용을 입력해주세요"
    textView.textColor = .lightGray
  }
}

extension TextViewCell: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == .lightGray {
      textView.text = nil
      textView.textColor = .black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      setPlaceHolderText()
    }
  }
}