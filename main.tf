terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.25.17"
    }
  }

  backend "remote" {
    organization = "my-organization-name"

    workspaces {
      name = "gh-actions-demo"
    }
  }
}

provider "snowflake" {
}

resource "snowflake_database" "demo_db" {
  name    = "DEMO_DB_V4"
  comment = "Database for Snowflake Terraform demo"
}

resource "snowflake_schema" "demo_schema" {
  database = snowflake_database.demo_db.name
  name     = "DEMO_SCHEMA"
  comment  = "Schema for Snowflake Terraform demo"
}

resource "snowflake_warehouse" "app_wh" {
  name                 = "AF_TEST"
  warehouse_size       = "XSMALL"
  auto_suspend         = 300
  auto_resume          = true
  initially_suspended  = false
}


# Create File Format
resource "snowflake_file_format" "csv_ff" {
  name                         = "APP_CSV_FF"
  database                     = "DEMO_DB_V4"
  schema                       = "DEMO_SCHEMA"
  format_type                  = "CSV"
  binary_format                = "UTF8"  # Binary format UTF-8
  compression                  = "AUTO"  # Automatic compression
  date_format                  = "AUTO"  # Auto date format
  encoding                     = "UTF8"  # Encoding set to UTF-8
  escape                       = "NONE"  # No escape character
  escape_unenclosed_field      = "NONE"  # No escape for unenclosed fields
  field_delimiter              = ";"  # Field delimiter set to semicolon
  field_optionally_enclosed_by = "\""  # Fields enclosed in double quotes
  record_delimiter             = "\r\n"  # Record delimiter set to carriage return + newline
  time_format                  = "AUTO"  # Auto time format
  timestamp_format             = "AUTO"  # Auto timestamp format
  empty_field_as_null          = true  # Empty fields treated as null
  null_if                      = ["", "NA", "NULL"]  # Null values to handle
  skip_header                  = 1  # Skip the header row (optional)
  validate_utf8                = true
}

resource "snowflake_file_format" "app_csv_ff" {
  name                         = "CSV_FF"
  database                     = "DEMO_DB_V4"
  schema                       = "DEMO_SCHEMA"
  format_type                  = "CSV"
  binary_format                = "UTF8"  # Binary format UTF-8
  compression                  = "AUTO"  # Automatic compression
  date_format                  = "AUTO"  # Auto date format
  encoding                     = "UTF8"  # Encoding set to UTF-8
  escape                       = "NONE"  # No escape character
  escape_unenclosed_field      = "NONE"  # No escape for unenclosed fields
  field_delimiter              = ";"  # Field delimiter set to semicolon
  field_optionally_enclosed_by = "\""  # Fields enclosed in double quotes
  record_delimiter             = "\r\n"  # Record delimiter set to carriage return + newline
  time_format                  = "AUTO"  # Auto time format
  timestamp_format             = "AUTO"  # Auto timestamp format
  empty_field_as_null          = true  # Empty fields treated as null
  null_if                      = ["", "NA", "NULL"]  # Null values to handle
  skip_header                  = 1  # Skip the header row (optional)
  validate_utf8                = true
}



resource "snowflake_table" "docs_chunks_table" {
  database = "DEMO_DB_V4"  # Replace with your database name
  schema   = "DEMO_SCHEMA"    # Replace with your schema name
  name     = "DOCS_CHUNKS_TABLE"

  column {
    name = "RELATIVE_PATH"
    type = "VARCHAR(16777216)"
    comment = "Relative path to the PDF file"
  }

  column {
    name = "SIZE"
    type = "NUMBER(38,0)"
    comment = "Size of the PDF"
  }

  column {
    name = "FILE_URL"
    type = "VARCHAR(16777216)"
    comment = "URL for the PDF"
  }

  column {
    name = "SCOPED_FILE_URL"
    type = "VARCHAR(16777216)"
    comment = "Scoped URL (you can choose which one to keep depending on your use case)"
  }

  column {
    name = "CHUNK"
    type = "VARCHAR(16777216)"
    comment = "Piece of text"
  }

  column {
    name = "CATEGORY"
    type = "VARCHAR(16777216)"
    comment = "Will hold the document category to enable filtering"
  }
}




# Create Documents Table
resource "snowflake_table" "documents" {
  name      = "DOCUMENTS"
  database  = "DEMO_DB_V4"
  schema    = "DEMO_SCHEMA"
  comment   = "{\"origin\":\"sf_sit-is\", \"name\":\"voc\", \"version\":{\"major\":1, \"minor\":0}, \"attributes\":{\"is_quickstart\":1, \"source\":\"streamlit\", \"vignette\":\"rag_chatbot\"}}"
  column {
    name = "RELATIVE_PATH"
    type = "VARCHAR(16777216)"
  }
  column {
    name = "RAW_TEXT"
    type = "VARCHAR(16777216)"
  }
}

# Create Array Table
resource "snowflake_table" "array_table" {
  name     = "ARRAY_TABLE"
  database = "DEMO_DB_V4"
  schema   = "DEMO_SCHEMA"
  column {
    name = "SOURCE"
    type = "VARCHAR(6)"
  }
  column {
    name = "SOURCE_DESC"
    type = "VARCHAR(16777216)"
  }
  column {
    name = "FULL_TEXT"
    type = "VARCHAR(16777216)"
  }
  column {
    name = "SIZE"
    type = "NUMBER(18,0)"
  }
  column {
    name = "CHUNK"
    type = "VARCHAR(16777216)"
  }
  column {
    name = "INPUT_TEXT"
    type = "VARCHAR(16777216)"
  }
  column {
    name = "CHUNK_EMBEDDING"
    type = "ARRAY"
  }
}

# Create Vector Store Table
resource "snowflake_table" "vector_store" {
  name     = "VECTOR_STORE"
  database = "DEMO_DB_V4"
  schema   = "DEMO_SCHEMA"
  column {
    name = "SOURCE"
    type = "VARCHAR(6)"
  }
  column {
    name = "SOURCE_DESC"
    type = "VARCHAR(16777216)"
  }
  column {
    name = "FULL_TEXT"
    type = "VARCHAR(16777216)"
  }
  column {
    name = "SIZE"
    type = "NUMBER(18,0)"
  }
  column {
    name = "CHUNK"
    type = "VARCHAR(16777216)"
  }
  column {
    name = "INPUT_TEXT"
    type = "VARCHAR(16777216)"
  }
  column {
    name = "CHUNK_EMBEDDING"
    type = "VECTOR(FLOAT, 768)"
  }
}








# Data Copy Commands (Run these manually or via an external process as Terraform does not handle data loading directly)
# COPY INTO TASTY_BYTES_CHATBOT.APP.DOCUMENTS FROM @TASTY_BYTES_CHATBOT.APP.S3LOAD/DOCUMENTS/
# COPY INTO TASTY_BYTES_CHATBOT.APP.ARRAY_TABLE FROM @TASTY_BYTES_CHATBOT.APP.S3LOAD/VECTOR_STORE/
# INSERT INTO TASTY_BYTES_CHATBOT.APP.VECTOR_STORE (SELECT ...) -- As per your SQL logic




