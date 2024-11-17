import mysql.connector
import os
from flask_bcrypt import Bcrypt
from flask import Flask, render_template, request, redirect, url_for, jsonify
# from langchain_core.prompts import ChatPromptTemplate
# from langchain_community.utilities import SQLDatabase
# from langchain_core.output_parsers import StrOutputParser
# from langchain_core.runnables import RunnablePassthrough
# from langchain_google_genai import ChatGoogleGenerativeAI


# os.environ["GOOGLE_API_KEY"] = ""
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

user_db = mysql.connector.connect(host='localhost', user='grandprix_hub_user', passwd=os.environ["user_passwd"], database = 'grandprix_hub')
user_cursor = user_db.cursor()

# llm = ChatGoogleGenerativeAI(model="gemini-1.5-pro")

# template = """
# Based on the table schema below, write a SQL query that would answer the user's question:
# {schema}

# Question: {question}
# wasd:
# """

# prompt = ChatPromptTemplate.from_template(template)

# maintainer_db_uri = "mysql+mysqlconnector://grandprix_hub_maintainer:grandprix_hub_maintainer_password@localhost:3306/grandprix_hub"

# maintainer_sql_database = SQLDatabase.from_uri(maintainer_db_uri)

# user_db_uri = "mysql+mysqlconnector://grandprix_hub_user:grandprix_hub_user_password@localhost:3306/grandprix_hub"

# user_sql_database = SQLDatabase.from_uri(user_db_uri)

# def get_maintainer_schema(_):
#     maintainer_cursor.execute("""
#         SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE 
#         FROM INFORMATION_SCHEMA.COLUMNS 
#         WHERE TABLE_SCHEMA = 'grandprix_hub'
#         ORDER BY TABLE_NAME, ORDINAL_POSITION
#     """)
#     schema_info = maintainer_cursor.fetchall()
    
#     # Format schema info into a string
#     schema_text = []
#     current_table = None
#     for table, column, datatype in schema_info:
#         if table != current_table:
#             current_table = table
#             schema_text.append(f"\nTable: {table}")
#         schema_text.append(f"- {column} ({datatype})")
    
#     return "\n".join(schema_text)

# def get_user_schema(_):
#     user_cursor.execute("""
#         SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE 
#         FROM INFORMATION_SCHEMA.COLUMNS 
#         WHERE TABLE_SCHEMA = 'grandprix_hub'
#         ORDER BY TABLE_NAME, ORDINAL_POSITION
#     """)
#     schema_info = user_cursor.fetchall()
    
#     # Format schema info into a string
#     schema_text = []
#     current_table = None
#     for table, column, datatype in schema_info:
#         if table != current_table:
#             current_table = table
#             schema_text.append(f"\nTable: {table}")
#         schema_text.append(f"- {column} ({datatype})")
    
#     return "\n".join(schema_text)

# maintainer_sql_chain = (RunnablePassthrough.assign(schema = get_maintainer_schema)
#                         | prompt
#                         | llm.bind(stop = "\nwasd")
#                         | StrOutputParser()
# )

# user_sql_chain = (RunnablePassthrough.assign(schema = get_user_schema)
#                   | prompt
#                   | llm.bind(stop = "\nwasd")
#                   | StrOutputParser()
# )

# print(maintainer_sql_chain.invoke({"question": "change name of Nico Hulkenberg to George Russell in driver table"}))

# print(user_sql_chain.invoke({"question": "who won the 2023 Monza Grand Prix?"}))

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
    admin_cursor.execute("select password from user_credentials where username = '{}'".format(username))
    real_password_list = admin_cursor.fetchall()
    if not real_password_list:
        return redirect('/user_signin_signup')
    real_password = real_password_list[0][0]
    if bcrypt.check_password_hash(real_password, password):
        return redirect(url_for('user_main'))
    else:
        return redirect('/user_signin_signup')


@app.route('/user_sign_up', methods = ['POST'])
def user_sign_up():
    username = request.form['username']
    password = request.form['password']
    encrypted_password = bcrypt.generate_password_hash(password).decode('utf-8')
    try:
        admin_cursor.execute("insert into user_credentials values( '{}' , '{}');".format(username, encrypted_password))
        admin_db.commit()
        return redirect(url_for('user_main'))
    except:
        return redirect('/user_signin_signup')


@app.route('/maintainer_sign_in', methods = ['POST'])
def maintainer_sign_in():
    username = request.form['username']
    password = request.form['password']
    admin_cursor.execute("select password from maintainer_credentials where username = '{}'".format(username))
    real_password_list = admin_cursor.fetchall()
    if not real_password_list:
        return redirect('/maintainer_signin')
    real_password = real_password_list[0][0]
    if bcrypt.check_password_hash(real_password, password):
        return redirect(url_for('maintainer_main'))
    else:
        return redirect('/maintainer_signin')


@app.route('/user_main')
def user_main():
    user_cursor.execute("select year from season")
    available_years = user_cursor.fetchall()
    for i in range(len(available_years)):
        available_years[i] = int(available_years[i][0])
    selected_year = max(available_years)
    return render_template('user_main.html', available_years=available_years, selected_year=selected_year)

@app.route('/maintainer_main')
def maintainer_main():
    return render_template('maintainer_main.html')


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

def change_type(value):
    try:
        return int(value)
    except ValueError:
        try:
            return float(value)
        except ValueError:
            return value

@app.route('/insert', methods = ['POST'])
def insert():
    table_name = request.form['table_name']
    column_names_list = request.form['column_names'].split(',')
    values_list = request.form['values'].split(',')
    print(table_name, column_names_list, values_list)
    for i in range(len(column_names_list)):
        values_list[i] = change_type(values_list[i])
        if values_list[i] == '':
            values_list.pop(i)
            column_names_list.pop(i)
        else:
            if type(values_list[i]) == str:
                values_list[i] = "'{}'".format(values_list[i])
    column_names = ",".join(column_names_list)
    values = ",".join([str(value) for value in values_list])
    try:
        print("insert into {} ({}) values ({})".format(table_name, column_names, values))
        maintainer_cursor.execute("insert into {} ({}) values ({})".format(table_name, column_names, values))
        maintainer_db.commit()
        return {'success': True, 'message': 'Data inserted successfully!'}
    except:
        return {'success': False, 'message': 'An error occurred while inserting the record.'}


@app.route('/delete', methods = ['POST'])
def delete():
    table_name = request.form['table_name']
    column_names_list = request.form['column_names'].split(',')
    values_list = request.form['values'].split(',')
    condition = []
    for i in range(len(column_names_list)):
        values_list[i] = change_type(values_list[i])
        if values_list[i] == '':
            values_list.pop(i)
            column_names_list.pop(i)
        else:
            if type(values_list[i]) == str:
                values_list[i] = "'{}'".format(values_list[i])
            condition.append(column_names_list[i] + " = " + str(values_list[i]))
    condition = " and ".join(condition)
    try:
        maintainer_cursor.execute("delete from {} where {}".format(table_name, condition))
        maintainer_db.commit()
        return {'success': True, 'message': 'Data deleted successfully!'}
    except:
        return {'success': False, 'message': 'An error occurred while deleting the record.'}

@app.route('/update', methods = ['POST'])
def update():
    table_name = request.form['table_name']
    column_names_list = request.form['column_names'].split(',')
    values_list = request.form['values'].split(',')
    condition_column_names_list = request.form['condition_column_names'].split(',')
    condition_values_list = request.form['condition_values'].split(',')
    condition = []
    new_set = []
    for i in range(len(column_names_list)):
        values_list[i] = change_type(values_list[i])
        if values_list[i] == '':
            values_list.pop(i)
            column_names_list.pop(i)
        else:
            if type(values_list[i]) == str:
                values_list[i] = "'{}'".format(values_list[i])
            new_set.append(column_names_list[i] + " = " + str(values_list[i]))
    new_set = " , ".join(new_set)
    for i in range(len(condition_column_names_list)):
        condition_values_list[i] = change_type(condition_values_list[i])
        if condition_values_list[i] == '':
            condition_values_list.pop(i)
            condition_column_names_list.pop(i)
        else:
            if type(condition_values_list[i]) == str:
                condition_values_list[i] = "'{}'".format(condition_values_list[i])
            condition.append(condition_column_names_list[i] + " = " + str(condition_values_list[i]))
    condition = " and ".join(condition)
    try:
        maintainer_cursor.execute("update {} set {} where {}".format(table_name, new_set, condition))
        maintainer_db.commit()
        return {'success': True, 'message': 'Data updated successfully!'}
    except:
        return {'success': False, 'message': 'An error occurred while updating the record.'}


@app.route('/view_table/<table_name>')
def view_table(table_name):
    maintainer_cursor.execute(f"SHOW COLUMNS FROM {table_name}")
    column_names = [column[0] for column in maintainer_cursor.fetchall()]
    maintainer_cursor.execute(f"SELECT * FROM {table_name}")
    data = maintainer_cursor.fetchall()
    return render_template('view_table.html', table_name=table_name, column_names=column_names, data=data)

@app.route('/select_year/<table_name>')
def select_year(table_name):
    user_cursor.execute("select * from season")
    years = user_cursor.fetchall()
    for i in range(len(years)):
        years[i] = int(years[i][0])
    return render_template('select_year.html', table_name=table_name, years=years)

@app.route('/select_race', methods = ['POST'])
def select_race():
    data = request.json
    table_name = data.get('table_name')
    year = int(data.get('year'))
    if table_name == 'season_constructor_driver':
        user_cursor.execute(f"SHOW COLUMNS FROM {table_name}")
        column_names = list(set([column[0] for column in user_cursor.fetchall()]) - set(['season']))
        user_cursor.execute(f"SELECT {', '.join(column_names)} FROM {table_name} WHERE season = {year}")
        data = user_cursor.fetchall()
        return render_template('view1.html', table_name=table_name, column_names=column_names, data=data)
    else:
        user_cursor.execute(f"SELECT DISTINCT round FROM {table_name} WHERE season = {year}")
        rounds = [round[0] for round in user_cursor.fetchall()]
        return {'rounds': rounds, 'year': year, 'table_name': table_name}

@app.route('/view_race', methods = ['POST'])
def view_race():
    data = request.json  # Use request.json to access JSON data
    table_name = data.get('table_name')
    year = int(data.get('year'))
    round = int(data.get('round'))
    user_cursor.execute(f"SHOW COLUMNS FROM {table_name}")
    column_names = list(set([column[0] for column in user_cursor.fetchall()]) - set(['season', 'round']))
    user_cursor.execute(f"SELECT {', '.join(column_names)} FROM {table_name} WHERE season = {year} AND round = {round}")
    data = user_cursor.fetchall()
    return render_template('view1.html', table_name=table_name, column_names=column_names, data=data)


@app.route('/view/<table_name>')
def view(table_name):
    if table_name in ['country', 'circuit', 'constructor', 'driver']:
        user_cursor.execute(f"SHOW COLUMNS FROM {table_name}")
        column_names = [column[0] for column in user_cursor.fetchall()]
        user_cursor.execute(f"SELECT * FROM {table_name}")
        data = user_cursor.fetchall()
        return render_template('view.html', table_name=table_name, column_names=column_names, data=data)
    else:
        return redirect('/select_year/{}'.format(table_name))

@app.route('/championship_points/<year>')
def championship_points(year):
    year = int(year)
    user_cursor.callproc("get_driver_standings", [year])
    driver_standings = []
    for result in user_cursor.stored_results():
        driver_standings.extend(result.fetchall())
    user_cursor.callproc("get_constructor_standings", [year])
    constructor_standings = []
    for result in user_cursor.stored_results():
        constructor_standings.extend(result.fetchall())
    return {'driver_standings': driver_standings, 'constructor_standings': constructor_standings}

@app.route('/get_driver_names')
def get_driver_names():
    user_cursor.execute("select driver_id from driver")
    drivers = [column[0] for column in user_cursor.fetchall()]
    return render_template("achievements.html", drivers=drivers)

@app.route('/career_achievements/<driver_id>')
def get_wins(driver_id):
    user_cursor.execute(f"select get_race_wins('{driver_id}') from driver")
    race_wins = user_cursor.fetchall()[0][0]
    user_cursor.execute(f"select get_pole_positions('{driver_id}') from driver")
    pole_positions = user_cursor.fetchall()[0][0]
    user_cursor.execute(f"select get_podiums('{driver_id}') from driver")
    podiums = user_cursor.fetchall()[0][0]
    user_cursor.execute(f"select get_sprint_wins('{driver_id}') from driver")
    sprint_wins = user_cursor.fetchall()[0][0]
    return {'race_wins': race_wins, 'pole_positions': pole_positions, 'podiums': podiums, 'sprint_wins': sprint_wins}

@app.route('/get_driver')
def get_driver():
    user_cursor.execute("select driver_id from driver")
    drivers = [column[0] for column in user_cursor.fetchall()]
    user_cursor.execute("select * from season")
    years = user_cursor.fetchall()
    for i in range(len(years)):
        years[i] = int(years[i][0])
    return render_template("stats.html", drivers=drivers, years=years)

@app.route('/select_driver_and_race_stats/<driver_id>/<year>')
def select_driver_and_race_stats(driver_id, year):
    year = int(year)
    user_cursor.execute(f"SELECT DISTINCT round FROM race WHERE season = {year}")
    rounds = [round[0] for round in user_cursor.fetchall()]
    return {'rounds': rounds, 'year': year, 'driver_id': driver_id}

@app.route('/get_driver_and_race_stats/<driver_id>/<year>/<round>')
def get_driver_and_race_stats(driver_id, year, round):
    year = int(year)
    round = int(round)
    print(driver_id, year, round)
    user_cursor.callproc("get_driver_and_race_stats",[driver_id, year, round])
    data = []
    for result in user_cursor.stored_results():
        data.extend(result.fetchall())
    user_db.commit()
    print(data)
    return {'data': data}

if __name__ == '__main__':
    app.run(debug=True)
    
