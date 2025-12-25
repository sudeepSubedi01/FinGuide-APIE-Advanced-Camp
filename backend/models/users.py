from . import db

class User(db.Model):
    __tablename__ = "users"
    user_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(150), nullable=False, unique=True)
    password_hash = db.Column(db.Text, nullable=False)
    currency_code = db.Column(db.String(3), nullable = False)
    created_at = db.Column(db.DateTime(timezone=True), server_default = db.func.now())