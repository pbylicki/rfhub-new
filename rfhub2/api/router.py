from fastapi import APIRouter

from rfhub2.api.endpoints import (
    collections,
    healthcheck,
    keywords,
    keyword_statistics,
    version,
    suites,
    test_cases,
)

api_router = APIRouter()
api_router.include_router(healthcheck.router, prefix="/health", tags=["healthcheck"])
api_router.include_router(
    collections.router, prefix="/collections", tags=["collections"]
)
api_router.include_router(keywords.router, prefix="/keywords", tags=["keywords"])
api_router.include_router(
    keyword_statistics.router, prefix="/statistics/keywords", tags=["statistics"]
)
api_router.include_router(suites.router, prefix="/suites", tags=["suites"])
api_router.include_router(test_cases.router, prefix="/test_cases", tags=["test_cases"])
api_router.include_router(version.router, prefix="/version", tags=["version"])
