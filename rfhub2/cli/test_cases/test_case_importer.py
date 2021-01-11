from pathlib import Path
from typing import Tuple

from rfhub2.cli.api_client import Client
from .test_cases_extractor import TestCasesExtractor


class TestCaseImporter:
    def __init__(self, client: Client, paths: Tuple[Path, ...]) -> None:
        self.client = client
        self.paths = paths

    def import_data(self) -> Tuple[int, int]:
        """
        Wrapper for import_libraries, import_statistics and import_test_cases to unify modules.
        :return: Number of suites and testcases loaded
        """
        return self.import_test_cases()

    def import_test_cases(self) -> Tuple[int, int]:
        extractor = TestCasesExtractor(self.paths)
        suites = extractor.create_testdoc_from_paths()
        tc_count = sum(suite.test_count for suite in suites if not suite.parent)
        return len(suites), tc_count
