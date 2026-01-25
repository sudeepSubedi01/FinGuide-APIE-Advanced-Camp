from flask import Blueprint, jsonify, request
from models import db, Category
from flask_jwt_extended import jwt_required, get_jwt_identity

categories_bp = Blueprint("categories", __name__)

@categories_bp.route("/", methods=['GET'])
@categories_bp.route("", methods=['GET'])
@jwt_required()
def get_categories():
    # user_id = request.args.get('user_id')
    user_id = get_jwt_identity()

    if not user_id:
        return jsonify({'error':'user_id missing'}),400
    
    categories = Category.query.filter_by(user_id=user_id).all()

    result = []
    for c in categories:
        result.append({'category_id':c.category_id, 'name':c.name})
    # result.append({"user_id":user_id})
    return jsonify(result)

@categories_bp.route("/", methods=['POST'])
@categories_bp.route("", methods=['POST'])
@jwt_required()
def create_category():
    data = request.get_json()
    # user_id = data.get('user_id')
    user_id = get_jwt_identity()
    name = data.get('name')

    if not name:
        return jsonify({"error": "Name required"}), 400
    
    new_category = Category(user_id=user_id, name=name)

    db.session.add(new_category)
    db.session.commit()

    return jsonify({
        "message": "New category created",
        "user_id from jwt": user_id,
        "user_id": new_category.user_id,
        "name": new_category.name
    })

@categories_bp.route("/<int:category_id>", methods=['DELETE'])
@jwt_required()
def delete_category(category_id):
    user_id = get_jwt_identity()
    # user_id = request.args.get('user_id')

    if not user_id:
        return jsonify({"error": "user_id missing"}), 400

    category = Category.query.filter_by(
        category_id=category_id,
        user_id=user_id
    ).first()

    if not category:
        return jsonify({"error": "Category not found"}), 404

    db.session.delete(category)
    db.session.commit()

    return jsonify({
        "message": "Category deleted successfully",
        "category_id": category_id
    }), 200
