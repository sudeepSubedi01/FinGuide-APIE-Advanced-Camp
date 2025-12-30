from flask import Blueprint, jsonify, request
from werkzeug.security import generate_password_hash, check_password_hash
from models import db, User
import json

users_bp = Blueprint("users", __name__)

@users_bp.route("/register", methods=["POST"])
def user_register():
    data = request.get_json()

    name = data.get("name")
    email = data.get("email")
    password = data.get("password")
    currency_code = data.get("currency_code")

    if not all([name, email, password, currency_code]):
        return jsonify({'error: missing fields'}), 400
    
    password_hash = generate_password_hash(password)
    
    new_user = User(
        name = name,
        email = email,
        password_hash = password_hash,
        currency_code = currency_code
    )

    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email already registered'}), 409


    db.session.add(new_user)
    db.session.commit()

    return jsonify({
        'message': 'User registered successfully',
        "name": name,
        "email": email,
        "currency_code": currency_code,
        "password_hash": password_hash}), 201


@users_bp.route("/login", methods=["POST"])
def user_login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    if not all([email, password]):
        return jsonify({'error: missing fields'}), 400
    
    user = User.query.filter_by(email=email).first()

    if not user:
        return jsonify({'error: invalid email or password'}), 400
    
    if not check_password_hash(user.password_hash, password):
        return jsonify({'error': 'Invalid email or password'}), 401
    
    return jsonify({
        'message': 'Login successful',
        'user_id': user.user_id,
        'name': user.name,
        'email':user.email,
        'password_hash': user.password_hash,
        'password': password
    }), 200