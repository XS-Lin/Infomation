# Python #

## Oracle Database 操作 ##

~~~python
connection = cx_Oracle.connect('system', 'ora', '192.168.56.102:1521orcl01')
cursor = connection.cursor()
cursor.execute(sql)
rows = cursor.fetchall()
for row in rows:
    print(row[0])
cursor.close()
connection.close()
~~~

## Pythonインストールパス取得 ##

~~~python
import os
import sys
os.path.dirname(sys.executable)
~~~

## MS Teams 操作 ##

[pyteams](https://pypi.org/project/pymsteams/)

1. メッセージ送信

~~~python
import pymsteams
myTeamsMessage.title("This is my message title")
myTeamsMessage.text("this is my text")
myTeamsMessage.addLinkButton("This is the button Text", "https://github.com/rveachkc/pymsteams/")
~~~

1. メッセージカード

~~~python
# create the section
myMessageSection = pymsteams.cardsection()

# Section Title
myMessageSection.title("Section title")

# Activity Elements
myMessageSection.activityTitle("my activity title")
myMessageSection.activitySubtitle("my activity subtitle")
#myMessageSection.activityImage("http://i.imgur.com/c4jt321l.png")
myMessageSection.activityText("This is my activity Text")

# Facts are key value pairs displayed in a list.
myMessageSection.addFact("this", "is fine")
myMessageSection.addFact("this is", "also fine")

# Section Text
myMessageSection.text("This is my section text")

# Section Images
myMessageSection.addImage("http://i.imgur.com/c4jt321l.png", ititle="This Is Fine")

# Add your section to the connector card object before sending
myTeamsMessage.addSection(myMessageSection)
~~~