from flask import Blueprint, jsonify, request
from werkzeug.security import generate_password_hash, check_password_hash
from models import db, User
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity

users_bp = Blueprint("users", __name__)

@users_bp.route("/register", methods=["POST"])
def user_register():
    print("Register API HIT")
    data = request.get_json()
    print(data)
    name = data.get("name")
    email = data.get("email")
    password = data.get("password")
    currency_code = data.get("currency_code")

    if not all([name, email, password, currency_code]):
        return jsonify({
            "success": False,
            "message": "Missing required fields"
        }), 400
    
    if User.query.filter_by(email=email).first():
        return jsonify({
            "success": False,
            "message": "Email already registered"
        }), 409
    
    password_hash = generate_password_hash(password)
    
    new_user = User(
        name = name,
        email = email,
        password_hash = password_hash,
        currency_code = currency_code
    )

    db.session.add(new_user)
    db.session.commit()

    return jsonify({
        "success": True,
        'message': 'User registered successfully',
        'user': {
            "name": new_user.name,
            "email": new_user.email,
            "currency_code": new_user.currency_code,
        }
    }),201

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
    
    access_token = create_access_token(identity=str(user.user_id))

    return jsonify({
        'message': 'Login successful',
        'access_token': access_token,
        'user':{
            'user_id': user.user_id,
            'name': user.name,
            'email':user.email,
            'currency_code':user.currency_code
        }        
    }), 200

@users_bp.route("/me", methods=["GET"])
@jwt_required()
def user_profle():
    user_id = get_jwt_identity()
    # user_id = request.args.get("user_id")
    if not user_id:
        return jsonify({'error':'user_id missing'}),400
    
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "user not found"}), 404
    
    return jsonify({
        "id": user.user_id,
        "name": user.name,
        "email": user.email,
        "currency_code":user.currency_code
    })