from setuptools import find_packages, setup

package_name = "example_py_tools"

setup(
    name=package_name,
    version="0.1.0",
    packages=find_packages(exclude=["test"]),
    package_data={package_name: ["py.typed"]},
    data_files=[
        ("share/ament_index/resource_index/packages", [f"resource/{package_name}"]),
        (f"share/{package_name}", ["package.xml"]),
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
            "temperature_reporter = example_py_tools.main:main",
        ],
    },
)
