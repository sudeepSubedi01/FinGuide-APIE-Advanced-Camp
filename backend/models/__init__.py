from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

from .users import User
from .categories import Category
from .transactions import Transaction
from .ai_log import AIRecommendationLog
from .enums import TransactionType