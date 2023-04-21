from setuptools import setup

setup(
    name='click-example-db',
    version='0.1',
    py_modules=['cooldb'],
    include_package_data=True,
    install_requires=[
        'click',
    ],
    entry_points='''
        [console_scripts]
        cooldb=demo:cli
    ''',
)