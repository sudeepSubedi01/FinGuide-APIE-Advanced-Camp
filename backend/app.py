from flask import Flask
from models import db
from dotenv import load_dotenv
import os
from sqlalchemy import text
from routes import users_bp

load_dotenv()
database_url = os.getenv("DATABASE_URL")

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
db.init_app(app)
app.register_blueprint(users_bp)

@app.route("/")
def home():
    return "INITIAL COMMIT"

@app.route("/testconn")
def testconn():
    try:
        result = db.session.execute(text("SELECT 1"))
        print("Database connected successfully!")
        return "Database connected successfully!"
    except Exception as e:
        print("Database connection failed:", e)
        return f"Database connection failed: {e}"


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")


print("Success")