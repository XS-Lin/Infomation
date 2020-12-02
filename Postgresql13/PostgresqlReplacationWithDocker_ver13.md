# レプリケーションテスト(PostgreSQL13) #

## 環境設定 ##

### 1. シミュレーター作成 ###

~~~go
package main

import (
    "database/sql"
    "fmt"

    _ "github.com/lib/pq"
)

type Category struct {
    categoryId string
    name string
    last_update string
}

type EMPLOYEE struct {
    ID     string
    NUMBER string
}

func main() {
    db, err := sql.Open("postgres", "host=127.0.0.1 port=5555 user=root password=password dbname=testdb sslmode=disable")
    defer db.Close()

    if err != nil {
        fmt.Println(err)
    }

    // INSERT
    var empID string
    id := 3
    number := 4444
    err = db.QueryRow("INSERT INTO employee(emp_id, emp_number) VALUES($1,$2) RETURNING emp_id", id, number).Scan(&empID)

    if err != nil {
        fmt.Println(err)
    }

    fmt.Println(empID)

    // SELECT
    rows, err := db.Query("SELECT * FROM employee")

    if err != nil {
        fmt.Println(err)
    }

    var es []EMPLOYEE
    for rows.Next() {
        var e EMPLOYEE
        rows.Scan(&e.ID, &e.NUMBER)
        es = append(es, e)
    }
    fmt.Printf("%v", es)
}
~~~

### 2. テストDB作成 ###

[DVD rental database](https://www.postgresqltutorial.com/postgresql-sample-database/)

~~~bash
pg_restore -h localhost -p 5432 --clean --create -Ft -f /tmp/dvdrental.tar
~~~

## 操作 ##

### 1. マスタDB起動 ###

~~~bash

~~~

~~~txt
/var/lib/postgresql/data/postgresql.conf

/var/lib/postgresql/data/pg_hba.conf

~~~

### 2. シミュレーター起動 ###

~~~bash

~~~

### 3. マスタDBバックアップ ###

~~~bash

~~~

### 4. スタンバイDB作成及び起動 ###

~~~bash

~~~

### 5. レプリケーション起動 ###

~~~bash

~~~

### 6. スタンバイDBをマスタに切り替え ###

~~~bash

~~~

### 7. シミュレーター接続切り替え ###

~~~bash

~~~
