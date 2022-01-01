//------------------------------------------------------------------------------
//  UAView.swift
//------------------------------------------------------------------------------
import Cocoa
class UAView: NSView, UAViewDelegate{
    var font: NSFont?                                   //日付フォント
    var fontSmall: NSFont?                              //日付フォント（小）
    var itemViewList = [UAItemView]()                   //日付ビューリスト
    var calendar: UACalendar =  UACalendar.init()       //カレンダーオブジェクト
    var headerView: UATextView                          //年月見出し
    var selectedItemIndex:Int = 0                       //選択中の日付ビュー
    //**************************************************************************
    var winArray = SubWindowArray()
    let docProperty = DocumentProperty.sharedInstance //ドキュメント属性
    //**************************************************************************
    //ビューのY軸の反転
    override var isFlipped:Bool {
        get {
            return true
        }
    }
    //イニシャライザ
    init(point: NSPoint){
        //プロパティの初期化
        //見出し
        headerView = UATextView.init(frame:NSMakeRect(40,0,220,30));
        headerView.wantsLayer = true
        headerView.layer?.backgroundColor = NSColor.clear.cgColor
        //フォント
        font =  NSFont.init(name:"Arial", size:24)
        fontSmall =  NSFont.init(name:"Arial", size:16)
        //super classオブジェクトの作成
        let myFrame = NSMakeRect(point.x, point.y, 300, 330)
        super.init(frame: myFrame)
         //当月カレンダーの作成（現在日を元に）
        calendar = UACalendar()
        //サブビュー（コントロール、日付ビュー）の作成と配置
        self.arrangeControlViews()
        //日付ビューに日付をセットする
        self.putDateToIemView()
        selectedItemIndex = calendar.currentDateIndex
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        window?.makeFirstResponder(itemViewList[selectedItemIndex])
    }
    //カレンダービューの編集
    func arrangeControlViews(){
        //super classのプロパティの参照はここから
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.lightGray.cgColor
        
        self.addSubview(headerView)
        
        //ドキュメントを開くボタン
        let documentOpen = NSButton.init(frame: NSMakeRect(45, 35, 30, 30))
        documentOpen.image = NSImage.init(named:NSImage.Name.bookmarksTemplate)
        documentOpen.bezelStyle = .texturedSquare
        documentOpen.target = self
        documentOpen.action = #selector(self.subWindowOpen)
        self.addSubview(documentOpen)
        //前月へボタン
        let clickPreButton = NSButton.init(frame: NSMakeRect(9,35,30,30))
        clickPreButton.bezelStyle = .texturedSquare
        clickPreButton.target = self
        clickPreButton.action = #selector(self.clickPreButton)
        clickPreButton.image =  NSImage.init(named:NSImage.Name.leftFacingTriangleTemplate)
        self.addSubview(clickPreButton)
        //翌月へボタン
        let clickNextButton = NSButton.init(frame: NSMakeRect(261,35,30,30))
        clickNextButton.bezelStyle = .texturedSquare
        clickNextButton.target = self
        clickNextButton.action = #selector(self.clickNextButton)
        clickNextButton.image =  NSImage.init(named:NSImage.Name.rightFacingTriangleTemplate)
        self.addSubview(clickNextButton)
        //曜日見出し
        
        let youbis = ["月","火","水","木","金","土","日"]
        for i in 0 ..< youbis.count {
            let youbiView = UATextView.init(frame:NSMakeRect(CGFloat(10+(40*i)),68,40,22))
            youbiView.wantsLayer = true
            youbiView.layer?.backgroundColor = NSColor.clear.cgColor
            youbiView.text =
                NSMutableAttributedString.init(string: youbis[i],
                                               attributes: [NSAttributedStringKey.font:fontSmall!])
            self.addSubview(youbiView)
        }
        
        //日付ビューのグリッド(6行×7列)を作成してカレンダービューへ追加する
        let CELL_WIDTH: CGFloat = 40.0
        let CELL_HEIGHT: CGFloat = 40.0
        var index = 0
        for i in 1 ... 6{
            for j in 1 ... 7{
                let x = CGFloat((j-1) % 7) * CELL_WIDTH + 10
                let y = 90 + (CGFloat(i-1) * CELL_HEIGHT)
                let rect = NSMakeRect(x, y, CELL_WIDTH, CELL_HEIGHT)
                let item = UAItemView.init(frame: rect)
                item.uaViewDelegate = self
                itemViewList.append(item)
                self.addSubview(item)
                index += 1
            }
        }
    }
    //日付ビューに日付をセットする
    //イニシャライザ、または前月/翌月の移動処理から呼ばれる
    func putDateToIemView(){
        let currentDaycolor:CGColor =
            NSColor.init(red: 200/255, green: 220/255, blue: 240/255, alpha: 1).cgColor
        let wareki:Array = calendar.yearOfWareki
        let text = String(format: "%ld年%ld月(%@%@)",
                          calendar.year, calendar.month, wareki[0], wareki[1])
        let headerFont: NSFont =  NSFont.init(name:"YuGothic", size:22) ??  NSFont.systemFont(ofSize:22)
        headerView.text = NSMutableAttributedString.init(string: text,
                                                  attributes: [NSAttributedStringKey.font:headerFont])
        headerView.needsDisplay = true
        //ドキュメントファイル名の取得
        let start = calendar.yearMonthday(index: 0)
        let end = calendar.yearMonthday(index: calendar.daysOfCalender - 1)
        let fileNames = CommonLib.fileNamesWithContents(start, end)
        //日付のセット
        for i in 0 ..< itemViewList.count{
            if i < calendar.daysOfCalender{
                itemViewList[i].index = i
                itemViewList[i].aString = self.attributedDay(index: i)
                if i == calendar.currentDateIndex{
                    itemViewList[i].myBackgroundColor = currentDaycolor
                }else{
                    itemViewList[i].myBackgroundColor = NSColor.white.cgColor
                }
                //日記ドキュメント有無の印
                itemViewList[i].hasContents = false
                for ymd in fileNames{
                    if calendar.yearMonthday(index: i) == ymd{
                        itemViewList[i].hasContents = true
                        break
                    }
                }
            }else{
                itemViewList[i].index = -1 //hidden
            }
            itemViewList[i].needsDisplay = true
        }
    }
    //文字列・日の作成
    private func attributedDay(index: Int)->NSAttributedString{
        let attributes: [NSAttributedStringKey : Any]
        let textFont: NSFont?
        if calendar.thisMonthFlag(index: index){
            textFont = self.font
        }else{
            textFont = self.fontSmall
        }
        if calendar.weekday(index: index) == 1 ||
           calendar.holidayFlag(index: index){
            //日曜日・休日
            attributes = [.font : textFont!,
                          .foregroundColor:NSColor.red]
        }else if calendar.weekday(index: index) == 7{
            //土曜日
            attributes = [.font : textFont!,
                          .foregroundColor:NSColor.blue]
        }else{
            //平日
            attributes = [.font : textFont!,
                          .foregroundColor:NSColor.black]
        }
        //属性付き文字列の作成
        let day = String(format:"%ld", calendar.day(index: index))
        let atrDay = NSAttributedString.init(string: day, attributes: attributes)
        return atrDay
    }
    //前月へボタン
    @objc func clickPreButton(){
        calendar.createCalender(addMonth: -1)
        self.putDateToIemView()
        selectedItemIndex = calendar.lastDayIndex
        self.needsDisplay = true
    }
    //翌月へボタン
    @objc func clickNextButton(){
        calendar.createCalender(addMonth: 1)
        self.putDateToIemView()
        selectedItemIndex = calendar.firstDayIndex
        self.needsDisplay = true
    }
    //デリゲートメソッド：日付ビューの移動
    func moveDate(index: Int, to:MoveTYpe){
        switch to {
        case .LEFT:
            if selectedItemIndex > 0{
                //前日へ
                selectedItemIndex -= 1
            }else{
                var addition = 0
                //前月へ
                //カーソルの位置
                if !calendar.thisMonthFlag(index: selectedItemIndex){
                    addition = 7;
                }
                calendar.createCalender(addMonth: -1)   //前月のカレンダーの作成
                self.putDateToIemView()                 //日付ビューに日付をセットする
                selectedItemIndex = calendar.daysOfCalender - 1 - addition
            }
        case .RIGHT:
            if selectedItemIndex < calendar.daysOfCalender - 1 {
                //翌日へ
                selectedItemIndex += 1
            }else{
                var addition = 0
                //翌月へ
                //カーソルの位置
                if !calendar.thisMonthFlag(index: selectedItemIndex){
                    addition = 7;
                }
                calendar.createCalender(addMonth: 1)   //翌月のカレンダーの作成
                self.putDateToIemView()                //日付ビューに日付をセットする
                selectedItemIndex = addition
            }
        case .DOWN:
            if selectedItemIndex < calendar.daysOfCalender - 7{
                selectedItemIndex += 7
            }
        case .UP:
            if selectedItemIndex >= 7{
                selectedItemIndex -= 7
            }
        default:
            selectedItemIndex = index
        }
        self.needsDisplay = true
    }
    //**************************************************************************
    //ドキュメントを開く
    @objc func subWindowOpen(){
        //日付の取得
        let date = DateOfDiary(calendar.year(index: self.selectedItemIndex),
                               calendar.month(index: self.selectedItemIndex),
                               calendar.day(index: self.selectedItemIndex),
                               calendar.yobi(index: self.selectedItemIndex))
        //表示モードの判定
        winArray.openWindow(date:date, frame: window!.frame)
    }
}

