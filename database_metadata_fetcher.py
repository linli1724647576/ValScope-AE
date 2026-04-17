from data_structures.table import Table
from data_structures.column import Column

class DatabaseMetadataFetcher:
    def __init__(self, host='127.0.0.1', port=4000, database='test', user='root', password='123456', dialect='MYSQL'):
        self.host = host
        self.port = port
        self.database = database
        self.user = user
        self.password = password
        self.dialect = dialect
        self.connection = None
    
    def connect(self):
        try:
            if self.dialect == 'MYSQL':
                import pymysql
                self.connection = pymysql.connect(
                    host=self.host,
                    port=self.port,
                    user=self.user,
                    password=self.password,
                    database=self.database,
                    charset='utf8mb4',
                    cursorclass=pymysql.cursors.DictCursor
                )
            return True
        except Exception as e:
            print(f"Connection failed: {e}")
            return False
    
    def disconnect(self):
        if self.connection:
            try:
                self.connection.close()
                self.connection = None
            except Exception as e:
                print(f"Disconnection failed: {e}")
    
    def get_all_tables_info(self):
        tables = []
        
        if not self.connection:
            return tables
        
        try:
            tables = self._get_mysql_tables()
        except Exception as e:
            print(f"Error getting tables info: {e}")
        
        return tables
    
    def _get_mysql_tables(self):
        tables = []
        cursor = self.connection.cursor()
        
        cursor.execute("SHOW TABLES")
        table_rows = cursor.fetchall()
        table_names = []
        
        # Handle both dict cursor and regular cursor
        for row in table_rows:
            if isinstance(row, dict):
                # Dict cursor - get the first value
                table_names.append(list(row.values())[0])
            else:
                # Regular cursor - get first element
                table_names.append(row[0])
        
        for table_name in table_names:
            columns = []
            primary_key = None
            foreign_keys = []
            
            cursor.execute(f"SHOW CREATE TABLE {table_name}")
            create_table_result = cursor.fetchone()
            if create_table_result:
                if isinstance(create_table_result, dict):
                    # Dict cursor
                    create_table_sql = create_table_result['Create Table']
                else:
                    # Regular cursor
                    create_table_sql = create_table_result[1]
                
                if 'PRIMARY KEY' in create_table_sql:
                    import re
                    pk_match = re.search(r'PRIMARY KEY \(([^)]+)\)', create_table_sql)
                    if pk_match:
                        primary_key = pk_match.group(1).strip()
            
            cursor.execute(f"DESCRIBE {table_name}")
            column_rows = cursor.fetchall()
            for col in column_rows:
                # Determine category based on data type
                data_type = col['Type'].upper()
                if any(keyword in data_type for keyword in ['INT', 'DECIMAL', 'FLOAT', 'DOUBLE', 'NUMERIC', 'REAL']):
                    category = 'numeric'
                elif any(keyword in data_type for keyword in ['VARCHAR', 'TEXT', 'STRING', 'CHAR', 'ENUM', 'SET']):
                    category = 'string'
                elif any(keyword in data_type for keyword in ['DATE', 'TIME', 'DATETIME', 'TIMESTAMP', 'YEAR']):
                    category = 'datetime'
                elif any(keyword in data_type for keyword in ['BOOLEAN', 'BOOL', 'TINYINT(1)']):
                    category = 'boolean'
                else:
                    category = 'string'  # Default category
                
                column = Column(
                    name=col['Field'],
                    data_type=col['Type'],
                    category=category,
                    is_nullable=(col['Null'] == 'YES'),
                    table_name=table_name
                )
                columns.append(column)
            
            cursor.execute(f"SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME = '{table_name}' AND REFERENCED_TABLE_NAME IS NOT NULL")
            fk_rows = cursor.fetchall()
            for fk in fk_rows:
                foreign_keys.append({
                    'column': fk['COLUMN_NAME'],
                    'ref_table': fk['REFERENCED_TABLE_NAME'],
                    'ref_column': fk['REFERENCED_COLUMN_NAME']
                })
            
            # Create Table object
            table = Table(
                name=table_name,
                columns=columns,
                primary_key=primary_key or '',
                foreign_keys=foreign_keys,
                indexes=None
            )
            tables.append(table)
        
        cursor.close()
        return tables
    
