import os
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from backend.database.base import Base
from backend.database.session import engine
from backend.api import auth_routes, claim_routes, estimate_routes, report_routes

# Import all models so Base.metadata knows about them
from backend.models import user, claim, part, photo, document, assessment  # noqa: F401


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create all tables on startup
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(title="Motor Survey API", lifespan=lifespan)

origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000"
]

# Allow browser requests from Flutter web / mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve uploaded files
UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# Include routers
app.include_router(auth_routes.router, prefix="/auth", tags=["auth"])
app.include_router(claim_routes.router, prefix="/claims", tags=["claims"])
app.include_router(estimate_routes.router, prefix="/estimate", tags=["estimate"])
app.include_router(report_routes.router, prefix="/reports", tags=["reports"])


@app.get("/")
def read_root():
    return {"message": "Motor Survey backend is running"}
