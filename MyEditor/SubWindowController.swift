//----  SubWindowController.swift ----
import Cocoa
//クラス定義
class SubWindowController: NSWindowController, NSWindowDelegate, NSTextFieldDelegate {
    @IBOutlet weak var textView: NSTextView!
    @IBOutlet weak var dateLabel: NSTextField!
    @IBOutlet weak var keyword: NSTextField!
    weak var delegate: SubWindowDelegate?  = nil
    var date = DateOfDiary()  //日付構造体
    let docProperty = DocumentProperty.sharedInstance //ドキュメント属性
    //検索
    var matchList = [NSRange]()
    var matchIndex = 0
    let color1:[NSAttributedStringKey:Any] = [.backgroundColor: NSColor.yellow]
    let color2:[NSAttributedStringKey:Any] = [.backgroundColor: NSColor.orange]
    //ゲッターの定義：xibファイル名を返す
    override var windowNibName: NSNib.Name?  {
        return NSNib.Name(rawValue: "DiaryWindow")
    }
    //イニシャライザ
    init(){
        super.init(window: nil)
        //通知オブザーバの登録
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.fontSizeUpdate),
                       name: Notification.Name(rawValue:"UAFontSize"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(self.fontNameUpdate),
                       name: Notification.Name(rawValue:"UAFontName"),
                       object: nil)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    deinit {
        //print("deinit")
    }
    //ウィンドウオブジェクトのロード時
    override func windowDidLoad() {
        super.windowDidLoad()
        //ウィンドウの背景色
        self.window?.titlebarAppearsTransparent = true
        self.window?.backgroundColor = NSColor.lightGray
        //ドキュメント属性
        textView.textContainerInset = NSMakeSize(1, 5) //上下左右の余白
        textView.isRichText = false
        textView.font = NSFont.init(name:self.docProperty.fontName,
                                    size:CGFloat(self.docProperty.fontSize))
        //日付のセットとファイル読み込み
        let dateStr = String(format:"%ld月%ld日(%@)", date.month, date.day, date.yobi)
        self.dateLabel.attributedStringValue = UATextAttribute.string(dateStr, size: 16)
        self.textView.textStorage?.append(CommonLib.readFromFile(date: date))
        self.resetFont() //フォントのリセット
        self.keyword.delegate = self
        self.window?.makeFirstResponder(self.textView)
        self.textView.setSelectedRange(NSMakeRange(0, 0)) //カーソルの移動
    }
    //NSWindowDelegate *********************************************************
    //ウィンドウを閉じるとき
    func windowWillClose(_ notification: Notification){
        CommonLib.writeToFile(textView.string, date: date)
        delegate?.windowDeactivate(self)
        delegate?.windowClose(self)
    }
    //ウィンドウがアクティブになった
    func windowDidBecomeKey(_ notification: Notification){
        delegate?.windowActivate(self)
    }
    //ウィンドウがアクティブでなくなった
    func windowDidResignKey(_ notification: Notification){
        delegate?.windowDeactivate(self)
    }
    //ウィンドウのサイズが変わった
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        var outSize = frameSize
        let minWidth: CGFloat = 300.0
        let minHeight: CGFloat = 150.0
        if frameSize.width < minWidth{
            outSize.width = minWidth
        }
        if frameSize.height < minHeight{
            outSize.height = minHeight
        }
        return outSize
    }
    //通知を受けて起動するメソッド **************************************************
    @objc func fontSizeUpdate(notification: NSNotification){
        self.resetFont()
    }
    @objc func fontNameUpdate(notification: NSNotification){
        self.resetFont()
    }
    //検索
    @IBAction func doSearch(_ sender: Any){
        if docProperty.regex == false{
            if self.matchList.count == 0{
                //検索の実行
                matchList = textView.string.nsRanges(of: keyword.stringValue, options: [], locale: nil)
                for match in matchList{
                    textView.textStorage?.setAttributes(color1, range: match)
                }
            }
            self.stepMatchList()
        }else{
            //正規表現
            if self.matchList.count == 0{
                //検索するパターン
                let pattern = keyword.stringValue
                do{
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    //検索実行
                    let results = regex.matches(in: self.textView.string,
                                                options: [],
                                                range: NSRange(0..<self.textView.string.count))
                    for result in results {
                        matchList.append(result.range)
                        textView.textStorage?.setAttributes(color1, range: result.range)
                    }
                }catch{
                    print(error.localizedDescription)
                    return
                }
            }
            self.stepMatchList()
        }
    }
    //検索クリア
    @IBAction func clearSearch(_ sender: Any){
        let attributes:[NSAttributedStringKey:Any] =  [.backgroundColor: NSColor.clear]
        for match in matchList{
            textView.textStorage?.setAttributes(attributes, range: match)
        }
        self.matchList = []
        self.matchIndex = 0
        self.keyword.stringValue = ""
        self.resetFont() //フォントのリセット
    }
    //NSTextField Deelegate ****************************************************
    func control(_ control: NSControl,
                 textView: NSTextView,
                 doCommandBy commandSelector: Selector) -> Bool{
        if commandSelector == #selector(NSResponder.insertNewline(_:)){
            self.doSearch(self)
            return true
        }
        return false
    }
    //内部関数 ******************************************************************
    //フォントの再設定
    private func resetFont(){
        self.textView.font = NSFont.init(name:self.docProperty.fontName,
                                         size:CGFloat(self.docProperty.fontSize))
        self.textView.font = NSFont.init(name:self.docProperty.fontName,
                                         size:CGFloat(self.docProperty.fontSize))
    }
    //カーソル移動に合わせ検索語の背景色を変える
    private func stepMatchList(){
        if self.matchList.count > 0{
            var range = matchList[self.matchIndex]
            self.textView.setSelectedRange(NSMakeRange(range.location, 0))
            self.textView.textStorage?.setAttributes(self.color2, range: range)
            //スクロール
            self.textView.scrollRangeToVisible(range)
            if self.matchIndex > 0 {
                range = matchList[self.matchIndex-1]
                self.textView.textStorage?.setAttributes(self.color1, range: range)
            }
            if self.matchList.count - 1 > self.matchIndex{
                self.matchIndex += 1
            }
            self.resetFont()
        }
    }
}
