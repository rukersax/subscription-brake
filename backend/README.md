# Subscription Brake - Backend (FastAPI + SQLAlchemy)

## Setup & Execution

### 1. Requirements
- Python 3.11+
- Virtual Environment (`venv` or `poetry`)

### 2. Environment Configuration
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Seed the Subscription Catalog (15+ Turkish & Global Services)
```bash
python seed_catalog.py
```

### 5. Run FastAPI Development Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Visit http://localhost:8000/docs for Swagger UI.
