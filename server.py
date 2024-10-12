import mysql.connector

mydb = mysql.connector.connect(host='localhost', user='root', passwd='', database = 'grandprix_hub')
mycursor = mydb.cursor()

#mycursor.execute("query '{}'  {}".format(<str_arg>, <int_arg>))

