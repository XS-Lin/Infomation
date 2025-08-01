# Python #

## IPython Magic ##

### bigquery ###

- [bigquery](https://github.com/googleapis/python-bigquery-magics/blob/main/bigquery_magics/bigquery.py)
  - [config](https://github.com/googleapis/python-bigquery-magics/blob/main/bigquery_magics/config.py)
    - [from_authorized_user_file](https://github.com/googleapis/google-auth-library-python/blob/main/google/oauth2/credentials.py#L500)
    - [default auth](https://github.com/pydata/pydata-google-auth/blob/main/pydata_google_auth/auth.py)

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

## プロキシ環境(windows) ##

~~~python
set HTTP_PROXY=<proxy>
set HTTPS_PROXY=<proxy>
py -m pip install -U pip
py -m pip install numpy
~~~

## Flask ##

~~~powershell
cd E:\tool\python\flask_test
# py -m venv venv
.\venv\Scripts\activate
pip install flask
# python.exe -m pip install --upgrade pip
# pip list
~~~

## pytest ##

[pytest](https://docs.pytest.org/en/stable/)

~~~bash
pip install pytest pytest-cov
~~~

## Manage Tools ##

### poetry ###

[poetry](https://python-poetry.org/)

### uv ###

[uv](https://docs.astral.sh/uv/guides/install-python/)

## Other Tools ##

- [numba](https://numba.pydata.org/)
  - 数学計算にスピードアップ
