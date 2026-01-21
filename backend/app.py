from flask import Flask
from models import db
from dotenv import load_dotenv
import os
from sqlalchemy import text
from routes import users_bp, categories_bp, transaction_bp, stats_bp
from flask_jwt_extended import JWTManager
from flask_cors import CORS

load_dotenv()
database_url = os.getenv("DATABASE_URL")
jwt_secret_key = os.getenv("JWT_SECRET_KEY")

app = Flask(__name__)
# CORS(app, resources={r"/*": {"origins": "*"}})
CORS(app, supports_credentials=True)

app.config['SQLALCHEMY_DATABASE_URI'] = database_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

app.config["JWT_SECRET_KEY"] = jwt_secret_key
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = 3600

jwt = JWTManager(app)
    
db.init_app(app)
app.register_blueprint(users_bp, url_prefix='/users')
app.register_blueprint(categories_bp, url_prefix='/categories')
app.register_blueprint(transaction_bp, url_prefix='/transactions')
app.register_blueprint(stats_bp, url_prefix='/stats')

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