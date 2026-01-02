# PyCharm Setup Guide for EasyMart Backend

## Prerequisites
1. **PyCharm** (Professional or Community Edition)
2. **Python 3.11** installed on your system
3. **Docker Desktop** running (for PostgreSQL database)
4. **PostgreSQL** database running via Docker Compose

## Step-by-Step Setup

### 1. Open Project in PyCharm
1. Open PyCharm
2. Click `File` → `Open`
3. Navigate to `/Users/ywaychitaung/Desktop/Projects/easymart-fullstack/backend_api`
4. Click `OK`

### 2. Configure Python Interpreter
1. Go to `PyCharm` → `Settings` (or `Preferences` on Mac)
2. Navigate to `Project: backend_api` → `Python Interpreter`
3. Click the gear icon ⚙️ → `Add...`
4. Select `Existing environment`
5. Navigate to: `/Users/ywaychitaung/Desktop/Projects/easymart-fullstack/backend_api/env/bin/python`
6. Click `OK`

**Alternative:** If the virtual environment doesn't exist, create a new one:
1. Click the gear icon ⚙️ → `Add...`
2. Select `New environment`
3. Location: `backend_api/env`
4. Base interpreter: Select Python 3.11
5. Click `OK`

### 3. Install Dependencies
1. Open PyCharm's terminal (View → Tool Windows → Terminal)
2. Activate the virtual environment (if not already active):
   ```bash
   source env/bin/activate  # On Mac/Linux
   # or
   env\Scripts\activate  # On Windows
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

### 4. Start PostgreSQL Database
Before running the backend, ensure PostgreSQL is running:

```bash
cd /Users/ywaychitaung/Desktop/Projects/easymart-fullstack/backend_api
docker-compose up -d db
```

Or start all services:
```bash
docker-compose up -d
```

### 5. Configure Run Configuration

#### Option A: Using PyCharm's FastAPI Run Configuration (Recommended)
1. Go to `Run` → `Edit Configurations...`
2. Click `+` → `Python`
3. Configure:
   - **Name:** `EasyMart Backend`
   - **Script path:** `$ProjectFileDir$/app/main.py`
   - **Parameters:** (leave empty)
   - **Python interpreter:** Select your virtual environment interpreter
   - **Working directory:** `$ProjectFileDir$`
   - **Environment variables:** (optional, if not using .env file)
     ```
     DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/local_db
     JWT_SECRET=f0v1AkvK9a9d+xJl9RM8ThWftL/ZIAoJKY0aZECXDdhRI5TUnDldSnOdjLgxgKF+ijPNTr1i30mq0/BZ2YMKQQ==
     ```
4. Click `OK`

#### Option B: Using Uvicorn Command
1. Go to `Run` → `Edit Configurations...`
2. Click `+` → `Python`
3. Configure:
   - **Name:** `EasyMart Backend (Uvicorn)`
   - **Module name:** `uvicorn` (check "Module name" radio button)
   - **Parameters:** `app.main:app --host 0.0.0.0 --port 8000 --reload`
   - **Python interpreter:** Select your virtual environment interpreter
   - **Working directory:** `$ProjectFileDir$`
4. Click `OK`

### 6. Run the Application
1. Select your run configuration from the dropdown (top right)
2. Click the green ▶️ Run button
3. Or press `Shift + F10`

### 7. Verify It's Working
1. Open your browser or API client
2. Navigate to: `http://localhost:8000`
3. You should see: `{"status":"EasyMart API is running"}`
4. Check API docs at: `http://localhost:8000/docs`

## Troubleshooting

### Issue: Module not found errors
**Solution:** Ensure the Python interpreter is set to the virtual environment and dependencies are installed.

### Issue: Database connection errors
**Solution:** 
1. Ensure Docker is running
2. Start PostgreSQL: `docker-compose up -d db`
3. Check `.env` file has correct `DATABASE_URL`

### Issue: Port 8000 already in use
**Solution:** 
1. Change port in run configuration: `--port 8001`
2. Or stop the Docker container: `docker-compose down`

### Issue: Import errors (app.routers, app.models, etc.)
**Solution:** 
1. Mark `backend_api` as Sources Root:
   - Right-click `backend_api` folder → `Mark Directory as` → `Sources Root`
2. Or add to PYTHONPATH in run configuration:
   - `Environment variables`: `PYTHONPATH=$ProjectFileDir$`

## Useful PyCharm Features

### Debugging
1. Set breakpoints by clicking left of line numbers
2. Run in Debug mode (🐛 icon or `Shift + F9`)
3. Use Debugger panel to inspect variables

### API Testing
1. Use PyCharm's built-in HTTP Client
2. Create `.http` files in project root
3. Example: `test.http`
   ```http
   POST http://localhost:8000/api/auth/register
   Content-Type: application/json
   
   {
     "email": "test@example.com",
     "name": "Test User",
     "password": "test123"
   }
   ```

### Database Tools
1. Install Database plugin (if not already installed)
2. Connect to PostgreSQL:
   - Host: `localhost`
   - Port: `5432`
   - Database: `local_db`
   - User: `postgres`
   - Password: `postgres`

## Environment Variables
The project uses `.env` file for configuration. Make sure `.env` exists in `backend_api/` directory with:
```
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/local_db
JWT_SECRET=your-secret-key
```

## Quick Commands Reference

```bash
# Activate virtual environment
source env/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start database
docker-compose up -d db

# Start all services (database + backend)
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f web
```

