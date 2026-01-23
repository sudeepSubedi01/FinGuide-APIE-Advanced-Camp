from flask import Blueprint, jsonify, request
from models import db, Transaction, TransactionType, Category
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime

transaction_bp = Blueprint("transactions", __name__)

@transaction_bp.route("/", methods=['GET'])
@transaction_bp.route("", methods=['GET'])
# @jwt_required()
def list_transactions():
    user_id = request.args.get('user_id')
    # user_id = get_jwt_identity()
    if not user_id:
        return jsonify({'error':'user_id missing'}),400
    
    transactions = Transaction.query.filter_by(user_id=user_id).all()

    result = []
    for t in transactions:
        result.append({
            # 'category_id': t.category_id, 
            'category': {
                'id': t.category.category_id,
                'name': t.category.name
            }if t.category else None,
            'amount': float(t.amount), 
            'transaction_type': t.transaction_type.value, 
            'transaction_date': t.transaction_date.strftime("%Y-%m-%d"),
            'description': t.description})
    return jsonify(result)

@transaction_bp.route("/", methods=['POST'])
@transaction_bp.route("", methods=['POST'])
# @jwt_required()
def create_transaction():
    data = request.get_json()

    user_id = data.get("user_id")
    # user_id = get_jwt_identity()
    amount = data.get('amount')
    transaction_type_enum = TransactionType(data.get('transaction_type'))
    category_id = data.get("category_id") if data.get("transaction_type") == "expense" else None
    transaction_date = datetime.strptime(data.get('transaction_date'), "%Y-%m-%d").date()
    description = data.get('description')

    new_transaction = Transaction(
        user_id=user_id, 
        category_id=category_id,
        amount=amount, 
        transaction_type=transaction_type_enum, 
        transaction_date=transaction_date, 
        description=description)

    db.session.add(new_transaction)
    db.session.commit()

    return jsonify({
        "message" : "Transaction inserted successfully",
        "user_id": user_id,
        "category_id":category_id,
        "amount":amount,
        "transaction_type":transaction_type_enum.value,
        "transaction_date": transaction_date,
        "description": description
    })
