# FinGuide - Think Smart Spend Smart

## Tech Stack
* **Frontend:** Flutter (Mobile/Web)
* **Backend:** Flask (Python)
* **Database:** PostgreSQL
* **Authentication:** JWT (JSON Web Tokens)

## Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Python 3.x](https://www.python.org/downloads/)
* [PostgreSQL](https://www.postgresql.org/download/)


### 1. Clone the Repository
```bash
git clone git@github.com:sudeepSubedi01/FinGuide-APIE-Advanced-Camp.git
cd FinGuide-APIE-Advanced-Camp
```
### 2. Backend Setup (Flask)
```bash
cd backend
# Create virtual environment
python3 -m venv venv
# Activate virtual environment
source venv/bin/activate    # Linux
venv\Scripts\activate       # Windows
# Install dependencies
pip install -r requirements.txt
```
<b>Environment Variables</b>: Create a `.env` file in the `/backend` directory:
```env
DATABASE_URL=postgresql+psycopg2://<username>:<password>@localhost:5432/finguide
JWT_SECRET_KEY=your_super_secret_key
```
<b>Database Initialization:</b>
```bash
# Ensure PostgreSQL is running and 'finguide' DB is created
flask db upgrade
# Or if using raw SQL:
psql -U <username> -d finguide -f database/schema.sql
```
<b>Run Server:</b>
```bash
flask run
```
Backend runs at: `http://localhost:5000`

### 3. Frontend Setup (Flutter)
Ensure your emulator is running or a device is connected.
```bash
# Navigate to /frontend folder
cd frontend
# Get dependencies
flutter pub get
# Run the flutter app
flutter run
```

## Project Structure
```

├── backend/            # Flask API, Models, and Routes
├── frontend/           # Flutter Application
├── database/           # SQL Schemas and Migrations
└── README.md
```