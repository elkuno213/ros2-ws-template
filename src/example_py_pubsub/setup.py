from glob import glob

from setuptools import find_packages, setup

package_name = "example_py_pubsub"

setup(
    name=package_name,
    version="0.2.1",
    packages=find_packages(exclude=["test"]),
    data_files=[
        ("share/ament_index/resource_index/packages", [f"resource/{package_name}"]),
        (f"share/{package_name}", ["package.xml"]),
        (f"share/{package_name}/launch", glob("launch/*.launch.py")),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="elkuno213",
    maintainer_email="elkuno213@example.com",
    description="Minimal Python ROS2 subscriber example for the workspace template.",
    license="MIT",
    extras_require={"test": ["pytest"]},
    entry_points={
        "console_scripts": [
            "temperature_subscriber = example_py_pubsub.temperature_subscriber:main",
        ],
    },
)
