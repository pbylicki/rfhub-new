from pathlib import Path
import re
from robot.errors import DataError
from robot.libdocpkg import LibraryDocumentation
import robot.libraries
from typing import Dict, List, Set, Tuple

from .api_client import Client
from rfhub2.model import Collection, Keyword


RESOURCE_PATTERNS = {'.robot', '.txt', '.tsv', '.resource'}
ALL_PATTERNS = (RESOURCE_PATTERNS | {'.xml', '.py'})
EXCLUDED_LIBRARIES = {'remote.py', 'reserved.py', 'dialogs.py', 'dialogs_jy.py',
                      'dialogs_py.py', 'dialogs_ipy.py', 'setup.py'}
INIT_FILES = {'__init__.txt', '__init__.robot', '__init__.html', '__init__.tsv'}


class RfhubImporter(object):

    def __init__(self, paths: Tuple[Path, ...], no_installed_keywords: bool, client: Client) -> None:
        self.paths = paths
        self.no_installed_keywords = no_installed_keywords
        self.client = client

    def delete_collections(self) -> Set[int]:
        """
        Deletes all existing collections.
        """
        self.client.check_communication_with_app()
        collections = self.client.get_collections()
        collections_id = {collection['id'] for collection in collections}
        for id in collections_id:
            self.client.delete_collection(id)
        return collections_id

    def get_libraries_paths(self) -> Set[Path]:
        """
        Traverses all given paths and returns set with paths
        pointing to libraries to import to app.
        :return: Set of Paths object pointing to libraries to import
        """
        self.client.check_communication_with_app()
        libraries_paths = set()
        for path in self.paths:
            libraries_paths.update(self._traverse_paths(Path(path)))
        if not self.no_installed_keywords:
            libdir = Path(robot.libraries.__file__).parent
            libraries_paths.update(self._traverse_paths(Path(libdir)))
        return libraries_paths

    def _traverse_paths(self, path: Path) -> Set[Path]:
        """
        Traverses through paths and adds libraries to rfhub.
        Helper function for get_library_paths.
        """
        valid_lib_paths = set()
        if self._is_library_with_init(path):
            valid_lib_paths.add(path)
        else:
            for item in path.iterdir():
                if item.is_dir():
                    if self._is_library_with_init(item):
                        valid_lib_paths.add(item)
                    else:
                        valid_lib_paths.update(self._traverse_paths(item))
                elif item.is_file() and self._is_robot_keyword_file(item) and not self._should_ignore(item):
                    valid_lib_paths.add(item)
        return valid_lib_paths

    def create_collections(self, paths: Set[Path]) -> List[Collection]:
        """
        Creates list of Collection objects from set of provided paths.
        :param paths: set of paths
        :return: list of Collection objects
        """
        return [self.create_collection(path) for path in paths]
        # ToDo try except to handle problem with library creation

    def create_collection(self, path: Path):
        """
        Creates Collection object from provided path.
        :param path: Path
        :return: Collection object
        """
        libdoc = LibraryDocumentation(str(path))
        serialised_keywords = self._serialise_keywords(libdoc)
        return self._serialise_libdoc(libdoc, str(path), serialised_keywords)

    def add_collections(self, collections: List[Collection]) -> List[Dict[str, int]]:
        """
        Adds collections and keywords from provided list to app.
        :param collections: List of collections object
        :return: list of dictionaries with collection name and number of keywords.
        """
        loaded_collections = []
        for collection in collections:
            coll_req = self.client.add_collection(collection)
            if coll_req['name'] == collection['name']:
                collection_id = coll_req['id']
                for keyword in collection['keywords']:
                    keyword['collection_id'] = collection_id
                    self.client.add_keyword(keyword)
                loaded_collections.append({collection['name']: len(collection["keywords"])})
                print(f'{collection["name"]} library with {len(collection["keywords"])} keywords loaded.')
            else:
                print(f'{collection.name} library was not loaded!')
        return loaded_collections

    def _serialise_libdoc(self, libdoc: LibraryDocumentation, path: str, keywords: List[Keyword]) -> Collection:
        """
        Serialises libdoc object to Collection object.
        :param libdoc: libdoc input object
        :param path: library path
        :return: Collection object
        """

        lib_dict = libdoc.__dict__
        lib_dict['doc_format'] = lib_dict.pop('_setter__doc_format')
        for key in ('_setter__keywords', 'inits', 'named_args'):
            lib_dict.pop(key)
        lib_dict['path'] = path
        lib_dict['keywords'] = keywords
        return lib_dict

    def _serialise_keywords(self, libdoc: LibraryDocumentation) -> Keyword:
        """
        Serialises keywords to Keyword object.
        :param :libdoc input object
        :return: Keyword object
        """

        keywords = [keyword.__dict__ for keyword in libdoc.keywords]
        for keyword in keywords:
            keyword.pop('tags')
            if keyword["args"]:
                keyword["args"] = str([str(item) for item in keyword["args"]]).replace("\'", "\"")
            else:
                keyword["args"] = ""
        return keywords

    @staticmethod
    def _is_library_with_init(path: Path) -> bool:
        return (path / '__init__.py').is_file() and \
           len(LibraryDocumentation(str(path)).keywords) > 0

    def _is_robot_keyword_file(self, file: Path) -> bool:
        return self._is_library_file(file) or \
               self._is_libdoc_file(file) or \
               self._is_resource_file(file)

    @staticmethod
    def _is_library_file(file: Path) -> bool:
        return file.suffix == '.py' and file.name != "__init__.py"

    @staticmethod
    def _is_libdoc_file(file: Path) -> bool:
        """Return true if an xml file looks like a libdoc file"""
        # inefficient since we end up reading the file twice,
        # but it's fast enough for our purposes, and prevents
        # us from doing a full parse of files that are obviously
        # not libdoc files
        if file.suffix == '.xml':
            with open(file, "r") as f:
                # read the first few lines; if we don't see
                # what looks like libdoc data, return false
                data = f.read(200)
                index = data.lower().find("<keywordspec ")
                return index > 0
        return False

    @staticmethod
    def _should_ignore(file: Path) -> bool:
        """Return True if a given library name should be ignored
        This is necessary because not all files we find in the library
        folder are libraries.
        """
        filename = file.name.lower()
        return filename.startswith("deprecated") or \
               filename.startswith("_") or \
               filename in EXCLUDED_LIBRARIES

    @staticmethod
    def _is_resource_file(file: Path) -> bool:
        """Returns true if the file has a keyword table but not a testcase table."""
        # inefficient since we end up reading the file twice,
        # but it's fast enough for our purposes, and prevents
        # us from doing a full parse of files that are obviously
        # not robot files

        if file.name not in INIT_FILES and file.suffix in RESOURCE_PATTERNS:
            with open(file, "r") as f:
                data = f.read()
                return not RfhubImporter._has_test_case_table(data) and \
                    RfhubImporter._has_keyword_table(data)
        return False

    @staticmethod
    def _has_keyword_table(data: str) -> bool:
        """Returns true if file has keyword or user keyword table"""
        return re.search(r'^\*+\s*((?:User )?Keywords?)', data, re.MULTILINE | re.IGNORECASE) is not None

    @staticmethod
    def _has_test_case_table(data: str) -> bool:
        """Returns true if file has keyword or user keyword table"""
        return re.search(r'^\*+\s*(Test Cases?)', data, re.MULTILINE | re.IGNORECASE) is not None
