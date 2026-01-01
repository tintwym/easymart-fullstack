import os
import shutil
import uuid
from contextlib import asynccontextmanager
from fastapi import FastAPI, UploadFile, File, Request
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from .routers import auth, users, listings, offers, message, categories
from .models.models import Base
from .db.database import engine

# --------------------
# Setup Upload Directory
# --------------------
# We go up one level (..) to save images in backend/static, not backend/app/static
UPLOAD_DIR = "../static/images" 
os.makedirs(UPLOAD_DIR, exist_ok=True)

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Startup: Initializing database tables...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    print("Shutdown: Cleanup complete.")

app = FastAPI(title="EasyMart API", version="1.0.0", lifespan=lifespan)

# Mount static folder (Go up one level to find static)
app.mount("/static", StaticFiles(directory="../static"), name="static")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:8000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
        "*" # Keep wildcard as fallback for mobile apps
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"status": "EasyMart API is running"}

@app.post("/api/upload")
async def upload_image(request: Request, file: UploadFile = File(...)):
    if not file.filename:
        return {"error": "No filename provided"}

    file_extension = file.filename.split(".")[-1]
    unique_filename = f"{uuid.uuid4()}.{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, unique_filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    base_url = str(request.base_url).rstrip("/")
    # Check if "static" is doubled in URL, remove if necessary
    url_path = f"static/images/{unique_filename}"
    return {"url": f"{base_url}/{url_path}"}

# --------------------
# Routers
# --------------------
# ✅ Explicitly define /api/auth here
app.include_router(auth.router, prefix="/api/auth", tags=["Auth"])
app.include_router(users.router, prefix="/api")
app.include_router(listings.router, prefix="/api")
app.include_router(offers.router, prefix="/api")
app.include_router(message.router, prefix="/api")
app.include_router(categories.router, prefix="/api")