from models import Transaction, Category, db
from utils.date_utils import get_month_range
from sqlalchemy import func
from datetime import datetime, timedelta
from collections import defaultdict
from sqlalchemy import cast,Date
from sqlalchemy.orm import joinedload

def generate_monthly_analytics(user_id, year, month):
    start, end = get_month_range(year, month)

    # print("start:", start)
    # print("end:", end)

    # txs = Transaction.query.filter(
    #     Transaction.user_id == user_id,
    #     cast(Transaction.transaction_date, Date) >= start,
    # cast(Transaction.transaction_date, Date) <= end
    # ).all()

    txs = Transaction.query.options(joinedload(Transaction.category)).filter(
        Transaction.user_id == user_id,
        Transaction.transaction_date >= start,
        Transaction.transaction_date <= end
    ).all()

    # print(f"Transactions found: {len(txs)}")
    # for t in txs:
    #     print(t.transaction_date, t.transaction_type.value, t.amount)

    summary = calculate_summary(txs)
    categories = category_breakdown(txs)
    trend = month_trend(user_id, year, month, summary["expense"])
    patterns = detect_patterns(txs)
    spikes = detect_spikes(user_id, year, month)

    return {
        "summary": summary,
        "categories": categories,
        "trend": trend,
        "patterns": patterns,
        "spikes": spikes
    }

def calculate_summary(transactions):
    income = sum(float(t.amount) for t in transactions if t.transaction_type.value == "income")
    expense = sum(float(t.amount) for t in transactions if t.transaction_type.value == "expense")
    savings = income - expense
    savings_ratio = (savings / income) if income > 0 else 0

    return {
        "income": round(income, 2),
        "expense": round(expense, 2),
        "savings": round(savings, 2),
        "savings_ratio": round(savings_ratio, 2)
    }


def category_breakdown(transactions):
    expense_txs = [t for t in transactions if t.transaction_type.value == "expense"]

    category_map = defaultdict(float)
    total_expense = sum(float(t.amount) for t in expense_txs)

    for tx in expense_txs:
        name = tx.category.name if tx.category else "Uncategorized"
        category_map[name] += float(tx.amount)

    result = []
    for cat, amt in category_map.items():
        percent = (amt / total_expense * 100) if total_expense > 0 else 0
        result.append({
            "category": cat,
            "amount": round(amt, 2),
            "percent": round(percent, 2)
        })

    return result


def month_trend(user_id, year, month, current_expense):
    prev_month = month - 1
    prev_year = year

    if prev_month == 0:
        prev_month = 12
        prev_year -= 1

    start, end = get_month_range(prev_year, prev_month)

    prev_expense = db.session.query(func.sum(Transaction.amount)).filter(
        Transaction.user_id == user_id,
        Transaction.transaction_type == "expense",
        Transaction.transaction_date >= start,
        Transaction.transaction_date <= end
    ).scalar() or 0

    change_percent = 0
    trend = "no_change"

    if prev_expense > 0:
        change_percent = ((float(current_expense) - float(prev_expense)) / float(prev_expense)) * 100
        if change_percent > 5:
            trend = "increase"
        elif change_percent < -5:
            trend = "decrease"

    return {
        "current_month_expense": round(current_expense, 2),
        "previous_month_expense": round(prev_expense, 2),
        "change_percent": round(change_percent, 2),
        "trend": trend
    }


def detect_patterns(transactions):
    weekend_expense = 0
    weekday_expense = 0
    # night_expense = 0
    total_expense = 0

    for tx in transactions:
        if tx.transaction_type.value != "expense":
            continue

        total_expense += tx.amount
        day = tx.transaction_date.weekday()
        # hour = tx.transaction_date.hour

        if day >= 5:
            weekend_expense += tx.amount
        else:
            weekday_expense += tx.amount

        # if hour >= 20 or hour <= 5:
            # night_expense += tx.amount

    # night_percent = (night_expense / total_expense * 100) if total_expense > 0 else 0

    return {
        "weekend_expense": round(weekend_expense, 2),
        "weekday_expense": round(weekday_expense, 2),
        "weekend_heavy": weekend_expense > weekday_expense
        # "night_expense_percent": round(night_percent, 2),
        # "night_spender": night_percent > 40
    }


def detect_spikes(user_id, year, month):
    start, end = get_month_range(year, month)

    prev_month = month - 1
    prev_year = year
    if prev_month == 0:
        prev_month = 12
        prev_year -= 1

    prev_start, prev_end = get_month_range(prev_year, prev_month)

    current = db.session.query(
        Category.name,
        func.sum(Transaction.amount)
    ).join(Category).filter(
        Transaction.user_id == user_id,
        Transaction.transaction_type == "expense",
        Transaction.transaction_date >= start,
        Transaction.transaction_date <= end
    ).group_by(Category.name).all()

    previous = db.session.query(
        Category.name,
        func.sum(Transaction.amount)
    ).join(Category).filter(
        Transaction.user_id == user_id,
        Transaction.transaction_type == "expense",
        Transaction.transaction_date >= prev_start,
        Transaction.transaction_date <= prev_end
    ).group_by(Category.name).all()

    prev_map = {c: amt for c, amt in previous}
    spikes = []

    for cat, amt in current:
        prev_amt = prev_map.get(cat, 0)
        if prev_amt > 0:
            change = ((amt - prev_amt) / prev_amt) * 100
            if change > 40:
                spikes.append({
                    "category": cat,
                    "change_percent": round(change, 2),
                    "spike": True
                })

    return spikes
