from flask import Flask
from models import db
from dotenv import load_dotenv
import os
import enum

load_dotenv()
database_url = os.getenv("DATABASE_URL")

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
db.init_app(app)

@app.route("/")
def home():
    return "INITIAL COMMIT"



if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")


print("Success")