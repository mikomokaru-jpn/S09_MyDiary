## macOS S09_MyDiary

### Diary, open from calendar

<img src="http://mikomokaru.sakura.ne.jp/data/B25/diary1.png" alt="diary1" title="diary1" width="400">




Confirmed operation: MacOS 10.14.6 / Xcode 11.3.1


### Text Editor
Text editor of this application is implemented from NSTextView class. The text format is plain text only. NSTextView class class seems to be adopted by TextEdit.app. As adopted this class, I think In theory We can do all operations that we can do with TextEdit.app.

#### Line spacing problem (although it is a little detailed)
Depending on the type of font, upper and lower display positions of full-width characters and half-width characters are different, which makes it look quite strange.

### Display diary
To open a diary for a particular day, double-click the date on the calendar, select the date and press Open Button, or select Open Item from the menu, and a subwindow will open to display the editor that recorded the diary. Up to 10 subwindows can be opened at the same time.

The position and size of the main window are recorded in User Defaults and will be inherited after the application is closed. So when you open a new window, it will be the same position and size as the last closed window.

### Change font and size
Select a font name or size of the text from the menu and change it . This process is implemented using NSNotification function. The selected font name and size values are held in a singleton object and referenced by some objects that need them. The values are saved in Plist and are inherited even after the application is closed.

### Text search
Search by a keyword and highlight the word that match your search. If there are multiple matching words, press Enter key to skip the cursor position to the next word. You can also search with regular expression.

### Save text
The text of the diary is saved in a file by date.

### Class Structure Diagram

