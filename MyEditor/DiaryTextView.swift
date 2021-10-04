//---- DiaryTextView.swift ----
//おそらく不要
import Cocoa

class DiaryTextView: NSTextView {
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.backgroundColor = NSColor.yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}
