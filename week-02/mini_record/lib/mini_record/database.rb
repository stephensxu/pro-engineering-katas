module MiniRecord

  class Database
    def self.connection
      fail NoConnectionError, "Call MiniRecord::Database.database= to set database." unless connected?

      @connection
    end

    def self.connected?
      @connection.is_a?(SQLite3::Database)
    end

    def self.filename
      @filename
    end

    # See http://rubydoc.info/github/sparklemotion/sqlite3-ruby/master/SQLite3/Database:last_insert_row_id
    def self.last_insert_row_id
      connection.last_insert_row_id
    end

    def self.database=(filename)
      @filename = filename.to_s

      @connection = SQLite3::Database.new(@filename)
      @connection.type_translation = true
      @connection.results_as_hash = true

      @filename
    end

    def self.execute(query, *args)
      connection.execute(query, prepare_values!(*args))
    end

    # The SQLite3 gem doesn't know how to handle Time, Date, and DateTime
    # objects, so we have to convert them to Strings beforehand.
    def self.prepare_values!(*values)
      values.map do |value|
        case value
        when Time, Date, DateTime
          value.to_s
        else
          value
        end
      end
    end

    private_class_method :prepare_values!
  end

end
