//---- DiaryTabviewItem.swift ----
import Cocoa
class DiaryTabViewItem: NSTabViewItem {
    let textView: NSTextView
    var date: DateOfDiary  //日付構造体
    let docProperty = DocumentProperty.sharedInstance //ドキュメント属性
    //イニシャライザ
    init(contentSize: CGSize, date: DateOfDiary) {
        //テキストビューの作成
        let rect = NSMakeRect(0, 0,contentSize.width, contentSize.height)
        textView = NSTextView.init(frame: rect)
        self.date = date
        //スーパークラスの初期化
        super.init(identifier: date.ymd)
        //ファイルの読み込み
        textView.textStorage?.append(CommonLib.readFromFile(date: date))
        //タブのラベル・月日
        self.label = String(format:"%d月%d日(%@)", date.month, date.day, date.yobi)
        //ドキュメント属性
        textView.textContainerInset = NSMakeSize(1, 5) //上下左右の余白
        textView.isRichText = false
        textView.font = NSFont.init(name:self.docProperty.fontName,
                                    size:CGFloat(self.docProperty.fontSize))
        //textView.autoresizingMask = [.height, .width]  //NG
        //print(textView.autoresizingMask)
        //テキストビューを自身のビューに追加する
        self.view?.addSubview(textView)        
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
    //通知を受けて起動するメソッド
    @objc func fontSizeUpdate(notification: NSNotification){
        textView.font = NSFont.init(name:self.docProperty.fontName,
                                    size:CGFloat(self.docProperty.fontSize))
    }
    @objc func fontNameUpdate(notification: NSNotification){
        textView.font = NSFont.init(name:self.docProperty.fontName,
                                    size:CGFloat(self.docProperty.fontSize))
    }
    
    
}
