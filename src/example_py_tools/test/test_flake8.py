import pytest
from ament_flake8.main import main


@pytest.mark.flake8
@pytest.mark.linter
def test_flake8() -> None:
    rc = main(argv=[])
    assert rc == 0, "Found code style errors / warnings"
