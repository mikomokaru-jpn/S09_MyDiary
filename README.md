## macOS S09_MyDiary

### Diary, open from calendar

<img src="http://mikomokaru.sakura.ne.jp/data/B25/diary1.png" alt="diary1" title="diary1" width="400">




Confirmed operation: MacOS 10.14.6 / Xcode 11.3.1


### Text Editor
Text editor of this application is implemented from NSTextView class. The text format is plain text only. NSTextView class class seems to be adopted by TextEdit.app. As adopted this class, I think In theory We can do all operations that we can do with TextEdit.app.

#### Line spacing problem (although it is a little detailed)
Depending on the type of font, upper and lower display positions of full-width characters and half-width characters are different, which makes it look quite strange.

<img src="http://mikomokaru.sakura.ne.jp/data/B25/diary2.png" alt="diary2" title="diary2" width="250">

This is exactly the same for TextEdit.app.If you want to adjust it, you could set the line spacing to a negative value by Ruler Setting.

[Menu → Format → Text → Interval]

However, in this app does not incorporate Ruler Setting, because when setting value is changed, an error of unknown cause occurs.


<img src="http://mikomokaru.sakura.ne.jp/data/B25/diary3.png" alt="diary3" title="diary3" width="300">


### Display diary
To open a diary for a particular day, double-click the date on the calendar, select the date and press Open Button, or select Open Item from the menu, and a subwindow will open to display the editor that recorded the diary. Up to 10 subwindows can be opened at the same time.

The position and size of the main window are recorded in User Defaults and will be inherited after the application is closed. So when you open a new window, it will be the same position and size as the last closed window.

<img src="http://mikomokaru.sakura.ne.jp/data/B25/diary4.png" alt="diary4" title="diary4" width="500">

### Change font and size
Select a font name or size of the text from the menu and change it . This process is implemented using NSNotification function. The selected font name and size values are held in a singleton object and referenced by some objects that need them. The values are saved in Plist and are inherited even after the application is closed.

<img src="http://mikomokaru.sakura.ne.jp/data/B25/diary5.png" alt="diary5" title="diary5" width="500">

### Text search
Search by a keyword and highlight the word that match your search. If there are multiple matching words, press Enter key to skip the cursor position to the next word. You can also search with regular expression.

<img src="http://mikomokaru.sakura.ne.jp/data/B25/diary6.png" alt="diary6" title="diary6" width="300">

### Save text
The text of the diary is saved in a file by date.

### Class Structure Diagram

<img src="http://mikomokaru.sakura.ne.jp/data/B25/diary7.png" alt="diary7" title="diary7" width="600">
