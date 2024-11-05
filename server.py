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

os.environ["GOOGLE_API_KEY"] = ""
os.environ["mysqlpasswd"] = ""

mydb = mysql.connector.connect(host='localhost', user='root', passwd=os.environ["mysqlpasswd"], database = 'grandprix_hub')
mycursor = mydb.cursor()

#mycursor.execute("query '{}'  {}".format(<str_arg>, <int_arg>))

