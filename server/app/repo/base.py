class BaseRepo:
    def __init__(self, db, table_name):
        self.__db = db
        self.table = db.Table(table_name)