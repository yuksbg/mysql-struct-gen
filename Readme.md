# mysql-struct-gen

A  flexible MySQL to Go struct generator that automatically creates type-safe Go structs from your database schema.


## Features

- 🚀 **Automatic Struct Generation** - Generate Go structs directly from MySQL database tables
- 🎨 **Custom Templates** - Use inline templates, external template files, or the built-in default
- 🏷️ **Flexible Tagging** - Support for `db`, `json`, `gorm`, `validate`, and custom struct tags
- 🔧 **Configurable Null Handling** - Choose between `sql.Null*`, pointers, or zero values for nullable fields
- 📦 **Selective Generation** - Generate structs for specific tables or entire databases
- 🎯 **Type Mapping** - Custom type mappings for specialized database types
- 📝 **YAML Configuration** - Simple, readable configuration format

## Installation

### Prerequisites

- Go 1.16 or higher
- MySQL database access



## Quick Start

1. **Create a configuration file** (`config.yaml`):

```yaml
database:
  host: 127.0.0.1
  port: 3306
  user: root
  password: your_password
  name: your_database

output:
  package_name: models
  file_name: models/db_structs.go

options:
  tag_label: db
  json_tags: true
  use_pointers: false
  use_zero_values: true
```

2. **Run the generator**:

```bash
mysql-struct-gen -config config.yaml
```

3. **Use your generated structs**:

```go
package main

import "yourproject/models"

func main() {
    user := models.Users{
        ID:    1,
        Name:  "John Doe",
        Email: "john@example.com",
    }
    // ... use your structs
}
```

## Configuration

### Database Configuration

```yaml
database:
  host: 127.0.0.1          # MySQL host
  port: 3306               # MySQL port (default: 3306)
  user: root               # Database user
  password: your_password  # Database password
  name: your_database      # Database name
  tables:                  # Optional: specific tables to generate
    - users
    - posts
    - comments
```

### Output Configuration

```yaml
output:
  package_name: models                    # Go package name
  file_name: models/db_structs.go        # Output file path
  
  # Option 1: Inline template
  template: |
    package {{ .PackageName }}
    // ... your template
  
  # Option 2: External template file
  template_path: ./templates/custom.tmpl
```

### Options Configuration

```yaml
options:
  tag_label: db              # Primary struct tag name
  json_tags: true            # Generate JSON tags
  
  # Nullable field handling (choose one strategy):
  use_pointers: false        # Use *string instead of sql.NullString
  use_zero_values: true      # Use plain types (NULL becomes zero value)
  
  # Custom type mappings
  custom_type_mappings:
    json: "string"
    uuid: "uuid.UUID"
  
  # Additional struct tags
  additional_tags:
    gorm: "column:{column};type:{column_type}"
    validate: "required"
    form: "{column}"
```

## Usage Examples

### Basic Usage

```bash
# Use default config.yaml
mysql-struct-gen

# Specify custom config file
mysql-struct-gen -config production.yaml

# Short form
mysql-struct-gen -c myconfig.yaml

# Show version
mysql-struct-gen -version
```

### Example Generated Output

For a table `users`:

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Generated struct with `use_zero_values: true`:

```go
// Users represents a row in the users table
type Users struct {
    Id        int64     `db:"id" gorm:"column:id;type:int" json:"id,omitempty"`
    Name      string    `db:"name" gorm:"column:name;type:varchar(100)" json:"name,omitempty"`
    Email     string    `db:"email" gorm:"column:email;type:varchar(255)" json:"email,omitempty"`
    CreatedAt time.Time `db:"created_at" gorm:"column:created_at;type:timestamp" json:"created_at,omitempty"`
}

// TableName returns the table name for Users
func (Users) TableName() string {
    return "users"
}
```

### Nullable Field Strategies

#### 1. Using sql.Null* types (default)

```yaml
options:
  use_pointers: false
  use_zero_values: false
```

```go
Email sql.NullString `db:"email"`
```

#### 2. Using Pointers

```yaml
options:
  use_pointers: true
  use_zero_values: false
```

```go
Email *string `db:"email"`
```

#### 3. Using Zero Values

```yaml
options:
  use_pointers: false
  use_zero_values: true
```

```go
Email string `db:"email"`  // NULL becomes ""
```

## Custom Templates

### Template Variables

Your templates have access to:

- `.PackageName` - Package name from config
- `.Imports` - Required imports (automatically detected)
- `.Tables` - Slice of tables
- `.Timestamp` - Generation timestamp

### Table Object

Each table has:

- `.Name` - Pascal case struct name (e.g., "UserProfiles")
- `.OriginalName` - Original database table name (e.g., "user_profiles")
- `.Fields` - Slice of fields

### Field Object

Each field has:

- `.Name` - Pascal case field name
- `.Type` - Go type (e.g., "string", "*int64", "sql.NullString")
- `.Tags` - Complete struct tag string
- `.IsNullable` - Boolean indicating if field is nullable

### Custom Template Example

```yaml
output:
  template: |
    package {{ .PackageName }}
    
    {{ range .Tables }}
    // {{ .Name }} - {{ .OriginalName }} table
    type {{ .Name }} struct {
    {{- range .Fields }}
      {{ .Name }} {{ .Type }} {{ .Tags }} // Auto-generated
    {{- end }}
    }
    
    // NewEmpty{{ .Name }} creates an empty {{ .Name }}
    func NewEmpty{{ .Name }}() *{{ .Name }} {
      return &{{ .Name }}{}
    }
    {{ end }}
```

## Additional Tag Placeholders

When using `additional_tags`, you can use these placeholders:

- `{column}` - Original column name (e.g., "user_id")
- `{field}` - Go field name (e.g., "UserId")
- `{type}` - SQL data type (e.g., "varchar")
- `{column_type}` - Full column type (e.g., "varchar(255)")
- `{table}` - Table name

Example:

```yaml
additional_tags:
  gorm: "column:{column};type:{column_type}"
  validate: "min=1,max=100"
  form: "{column}"
  example: "table:{table},field:{field}"
```

## Type Mappings

Default MySQL to Go type mappings:

| MySQL Type | Go Type | Nullable (sql.Null*) | Nullable (pointer) |
|------------|---------|----------------------|-------------------|
| VARCHAR, TEXT | string | sql.NullString | *string |
| INT, BIGINT | int64 | sql.NullInt64 | *int64 |
| FLOAT, DECIMAL | float64 | sql.NullFloat64 | *float64 |
| DATETIME, TIMESTAMP | time.Time | sql.NullTime | *time.Time |
| BLOB, BINARY | []byte | []byte | []byte |

Override with `custom_type_mappings`:

```yaml
options:
  custom_type_mappings:
    json: "json.RawMessage"
    uuid: "uuid.UUID"
    geometry: "orb.Geometry"
```

## Common Workflows

### Generate for Specific Tables Only

```yaml
database:
  tables:
    - users
    - orders
    - products
```

### Generate to Different Packages

```yaml
# config-users.yaml
output:
  package_name: user_models
  file_name: internal/user/models.go

# config-orders.yaml  
output:
  package_name: order_models
  file_name: internal/order/models.go
```

### Integration with GORM

```yaml
options:
  tag_label: db
  json_tags: true
  use_zero_values: true
  additional_tags:
    gorm: "column:{column};type:{column_type}"
```

### Integration with sqlx

```yaml
options:
  tag_label: db
  json_tags: true
  use_pointers: false
  use_zero_values: false
```

## Troubleshooting

### Connection Issues

```bash
# Error: Failed to connect to database
```

**Solution**: Check your database credentials, host, and port in `config.yaml`. Ensure MySQL is running and accessible.

### Permission Issues

```bash
# Error: Access denied for user
```

**Solution**: Ensure the database user has `SELECT` permission on `information_schema.COLUMNS`.

### Template Parse Errors

```bash
# Error: Failed to parse template
```

**Solution**: Check your template syntax. Use `{{ }}` for variables and `{{- }}` to trim whitespace.


## Dependencies

- [go-sql-driver/mysql](https://github.com/go-sql-driver/mysql) - MySQL driver
- [gopkg.in/yaml.v3](https://gopkg.in/yaml.v3) - YAML parsing

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


Made with ❤️