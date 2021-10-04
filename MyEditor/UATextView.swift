//------------------------------------------------------------------------------
//  UATextView.swift
//------------------------------------------------------------------------------
import Cocoa
class UATextView: NSView {
    var text: NSMutableAttributedString?
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let unText = text{
            let x: CGFloat = (self.frame.size.width/2)-(unText.size().width/2);
            let y: CGFloat = (self.frame.size.height/2)-(unText.size().height/2);
            unText.draw(at: NSMakePoint(x, y))
        }else{
            return
        }
    }
}
