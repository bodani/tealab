from setuptools import setup

setup(
    name='pg_migrete_database',
    version='0.1',
    py_modules=['pg_migrate'],
    include_package_data=True,
    install_requires=[
        'click','psycopg2'
    ],
    entry_points='''
        [pg_migrate]
        pg_migrate=pg_migrate:cli
    ''',
)