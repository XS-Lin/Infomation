# Python #

## Oracle Database 操作 ##

        ~~~python
        connection = cx_Oracle.connect('system', 'ora', '192.168.56.102:1521/orcl01')
        cursor = connection.cursor()
        cursor.execute(sql)
        rows = cursor.fetchall()
        for row in rows:
            print(row[0])
        cursor.close()
        connection.close()
        ~~~
