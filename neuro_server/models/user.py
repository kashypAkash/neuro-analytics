import pymysql, os

from peewee import *

DATABASE = MySQLDatabase(os.environ['dbdatabase'], user=os.environ['dbuser'], passwd=os.environ['dbpassword'], host=os.environ['dbhost'], port=3306)
# DATABASE = MySQLDatabase('neuro-db', user='root', passwd='root', host='127.0.0.1', port=3306)

class Admin(Model):
    UserName = CharField(unique=True)
    EmailId = CharField(unique=True)
    Password = CharField(max_length=40)

    class Meta:
        database = DATABASE


class User(Model):
    """A base model that will use our MySQL database"""
    UserName = CharField(unique=True)
    Password = CharField(max_length=40)
    EmailId = CharField(unique=True)
    Active = CharField(max_length=20, default='Active')

    class Meta:
        database = DATABASE


def initialize():
    DATABASE.connect()
    DATABASE.create_tables([Admin, User], safe=True)
