from . import db

class Category(db.Model):
    __tablename__ = "categories"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    name = db.Column(db.String(100), nullable=False)

    transactions = db.relationship(
        "Transaction",
        backref="category",
        passive_deletes=True,
        lazy=True
    )

    __table_args__ = (
        db.UniqueConstraint("user_id", "name", name="unique_user_category"),
    )