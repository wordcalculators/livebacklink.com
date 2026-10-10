import re

with open('database-schema.sql', 'r') as f:
    sql = f.read()

# Remove ON UPDATE CURRENT_TIMESTAMP
sql = re.sub(r'ON UPDATE CURRENT_TIMESTAMP', '', sql)

# Convert AUTO_INCREMENT to AUTOINCREMENT (SQLite requires INTEGER PRIMARY KEY AUTOINCREMENT)
sql = re.sub(r'INT\s+AUTO_INCREMENT\s+PRIMARY KEY', 'INTEGER PRIMARY KEY AUTOINCREMENT', sql, flags=re.IGNORECASE)
sql = re.sub(r'INT\s+PRIMARY KEY\s+AUTO_INCREMENT', 'INTEGER PRIMARY KEY AUTOINCREMENT', sql, flags=re.IGNORECASE)
# Sometimes it's written as id INT AUTO_INCREMENT, and PRIMARY KEY (id) at the end.
sql = re.sub(r'id INT AUTO_INCREMENT,', 'id INTEGER PRIMARY KEY AUTOINCREMENT,', sql, flags=re.IGNORECASE)
sql = re.sub(r'PRIMARY KEY\s*\([^\)]+\),?', '', sql, flags=re.IGNORECASE)

# Convert ENUM to TEXT with CHECK
def enum_replacer(match):
    col = match.group(1)
    vals = match.group(2)
    default = match.group(3)
    res = f"{col} TEXT CHECK({col} IN ({vals}))"
    if default:
        res += f" {default}"
    return res

sql = re.sub(r'(\w+)\s+ENUM\(([^\)]+)\)(?:\s+(DEFAULT\s+\'[^\']+\'))?', enum_replacer, sql, flags=re.IGNORECASE)

# Convert other types
sql = re.sub(r'INT\b', 'INTEGER', sql, flags=re.IGNORECASE)
sql = re.sub(r'TINYINTEGER\(1\)', 'INTEGER', sql, flags=re.IGNORECASE)
sql = re.sub(r'VARCHAR\(\d+\)', 'TEXT', sql, flags=re.IGNORECASE)
sql = re.sub(r'DECIMAL\([^)]+\)', 'REAL', sql, flags=re.IGNORECASE)

# Clean up empty commas before closing parenthesis
sql = re.sub(r',\s*\)', '\n)', sql)

# Remove the information_schema query at the end
sql = re.sub(r'SELECT table_name FROM information_schema.*', '', sql)

with open('backend/database/schema-sqlite.sql', 'w') as f:
    f.write(sql)
