from requests import session, Response
from typing import Dict, Tuple


API_V1 = "api/v1"
TEST_COLLECTION = {
    "name": "healtcheck_collection",
    "type": "a",
    "version": "a",
    "scope": "a",
    "named_args": "a",
    "path": "a",
    "doc": "a",
    "doc_format": "a",
}


class Client(object):
    """
    API client with methods to populate rfhub2 application.
    """

    def __init__(self, app_url: str, user: str, password: str):
        self.app_url = app_url
        self.session = session()
        self.api_url = f"{self.app_url}/{API_V1}"
        self.session.auth = (user, password)
        self.session.headers = {
            "Content-Type": "application/json",
            "accept": "application/json",
        }

    def get_collections(self) -> Response:
        """
        Gets list of collections object using request get method.
        """
        return self._get_request(endpoint="collections")

    def add_collection(self, data: Dict) -> Dict:
        """
        Adds collection using request post method.
        """
        return self._post_request(endpoint="collections", data=data)

    def update_collection(self, data: Dict, id: int) -> Dict:
        """
        Updates collection using request post method.
        """
        return self._put_request(endpoint="collections", data=data, id=id)

    def delete_collection(self, id: int) -> Response:
        """
        Deletes collection with given id.
        """
        return self._delete_request(endpoint="collections", id=id)

    def add_keyword(self, data: Dict) -> Dict:
        """
        Adds keyword using request post method.
        """
        return self._post_request(endpoint="keywords", data=data)

    def update_keyword(self, data: Dict, id: int) -> Dict:
        """
        Updates keyword using request post method.
        """
        return self._put_request(endpoint="keywords", data=data, id=id)

    def _get_request(self, endpoint: str) -> Dict:
        """
        Sends get request from given endpoint.
        """
        request = self.session.get(url=f"{self.api_url}/{endpoint}/")
        return request.json()

    def _post_request(self, endpoint: str, data: Dict) -> Tuple[int, Dict]:
        """
        Sends post request to collections or keywords endpoint.
        """
        request = self.session.post(url=f"{self.api_url}/{endpoint}/", json=data)
        return request.status_code, request.json()

    def _put_request(self, endpoint: str, data: Dict, id: int) -> Tuple[int, Dict]:
        """
        Sends put request to collections or keywords endpoint.
        """
        request = self.session.put(url=f"{self.api_url}/{endpoint}/{id}/", json=data)
        return request.status_code, request.json()

    def _delete_request(self, endpoint: str, id: int) -> Response:
        """
        Sends delete request to collections or keywords endpoint with item id.
        """
        return self.session.delete(url=f"{self.api_url}/{endpoint}/{id}/")
