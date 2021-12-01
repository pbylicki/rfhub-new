import responses
import unittest

from rfhub2.cli.api_client import Client
from rfhub2.model import CollectionUpdate, KeywordUpdate

COLLECTION = CollectionUpdate(
    name="Third",
    type="Library",
    version=None,
    scope=None,
    named_args=None,
    path=None,
    doc=None,
    doc_format=None,
)

KEYWORD = KeywordUpdate(
    name="Some keyword", doc="Perform some check", args=None, tags=[]
)


class ApiClientTests(unittest.TestCase):
    def setUp(self) -> None:
        self.app_url = "http://localhost:8000"
        self.client = Client(self.app_url, "rfhub", "rfhub")
        self.collection_endpoint = f"{self.client.api_url}/collections/"
        self.keyword_endpoint = f"{self.client.api_url}/keywords/"

    def test_get_collections(self):
        with responses.RequestsMock() as rsps:
            rsps.add(
                responses.GET,
                self.collection_endpoint,
                json=[COLLECTION.json()],
                status=200,
                content_type="application/json",
            )
            response = self.client.get_collections()
            self.assertEqual(response, [COLLECTION.json()])

    def test_add_collection(self):
        with responses.RequestsMock() as rsps:
            rsps.add(
                responses.POST,
                self.collection_endpoint,
                json=COLLECTION.json(),
                status=201,
                adding_headers={
                    "Content-Type": "application/json",
                    "accept": "application/json",
                },
            )
            response = self.client.add_collection(data=COLLECTION)
            self.assertEqual(response, (201, COLLECTION.json()))

    def test_delete_collection(self):
        with responses.RequestsMock() as rsps:
            rsps.add(
                responses.DELETE,
                f"{self.collection_endpoint}1/",
                status=204,
                adding_headers={"accept": "application/json"},
            )
            response = self.client.delete_collection(1)
            self.assertEqual(response.status_code, 204)

    def test_add_keyword(self):
        with responses.RequestsMock() as rsps:
            rsps.add(
                responses.POST,
                self.keyword_endpoint,
                json=KEYWORD.json(),
                status=201,
                adding_headers={
                    "Content-Type": "application/json",
                    "accept": "application/json",
                },
            )
            response = self.client.add_keyword(data=KEYWORD)
            self.assertEqual(response, (201, KEYWORD.json()))

    def test_delete_all_collection(self):
        with responses.RequestsMock() as rsps:
            rsps.add(
                responses.DELETE,
                f"{self.collection_endpoint}",
                status=204,
                adding_headers={"accept": "application/json"},
            )
            response = self.client.delete_all_collections()
            self.assertEqual(response.status_code, 204)
