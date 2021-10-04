//---- UAContentView.swift ----
import Cocoa
class UAContentView: NSView {

    var startPoint = NSMakePoint(0, 0)
    var endPoint = NSMakePoint(0, 0)
    
    //マウスのドラッグでウィンドウを移動する
    override func mouseDown(with event: NSEvent) {
        startPoint =  event.locationInWindow
    }
    override func mouseDragged(with event: NSEvent) {
        if startPoint == NSZeroPoint{
            //ボタンの周縁部をクリックするとmouseUpだけ起動する場合があるので対応
            return
        }
        endPoint =  event.locationInWindow
        let xSpan = endPoint.x - startPoint.x
        let ySpan = endPoint.y - startPoint.y
        var newOrigin =  self.window!.frame.origin
        newOrigin.x += xSpan
        newOrigin.y += ySpan
        self.window!.setFrameOrigin(newOrigin)
    }
    override func mouseUp(with event: NSEvent) {
        if startPoint == NSZeroPoint{
            //ボタンの周縁部をクリックするとmouseUpだけ起動する場合があるので対応
            return
        }
        endPoint =  event.locationInWindow
        let xSpan = endPoint.x - startPoint.x
        let ySpan = endPoint.y - startPoint.y
        var newOrigin =  self.window!.frame.origin
        newOrigin.x += xSpan
        newOrigin.y += ySpan
        startPoint = NSMakePoint(0, 0)
        self.window!.setFrameOrigin(newOrigin)
    }
}
