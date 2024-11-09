import mysql.connector
import os
import chromadb
from llama_index.embeddings.gemini import GeminiEmbedding
from llama_index.core import Settings, VectorStoreIndex, SimpleDirectoryReader, StorageContext
from llama_index.llms.gemini import Gemini
from llama_index.vector_stores.chroma import ChromaVectorStore
from llama_index.core.retrievers import VectorIndexRetriever
from llama_index.core.node_parser import CodeSplitter
from llama_index.core import PromptTemplate
from flask_bcrypt import Bcrypt
from flask import Flask, render_template, request, redirect, url_for
from threading import Thread

os.environ["GOOGLE_API_KEY"] = ""
os.environ["admin_passwd"] = "grandprix_hub_admin_password"
os.environ["user_passwd"] = "grandprix_hub_user_password"
os.environ["maintainer_passwd"] = "grandprix_hub_maintainer_password"
os.environ["secret_key"] = "secret_key"

app = Flask(__name__)

app.jinja_env.variable_start_string = '[['
app.jinja_env.variable_end_string = ']]'

app.config['SECRET_KEY'] = os.environ["secret_key"]

bcrypt = Bcrypt(app)

admin_db = mysql.connector.connect(host='localhost', user='grandprix_hub_admin', passwd=os.environ["admin_passwd"], database = 'grandprix_hub')
admin_cursor = admin_db.cursor()

maintainer_db = mysql.connector.connect(host='localhost', user='grandprix_hub_maintainer', passwd=os.environ["maintainer_passwd"], database = 'grandprix_hub')
maintainer_cursor = maintainer_db.cursor()

user_db = mysql.connector.connect(host='localhost', user='grandprix_hub_user', passwd=os.environ["user_passwd"], database = 'grandprix_hub')
user_cursor = user_db.cursor()

@app.route('/login_signup')
def login_signup():
    return render_template('login_signup.html')


@app.route('/user_sign_in', methods = ['POST'])
def user_sign_in():
    username = request.form['username']
    password = request.form['password']
    encrypted_password = bcrypt.generate_password_hash(password).decode('utf-8')
    admin_cursor.execute("select count(*) from user_credentials where username = '{}' and password = '{}'".format(username, encrypted_password))
    user_exists = admin_cursor.fetchall()[0][0]
    if user_exists == 1:
        return redirect(url_for('user_main'))
    else:
        return redirect(url_for('login_signup'))


@app.route('/user_sign_up', methods = ['POST'])
def user_sign_up():
    username = request.form['username']
    password = request.form['password']
    encrypted_password = bcrypt.generate_password_hash(password).decode('utf-8')
    admin_cursor.execute("insert into user_credentials ( '{}' , '{}' )".format(username, encrypted_password))    #trigger to check if user exists
    user_exists = admin_cursor.fetchall()[0][0]
    if user_exists == 1:
        admin_cursor.rollback()
        return redirect(url_for('login_signup'))
    else:
        admin_cursor.commit()
        return redirect(url_for('user_main'))


@app.route('/maintainer_sign_in', methods = ['POST'])
def maintainer_sign_in():
    username = request.form['username']
    password = request.form['password']
    encrypted_password = bcrypt.generate_password_hash(password).decode('utf-8')
    admin_cursor.execute("select count(*) from maintainer_credentials where username = '{}' and password = '{}'".format(username, encrypted_password))
    user_exists = admin_cursor.fetchall()[0][0]
    if user_exists == 1:
        return redirect(url_for('maintainer_main'))
    else:
        return redirect(url_for('login_signup'))


@app.route('/user_main')
def user_main():
    return render_template('user_main.html')

@app.route('/maintainer_main')
def maintainer_main():
    return render_template('maintainer_main.html')


@app.route('/select_table')
def select_table(table_name):
    maintainer_cursor.execute("show columns from {}".format(table_name))
    columns = maintainer_cursor.fetchall()
    column_names = [column[0] for column in columns]
    return render_template('insert.html', column_names = column_names, table_name = table_name)


@app.route('/insert', methods = ['POST'])
def insert():
    table_name = request.form['table_name']
    column_names = request.form['column_names']
    values = request.form['values']
    maintainer_cursor.execute("insert into {} ({}) values ({})".format(table_name, column_names, values))
    valid_insert = maintainer_cursor.fetchall()[0][0]
    if valid_insert == 1:  
        maintainer_cursor.commit()
    else:
        maintainer_cursor.rollback()
