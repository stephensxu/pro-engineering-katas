# This adds './lib' to our require path so we can type
# require 'mini_record/errors' to include './lib/mini_record/errors'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'                  # For Date, DateTime, etc.
require 'ext/hash'              # For Hash#symbolize_keys, etc.
require 'sqlite3'               # For SQLite3

module MiniRecord
  VERSION = '0.1.0'
end

require 'mini_record/errors'    # Various error classes for MiniRecord
require 'mini_record/database'  # The MiniRecord::Database class
require 'mini_record/model'     # The MiniRecord::Model class
