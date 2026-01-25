from flask import Blueprint, jsonify, request
from models import db, Transaction, Category
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime, date, timedelta
from sqlalchemy import func, case

stats_bp = Blueprint("stats", __name__)

@stats_bp.route("/summary", methods=['GET'])
@jwt_required()
def get_summary():
    user_id = get_jwt_identity()
    # user_id = request.args.get("user_id")
    if not user_id:
        return jsonify({"error":"user_id is required"}),400
    
    total_income = db.session.query(db.func.sum(Transaction.amount)).filter_by(user_id = user_id, transaction_type ='income').scalar() or 0
    total_expense = db.session.query(db.func.sum(Transaction.amount)).filter_by(user_id=user_id, transaction_type="expense").scalar() or 0

    today = date.today()
    start_of_month = date(today.year, today.month, 1)
    if today.month == 12:
        end_of_month = date(today.year + 1, 1, 1) - timedelta(days=1)
    else:
        end_of_month = date(today.year, today.month + 1, 1) - timedelta(days=1)
    current_month_income = float(db.session.query(db.func.sum(Transaction.amount)).filter(
            Transaction.user_id == user_id,
            Transaction.transaction_type == 'income',
            Transaction.transaction_date >= start_of_month,
            Transaction.transaction_date <= end_of_month
        ).scalar() or 0)
    current_month_expense = float(db.session.query(db.func.sum(Transaction.amount)).filter(
            Transaction.user_id == user_id,
            Transaction.transaction_type == 'expense',
            Transaction.transaction_date >= start_of_month,
            Transaction.transaction_date <= end_of_month
        ).scalar() or 0)

    return jsonify({
        "total_income": round(total_income, 2),
        "total_expense": round(total_expense, 2),
        "current_month_income": round(current_month_income, 2),
        "current_month_expense": round(current_month_expense, 2)
    })

@stats_bp.route("/timeline", methods=['GET'])
@jwt_required()
def get_timeline_stats():
    user_id = get_jwt_identity()
    # user_id = request.args.get("user_id")
    start_date = request.args.get("start_date")
    end_date = request.args.get("end_date")

    if not user_id:
        return jsonify({'error':'user_id is required'}),400

    daily_totals = db.session.query( 
        Transaction.transaction_date,
        func.sum(
            case(
                (Transaction.transaction_type == "income", Transaction.amount), 
                else_=0
            )
        ).label("total_income"),
        func.sum(
            case(
                (Transaction.transaction_type == "expense", Transaction.amount), 
                else_=0
            )
        ).label("total_expense")
    ).filter(
        Transaction.user_id == user_id,
        Transaction.transaction_date >= start_date,
        Transaction.transaction_date <= end_date
    ).group_by(
        Transaction.transaction_date
    ).order_by(
        Transaction.transaction_date
    ).all()

    timeline=[]
    for t in daily_totals:
        timeline.append(
            {
                "date": t[0].strftime("%Y-%m-%d"),
                'income': t[1],
                'expense': t[2]
            }
        )
    return jsonify(timeline)

@stats_bp.route("/categories", methods=["GET"])
@jwt_required()
def get_categories_stats():
    user_id = get_jwt_identity()
    # user_id = request.args.get("user_id")
    start_date = request.args.get("start_date")
    end_date = request.args.get("end_date")

    expense_by_category = db.session.query(
        Category.name.label("category_name"),
        func.sum(
            Transaction.amount
        ).label("total_expense")
    ).filter(
        Transaction.user_id == user_id,
        Transaction.transaction_type == "expense",
        Transaction.transaction_date >= start_date,
        Transaction.transaction_date <= end_date
    ).join(
        Category, Transaction.category_id == Category.category_id
    ).group_by(
        Category.category_id, Category.name
    ).all()

    print(expense_by_category)
    result = []
    for r in expense_by_category:
        result.append(
            {
                "category_name": r[0],
                "expense": r[1]
            }
        )
    return jsonify(result)

@stats_bp.route("/transaction_history", methods=['GET'])
@jwt_required()
def get_transaction_history():
    user_id = get_jwt_identity()
    # user_id = request.args.get("user_id")
    start_date = request.args.get("start_date")
    end_date = request.args.get("end_date")

    history = db.session.query(
        Category.name.label("category_name"),
        Transaction.amount.label("amount"),
        Transaction.transaction_type.label("transaction_type"),
        Transaction.transaction_date.label("transaction_date"),
        Transaction.description.label("description")
    ).filter(
        Transaction.user_id == user_id,
        Transaction.transaction_date >= start_date,
        Transaction.transaction_date <= end_date
    ).join(
        Category, Transaction.category_id == Category.category_id
    ).all()

    result = []
    for h in history:
        result.append(
            {
                "category_name": h[0],
                "amount" : h[1],
                "transaction_type": h[2],
                "transaction_date": h[3],
                "description": h[4]
            }
        )

    return jsonify(result)