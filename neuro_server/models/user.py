import pymysql, os

from peewee import *

DATABASE = MySQLDatabase(os.environ['dbdatabase'], user=os.environ['dbuser'], passwd=os.environ['dbpassword'], host=os.environ['dbhost'], port=3306)
#DATABASE = MySQLDatabase('neuro-db', user='root', passwd='root', host='127.0.0.1', port=3306)

class Admin(Model):
    username = CharField(unique=True)
    emailid = CharField(unique=True)
    password = CharField(max_length=40)

    class Meta:
        database = DATABASE


class User(Model):
    """A base model that will use our MySQL database"""
    username = CharField(unique=True)
    password = CharField(max_length=40)
    emailid = CharField(unique=True)
    active = CharField(max_length=20, default='Active')

    class Meta:
        database = DATABASE

class Acceleration(Model):

    '''A base model used to store accelerometer readings in mysql'''
    username = CharField()
    x_acc = IntegerField()
    y_acc = IntegerField()
    z_acc = IntegerField()

    class Meta:
        database = DATABASE

def initialize():
    DATABASE.connect()
    DATABASE.create_tables([Admin, User], safe=True)
