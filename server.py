import mysql.connector
import os
from llama_index import GPTSQLStructStoreIndex, SQLDatabase
from flask_bcrypt import Bcrypt
from flask import Flask, render_template, request, redirect, url_for, jsonify
from threading import Thread

os.environ["GOOGLE_API_KEY"] = ""
os.environ["admin_passwd"] = "grandprix_hub_admin_password"
os.environ["user_passwd"] = "grandprix_hub_user_password"
os.environ["maintainer_passwd"] = "grandprix_hub_maintainer_password"
os.environ["secret_key"] = "secret_key"

app = Flask(__name__)

app.jinja_env.variable_start_string = '{{'
app.jinja_env.variable_end_string = '}}'

app.config['SECRET_KEY'] = os.environ["secret_key"]

bcrypt = Bcrypt(app)

admin_db = mysql.connector.connect(host='localhost', user='grandprix_hub_admin', passwd=os.environ["admin_passwd"], database = 'grandprix_hub')
admin_cursor = admin_db.cursor()

maintainer_db = mysql.connector.connect(host='localhost', user='grandprix_hub_maintainer', passwd=os.environ["maintainer_passwd"], database = 'grandprix_hub')
maintainer_cursor = maintainer_db.cursor()

maintainer_sql_database = SQLDatabase(maintainer_db)

user_db = mysql.connector.connect(host='localhost', user='grandprix_hub_user', passwd=os.environ["user_passwd"], database = 'grandprix_hub')
user_cursor = user_db.cursor()

user_sql_database = SQLDatabase(user_db)

@app.route('/')
def login_signup():
    return render_template('login_signup.html')

@app.route('/user_signin_signup')
def user_signin_signup():
    return render_template('user_signin_signup.html')

@app.route('/maintainer_signin')
def maintainer_signin():
    return render_template('maintainer_signin.html')

@app.route('/user_sign_in', methods = ['POST'])
def user_sign_in():
    username = request.form['username']
    password = request.form['password']
    admin_cursor.execute("select password from maintainer_credentials where username = '{}'".format(username))
    real_password = admin_cursor.fetchall()[0][0]
    if bcrypt.check_password_hash(real_password, password):
        return redirect(url_for('user_main'))
    else:
        return redirect('/user_signin_signup')


@app.route('/user_sign_up', methods = ['POST'])
def user_sign_up():
    username = request.form['username']
    password = request.form['password']
    encrypted_password = bcrypt.generate_password_hash(password).decode('utf-8')
    admin_cursor.execute("insert into user_credentials values( '{}' , '{}' , 'user');".format(username, encrypted_password))    #trigger to check if user exists
    user_exists = admin_cursor.fetchall()[0][0]
    if user_exists == 1:
        admin_cursor.rollback()
        return redirect('/user_signin_signup')
    else:
        admin_cursor.commit()
        return redirect(url_for('user_main'))


@app.route('/maintainer_sign_in', methods = ['POST'])
def maintainer_sign_in():
    username = request.form['username']
    password = request.form['password']
    admin_cursor.execute("select password from maintainer_credentials where username = '{}'".format(username))
    real_password = admin_cursor.fetchall()[0][0]
    if bcrypt.check_password_hash(real_password, password):
        return redirect(url_for('maintainer_main'))
    else:
        return redirect('/maintainer_signin')


@app.route('/user_main')
def user_main():
    return render_template('user_main.html')

@app.route('/maintainer_main')
def maintainer_main():
    return render_template('maintainer_main.html')


@app.route('/manipulation')
def manipulation():
    return render_template('manipulation.html')

@app.route('/select_insert')
def select_insert():
    return render_template('select_table_insert.html')

@app.route('/select_update')
def select_update():
    return render_template('select_table_update.html')

@app.route('/select_delete')
def select_delete():
    return render_template('select_table_delete.html')

@app.route('/select_table_insert', methods = ['POST'])
def select_table_insert():
    table_name = request.form['table_name']
    maintainer_cursor.execute("show columns from {}".format(table_name))
    columns = maintainer_cursor.fetchall()
    column_names = [column[0] for column in columns]
    print(column_names)
    return render_template('insert.html', column_names=column_names, table_name=table_name)

@app.route('/select_table_update' , methods = ['POST'])
def select_table_update():
    table_name = request.form['table_name']
    maintainer_cursor.execute("show columns from {}".format(table_name))
    columns = maintainer_cursor.fetchall()
    column_names = [column[0] for column in columns]
    print(column_names)
    return render_template('update.html', column_names=column_names, table_name=table_name)

@app.route('/select_table_delete', methods = ['POST'])
def select_table_delete():
    table_name = request.form['table_name']
    maintainer_cursor.execute("show columns from {}".format(table_name))
    columns = maintainer_cursor.fetchall()
    column_names = [column[0] for column in columns]
    print(column_names)
    return render_template('delete.html', column_names=column_names, table_name=table_name)


@app.route('/insert', methods = ['POST'])
def insert():
    table_name = request.form['table_name']
    column_names = request.form['column_names'].split(',')
    values = request.form['values'].split(',')
    for i in range(len(column_names)):
        if values[i] == '':
            values.pop(i)
            column_names.pop(i)
    maintainer_cursor.execute("insert into {} ({}) values ({})".format(table_name, column_names, values))   #trigger to check if insert is valid
    valid_insert = maintainer_cursor.fetchall()[0][0]
    if valid_insert == 1:  
        maintainer_cursor.commit()
    else:
        maintainer_cursor.rollback()
    return render_template('insert.html', column_names = column_names, table_name = table_name)


@app.route('/delete')
def delete(table_name, column_names, values):
    condition = []
    for i in range(len(column_names)):
        if type(values[i]) == str:
            values[i] = "'{}'".format(values[i])
        condition.append(column_names[i] + " = " + values[i])
    condition = " and ".join(condition)
    maintainer_cursor.execute("delete from {} where {}".format(table_name, condition))
    valid_delete = maintainer_cursor.fetchall()[0][0]
    if valid_delete == 1:
        maintainer_cursor.commit()
        message = "Record deleted successfully"
    else:
        maintainer_cursor.rollback()
        message = "Record not found"
    return render_template('delete.html', column_names = column_names, table_name = table_name, message = message)

@app.route('/update')
def update(table_name, column_names, values,condition_column_names, condition_values):
    condition = []
    new_set = []
    for i in range(len(condition_column_names)):
        if type(condition_values[i]) == str:
            condition_values[i] = "'{}'".format(condition_values[i])
        condition.append(condition_column_names[i] + " = " + condition_values[i])
    condition = " and ".join(condition)
    for i in range(len(column_names)):
        if type(values[i]) == str:
            values[i] = "'{}'".format(values[i])
        new_set.append(column_names[i] + " = " + values[i])
    new_set = " , ".join(new_set)
    maintainer_cursor.execute("update {} set {} where {}".format(table_name, new_set, condition))
    valid_update = maintainer_cursor.fetchall()[0][0]
    if valid_update == 1:
        maintainer_cursor.commit()
        message = "Record updated successfully"
    else:
        maintainer_cursor.rollback()
        message = "Record not found"
    return render_template('update.html', column_names = column_names, table_name = table_name, message = message)

if __name__ == '__main__':
    app.run(debug=True)
    
