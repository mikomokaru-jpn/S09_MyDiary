//---- UALine.swift ----
import Cocoa

class UALine: NSBox {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.borderColor = NSColor.black
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.borderColor = NSColor.black

        // Drawing code here.
    }
    
}
