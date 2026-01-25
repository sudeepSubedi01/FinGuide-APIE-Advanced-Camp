from flask import Blueprint, request, jsonify
from services.analytics_services import generate_monthly_analytics
from services.insights_engine import generate_all_insights
from datetime import datetime
from flask_jwt_extended import jwt_required, get_jwt_identity

analytics_bp = Blueprint("analytics", __name__)

@analytics_bp.route("/monthly", methods=["GET"])
@jwt_required()
def monthly_analytics():
    # user_id = request.args.get("user_id", type=int)
    user_id = get_jwt_identity()
    year = request.args.get("year", type=int)
    month = request.args.get("month", type=int)

    if not all([user_id, year, month]):
        return jsonify({"error": "user_id, year, month required"}), 400

    data = generate_monthly_analytics(user_id, year, month)
    return jsonify(data)


@analytics_bp.route("/insights", methods=["GET"])
@jwt_required()
def get_insights():
    # user_id = request.args.get("user_id", type=int)
    user_id = get_jwt_identity()
    start = request.args.get("start_date")
    end = request.args.get("end_date")

    if not all([user_id, start, end]):
        return jsonify({"error": "user_id, start_date, end_date required"}), 400

    try:
        start_date = datetime.strptime(start, "%Y-%m-%d").date()
        end_date = datetime.strptime(end, "%Y-%m-%d").date()
    except ValueError:
        return jsonify({"error": "Invalid date format. Use YYYY-MM-DD."}), 400

    insights = generate_all_insights(user_id, start_date, end_date)
    return jsonify({"rule_based_insights": insights})