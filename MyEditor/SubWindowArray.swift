//---- DocumentController.swift ----
import Cocoa
//クラス定義
class SubWindowArray: NSObject, SubWindowDelegate {
    let winCount = 10
    var winList: [SubWindowInfo] = []
    weak var delegate: DisplayDocumentsDelegate? = nil
    //イニシャライザ
    override init() {
        super.init()
        for i in 0..<winCount{
            winList.append(SubWindowInfo(object: nil, status: false, index: i, active: false))
        }
    }
    //ウィンドウを開く
    func openWindow(date: DateOfDiary, frame: NSRect){
        //すでに開いている場合は、それをアクティブにする。
        if self.isSameDate(date: date){
            return
        }
        //オープン可能なウィンドウを取得
        guard let subWindow: SubWindowInfo = self.availableWindow() else{
            print(String(format: "max %ld over", winCount))
            let alert = NSAlert()
            alert.messageText = "ドキュメントを開く"
            alert.informativeText = (String(format: "ウィンドウが %ld 個を超えています。", winCount))
            alert.alertStyle = .critical
            alert.runModal()
            return
        }
        //ウィンドウオブジェクトの取得（アンラップ）
        let object = subWindow.object!
        //プロパティの更新
        object.date = date
        object.delegate = self
        //ウィンドウを開く window load
        object.showWindow(self)
        //表示場所の変更：ユーザデフォルトの読み込み
        if let data = UserDefaults.standard.data(forKey: "WindowInfo")  {
            if let value = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                               as? NSValue {
                var rect: NSRect = NSZeroRect
                value?.getValue(&rect)
                object.window?.setFrame(rect, display: true)
                return
            }
        }
        let origin :CGPoint = frame.origin
        let size :CGSize = frame.size
        let x: CGFloat = origin.x + size.width + CGFloat(subWindow.index) * 15.0
        let y: CGFloat = origin.y - CGFloat(subWindow.index) * 20.0
                       - ((object.window?.frame.size.height)! - size.height)
        let point = CGPoint(x: x, y: y)
        object.window?.setFrameOrigin(point)
    }
    //全てのウィンドウを閉じる
    func closeAllWindows(){
        for i in 0..<winList.count{
            winList[i].object?.window?.close()
        }
    }
    //******** 内部メソッド ********
    //使用可能ウィンドウを渡す
    private func availableWindow()->SubWindowInfo?{
        for i in 0..<winList.count{
            if winList[i].status == false{
                winList[i].object = SubWindowController.init()
                winList[i].status = true
                return winList[i]
            }
        }
        return nil
    }
    //同じ日付のドキュメントが開いている場合は、それをアクティブにする。
    private func isSameDate(date: DateOfDiary) -> Bool{
        for i in 0..<winList.count{
            if winList[i].status == true && winList[i].object!.date == date{
                winList[i].object!.window?.makeKeyAndOrderFront(self)
                return true
            }
        }
        return false
    }
    //******** SubWindowDelegateメソッド ********
    //使用可能ウィンドウを戻す
    func windowClose(_ sender: SubWindowController) {
        for i in 0..<winList.count{
            if winList[i].object == sender{
                winList[i].object = nil
                winList[i].status = false
                delegate?.redisplayCalendar()
            }
        }
        //
        if let rect = sender.window?.frame {
            let value = NSValue.init(rect: rect)
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            UserDefaults.standard.set(data, forKey: "WindowInfo")
        }
    }
    //アクティブウィンドウの登録
    func windowActivate(_ sender: SubWindowController){
        for i in 0..<winList.count{
            if winList[i].status == true && winList[i].object == sender{
                winList[i].active = true
            }
        }
    }
    //アクティブウィンドウの登録解除
    func windowDeactivate(_ sender: SubWindowController){
        for i in 0..<winList.count{
            if winList[i].status == true && winList[i].object == sender{
                winList[i].active = false
            }
        }
    }
    //アクティブウィンドウのファイルを書き出する
    func writeForActiveWindow(){
        for i in 0..<winList.count{
            if winList[i].status == true && winList[i].active == true{
                if let text = winList[i].object?.textView.string{
                    CommonLib.writeToFile(text, date: (winList[i].object?.date)!)
                    delegate?.redisplayCalendar()
                }
            }
        }
    }
    
}
