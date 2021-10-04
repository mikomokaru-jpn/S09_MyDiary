//---- AppDelegate.swift ----
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, DisplayDocumentsDelegate,
                   NSWindowDelegate {
    let uaView = UAView.init(point: NSMakePoint(0, 0)) //カレンダービュー
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var menuNames: NSMenu!
    @IBOutlet weak var menuSizes: NSMenu!
    @IBOutlet weak var menuRegex: NSMenu!
    var docProperty = DocumentProperty.sharedInstance
    var plistURL = URL.init(fileURLWithPath: NSHomeDirectory() + "/MyDiary/document.plist")
    //アプリケーション開始時
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //カレンダー
        window.contentView?.addSubview(uaView)
        window.titlebarAppearsTransparent = true
        window.backgroundColor = NSColor.lightGray
        //ドキュメント属性の設定
        self.loadPlist()
        //メニュー選択値のセット
        self.setMenuNamesState(self.docProperty.fontName)
        self.setMenuSizesState(self.docProperty.fontSize)
        self.setMenuRegexState(self.docProperty.regex)
        //DisplayModeChangeDelegate
        uaView.winArray.delegate = self
        window.delegate = self
        /*
        for aFont in NSFontManager.shared.availableFonts{
            print(aFont);
        }
        */
    }
    //アプリケーション終了時
    func applicationWillTerminate(_ aNotification: Notification) {
        //plistに保存
        self.savePlist()
    }
    //ウィンドウの再表示
    func applicationShouldHandleReopen(_ sender: NSApplication,
                                       hasVisibleWindows flag: Bool) -> Bool{
        if !flag{
            window.makeKeyAndOrderFront(self)
        }
        return true
    }
    //ウィンドウを閉じる
    func windowWillClose(_ notification: Notification) {
        uaView.winArray.closeAllWindows()
    }
    //**************************************************************************
    //メニューの実行：ドキュメントの保存
    @IBAction func saveDocument(_ sender: Any?){
        uaView.winArray.writeForActiveWindow()
    }
    //メニューの実行：フォント名
    @IBAction func setFontName(_ sender: NSMenuItem){
        self.docProperty.fontName = sender.identifier?.rawValue ?? "Osaka"
        self.setMenuNamesState(docProperty.fontName)
        //plistに保存
        self.savePlist()
        //通知
        let nc = NotificationCenter.default
        let notification = Notification.init(name: Notification.Name(rawValue: "UAFontName"))
        nc.post(notification)
    }
    //メニューの実行：フォントサイズ
    @IBAction func setFontSize(_ sender: NSMenuItem){
        self.docProperty.fontSize = sender.tag
        self.setMenuSizesState(docProperty.fontSize)
        //plistに保存
        self.savePlist()
        //通知
        let nc = NotificationCenter.default
        let notification = Notification.init(name: Notification.Name(rawValue: "UAFontSize"))
        nc.post(notification)
    }
    //メニューの実行：検索方法
    @IBAction func setRegex(_ sender: NSMenuItem){
        if sender.tag == 0{
            docProperty.regex = false
        }else{
            docProperty.regex = true
        }
        self.setMenuRegexState(docProperty.regex)
        //plistに保存
        self.savePlist()
    }
    //メニューの実行：ドキュメントを開く
    @IBAction func openDocument(_ sender: NSMenuItem){
        uaView.subWindowOpen()
    }
    //DisplayDocumentsDelegate *************************************************
    func redisplayCalendar(){
        //カレンダーの再表示：日記記入済み印の更新
        uaView.putDateToIemView()
    }
    //内部関数 *******************************************************************
    //plistに保存
    private func savePlist(){
        /* どちらでも構わない
        let manager = FileManager.default
        let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentDir.appendingPathComponent("document.plist")
        */
        let docDictionary: NSDictionary = ["fontSize" : self.docProperty.fontSize,
                                           "fontName" : self.docProperty.fontName,
                                           "regex" : self.docProperty.regex]
        docDictionary.write(to: plistURL, atomically: true)
    }
    //plistを読み込む
    private func loadPlist(){
        //NSDictionaryオブジェクトのアンラップ
        if let docDictionary = NSDictionary.init(contentsOf: plistURL){
            //fontName要素のアンラップとキャストを一括して
            //フォント
            if let fontName = docDictionary["fontName"] as? String{
                self.docProperty.fontName = fontName
            }else{
                self.docProperty.fontName = "Osaka"
            }
            //サイズ
            if let fontSize = docDictionary["fontSize"] as? Int{
                self.docProperty.fontSize = fontSize
            }else{
                self.docProperty.fontSize = 14
            }
            //検索・正規表現
            if let value = docDictionary["regex"] as? Bool{
                self.docProperty.regex = value
            }else{
                self.docProperty.regex = false
            }

        }
    }
    //メニュー選択値のセット
    //フォント名
    private func setMenuNamesState(_ value: String){
        for item in menuNames.items{
            if value == (item.identifier?.rawValue ?? "?"){
                item.state = NSControl.StateValue.on
            }else{
                item.state = NSControl.StateValue.off
            }
        }
    }
    //フォントサイズ
    private func setMenuSizesState(_ value: Int){
        for item in menuSizes.items{
            if value == item.tag{
                item.state = NSControl.StateValue.on
            }else{
                item.state = NSControl.StateValue.off
            }
        }
    }
    //検索方法
    private func setMenuRegexState(_ value: Bool){
        if value == true{
            //正規表現あり
            menuRegex.items[0].state = NSControl.StateValue.off
            menuRegex.items[1].state = NSControl.StateValue.on
        }else{
            menuRegex.items[0].state = NSControl.StateValue.on
            menuRegex.items[1].state = NSControl.StateValue.off
        }
        
    }
}

