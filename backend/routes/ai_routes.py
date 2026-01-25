from flask import Blueprint, jsonify, request
from services.analytics_services import generate_monthly_analytics
from ai.ai_insights import generate_gemini_insights
from datetime import datetime
from flask_jwt_extended import jwt_required, get_jwt_identity

ai_bp = Blueprint("ai", __name__)

@ai_bp.route("/insights", methods=["GET"])
@jwt_required()
def get_ai_insights():
    user_id = get_jwt_identity()
    preference = request.args.get("preference", "")

    if not all([preference]):
        return jsonify({"error": "preference required"}), 400

    try:
        today = datetime.now()
        year = today.year
        month = today.month
        # print(today, year, month)
        month_str = f"{year}-{str(month).zfill(2)}"
        year, month = map(int, month_str.split("-"))
    except Exception:
        return jsonify({"error": "Month format should be YYYY-MM"}), 400

    analytics = generate_monthly_analytics(user_id, year, month) 
    user_profile = {"user_type": "student", "currency": "NPR"}

    try:
        ai_feedback = generate_gemini_insights(
            user_profile=user_profile,
            summary=analytics['summary'],
            category_dist=analytics["categories"],
            period=month_str,
            user_preference = preference
        )
    except Exception as e:
        print(e)
        return jsonify({"error": f"Failed to fetch AI insights: {e}"}), 500

    return jsonify({
        "analytics": analytics,
        "ai_insights": ai_feedback
    })
