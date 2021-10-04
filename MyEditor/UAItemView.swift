//------------------------------------------------------------------------------
//  UAItemView.swift
//------------------------------------------------------------------------------
import Cocoa
enum MoveTYpe: Int{
    case THIS = 0
    case RIGHT = 1
    case LEFT = 2
    case DOWN = 3
    case UP = 4
}

//プロトコル宣言
protocol UAViewDelegate  {
    func moveDate(index: Int, to:MoveTYpe)
    func subWindowOpen()
}
class UAItemView: NSView {
    var index: NSInteger = 0                                //インデックス
    var aString: NSAttributedString?                        //表示文字列
    var myBackgroundColor: CGColor?                         //背景色
    var myBorderWidth: CGFloat = 0.5                        //枠線の太さ
    var myBorderColor: CGColor = NSColor.lightGray.cgColor  //枠線の色
    var hasContents: Bool = false                           //日記有無
    var uaViewDelegate: UAViewDelegate?  = nil              //デリゲート
    //ビューの再表示
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if aString == nil{ return }
        if (index < 0){
            //月末一週間を非表示
            self.isHidden = true;
            return;
        }
        self.isHidden = false;
        let x = (self.frame.size.width/2)-(aString!.size().width/2)
        let y = (self.frame.size.height/2)-(aString!.size().height/2)+2
        aString?.draw(at: NSMakePoint(x, y)) //? is Optional Chaining
    
        self.layer?.borderWidth = myBorderWidth
        self.layer?.borderColor = myBorderColor
        self.layer?.backgroundColor = myBackgroundColor
        
        //入力済みの印
        if hasContents{
            let path = NSBezierPath.init()
            path.appendOval(in: NSMakeRect((self.frame.size.width/2-3),
                                           (self.frame.size.height/2-17),
                                            6, 6))
            //NSColor.init(red: 1.0, green: 0, blue: 0, alpha: 1.0).set()
            NSColor.lightGray.set()
            path.fill()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        myBorderWidth = 2.5
        myBorderColor = NSColor.blue.cgColor
        self.needsDisplay = true
        return true
    }
    override func resignFirstResponder() -> Bool {
        myBorderWidth = 0.5
        myBorderColor = NSColor.lightGray.cgColor
        self.needsDisplay = true
        return true
    }
    //日付をクリックする。
    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2{
            uaViewDelegate?.subWindowOpen()
        }else{
            uaViewDelegate?.moveDate(index: self.index, to: .THIS)
        }
    }
    //キーを押す
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:                   //left
            uaViewDelegate?.moveDate(index: self.index, to: .LEFT)
        case 124, 48:               //right, tab
            uaViewDelegate?.moveDate(index: self.index, to: .RIGHT)
        case 125:                   //down
            uaViewDelegate?.moveDate(index: self.index, to: .DOWN)
        case 126:                   //up
            uaViewDelegate?.moveDate(index: self.index, to: .UP)
        default:
            super.keyDown(with: event)
        }
    }
    /*
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool{
        return true
    }
    */
}
