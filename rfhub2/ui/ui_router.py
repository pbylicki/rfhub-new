from fastapi import APIRouter, Depends
from starlette.requests import Request
from starlette.templating import Jinja2Templates
from typing import Optional

from rfhub2.api.utils.db import get_collection_repository, get_keyword_repository
from rfhub2.api.utils.http import or_404
from rfhub2.db.repository.collection_repository import CollectionRepository
from rfhub2.db.repository.keyword_repository import KeywordRepository
from rfhub2.utils import abs_path
from rfhub2.version import version

router = APIRouter()

templates = Jinja2Templates(directory=abs_path("templates"))


@router.get("/")
async def home(request: Request,
               repository: CollectionRepository = Depends(get_collection_repository)):
    collections = repository.get_all()
    libraries = repository.get_all(libtype="library")
    resource_files = repository.get_all(libtype="resource")
    context = {
        "request": request,
        "hierarchy": collections,
        "libraries": libraries,
        "resource_files": resource_files,
        "version": version
    }
    return templates.TemplateResponse("home.html", context)


@router.get("/index")
async def index(request: Request,
                repository: CollectionRepository = Depends(get_collection_repository)):
    libraries = repository.get_all(libtype="library")
    resource_files = repository.get_all(libtype="resource")
    context = {
        "request": request,
        "libraries": libraries,
        "resource_files": resource_files,
        "version": version
    }
    return templates.TemplateResponse("libraryNames.html", context)


@router.get("/search")
async def search(request: Request,
                 pattern: str = "*",
                 repository: KeywordRepository = Depends(get_keyword_repository)):
    # todo: extract name: and in: from pattern and pass as appropriate params to repo method
    # todo: results should be sorted by keyword name
    keywords = repository.get_all(pattern=pattern)
    context = {
        "request": request,
        "keywords": keywords,
        "pattern": pattern,
        "version": version
    }
    return templates.TemplateResponse("search.html", context)


@router.get("/keywords/{collection_id}")
async def collection_doc(request: Request,
                         collection_id: int,
                         repository: CollectionRepository = Depends(get_collection_repository)):
    return base_doc_view(request, repository, collection_id)


@router.get("/keywords/{collection_id}/{keyword_id}")
async def keyword_doc(request: Request,
                      collection_id: int,
                      keyword_id: int,
                      repository: CollectionRepository = Depends(get_collection_repository)):
    return base_doc_view(request, repository, collection_id, keyword_id)


def base_doc_view(request: Request,
                  repository: CollectionRepository,
                  collection_id: int,
                  keyword_id: Optional[int] = None):
    collection = or_404(repository.get(collection_id))
    collections = repository.get_all()
    context = {
        "request": request,
        "collection": collection,
        "keyword_id": keyword_id,
        "hierarchy": collections,
        "version": version
    }
    return templates.TemplateResponse("library.html", context)
