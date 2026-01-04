from flask import Blueprint, jsonify, request
from models import db, Transaction
from flask_jwt_extended import jwt_required, get_jwt_identity

stats_bp = Blueprint("stats", __name__)

@stats_bp.route("/summary", methods=['GET'])
# @jwt_required
def get_summary():
    # user_id = get_jwt_identity()
    user_id = request.args.get("user_id")
    if not user_id:
        return jsonify({"error":"user_id is required"}),400
    
    transactions = Transaction.query.filter_by(user_id=user_id).all()

    total_income = db.session.query(db.func.sum(Transaction.amount)).filter_by(user_id = user_id, transaction_type ='income').scalar() or 0
    total_expense = db.session.query(db.func.sum(Transaction.amount)).filter_by(user_id=user_id, transaction_type="expense").scalar() or 0

    return jsonify(
        {
            "total income": total_income,
            "total_expense": total_expense
        }
    )