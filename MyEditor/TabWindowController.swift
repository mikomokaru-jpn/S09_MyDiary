//---- TabWindowController.swift ----
import Cocoa

class TabWindowController: NSWindowController, NSWindowDelegate  {
    @IBOutlet weak var tabView: NSTabView!      //タブビュー
    weak var delegate: DisplayDocumentsDelegate? = nil
    //ゲッターの定義：xibファイル名を返す
    override var windowNibName: NSNib.Name?  {
        return NSNib.Name(rawValue: "DiaryTabWindow")
    }
    //イニシャライザ
    init(){
        super.init(window: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    deinit {
        print("deinit of abWindowContRoller")
    }
    //ウィンドのウロード時
    override func windowDidLoad() {
        super.windowDidLoad()
        //ウィンドウの背景色
        self.window?.titlebarAppearsTransparent = true
        self.window?.backgroundColor = NSColor.lightGray
        window?.delegate = self
    }
    //表示場所の変更
    func reset(frame: NSRect){
        let origin :CGPoint = frame.origin
        let size :CGSize = frame.size
        let x: CGFloat = origin.x + size.width
        let y: CGFloat = origin.y
            - ((self.window?.frame.size.height)! - size.height)
        let point = CGPoint(x: x, y: y)
        self.window?.setFrameOrigin(point)
    }
    //表示
    func addItem(date: DateOfDiary){
        //タブ数の上限
        if self.tabView.tabViewItems.count == 5{
            let alert = NSAlert()
            alert.messageText = "ドキュメントを開く"
            alert.informativeText = (String(format: "タブが %ld 個を超えています。",
                                            self.tabView.tabViewItems.count))
            alert.runModal()
            return
        }
        //重複チェック
        for item in self.tabView.tabViewItems{
            if item.identifier as? Int == date.ymd{
                //日付が重複
                self.tabView.selectTabViewItem(item)
                return
            }
        }
        var itemArray = [DiaryTabViewItem]()        //タブリスト
        //現状のタブを配列に出力
        for item in self.tabView.tabViewItems{
            itemArray.append(item as! DiaryTabViewItem)
        }
        //新しいタブの作成
        let size = NSMakeSize(tabView.contentRect.size.width, tabView.contentRect.size.height)
        let newItem = DiaryTabViewItem.init(contentSize: size, date: date)
        //リストに追加
        itemArray.append(newItem)
        //日付でソート
        itemArray.sort(by:{ lTeam, rTeam -> Bool in
            if lTeam.date.ymd < rTeam.date.ymd{
                return true
            }
            return false
        })
        //現状のタブを削除
        for item in self.tabView.tabViewItems{
            tabView.removeTabViewItem(item)
        }
        //タブの追加
        for item in itemArray{
            tabView.addTabViewItem(item)
        }
        //選択タブ
        tabView.selectTabViewItem(newItem)
    }
    //消去
    @IBAction func removeItem(_ sender: NSButton){
        //ファイルの書き出し
        guard let item: DiaryTabViewItem =
            tabView.selectedTabViewItem as? DiaryTabViewItem else{
            return
        }
        //ファイルの書き出し
        CommonLib.writeToFile(item.textView.string, date: item.date)
        //タブの削除
        tabView.removeTabViewItem(item)
        //最後のタブを削除したらウィンドウを閉じる
        if tabView.tabViewItems.count == 0{
            self.window?.close()
        }
    }
    //メニュー：ファイルの保存
    func writeForSelectedTab(){
        if let item = self.tabView.selectedTabViewItem as? DiaryTabViewItem {
            CommonLib.writeToFile(item.textView.string, date: item.date)

        }
    }
    //NSWindowDelegate *********************************************************
    //ウィンドウを閉じる
    func windowWillClose(_ notification: Notification) {
        for item in self.tabView.tabViewItems{
            if let dItem = item as? DiaryTabViewItem{
                //全タブのファイルの書き出し
                CommonLib.writeToFile(dItem.textView.string, date: dItem.date)
            }
        }
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
}
