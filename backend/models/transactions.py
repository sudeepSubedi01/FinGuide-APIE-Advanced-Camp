from . import db
from .enums import TransactionType

class Transaction(db.Model):
    __tablename__ = "transactions"

    id = db.Column(db.Integer, primary_key = True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey("categories.category_id", ondelete="SET NULL"))
    amount = db.Column(db.Numeric(12,2), nullable=False)
    transaction_type = db.Column(db.Enum(TransactionType, name="transaction_type_enum"), nullable=False)
    transaction_date = db.Column(db.Date, nullable=False)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime(timezone=True), server_default=db.func.now())
