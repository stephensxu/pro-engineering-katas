module MiniRecord

  class Model
    MiniRecord::Database.database = 'blog.db' # This line is here so that self.table_name= method knows which database to fetch data from

    def self.table_name=(table_name)
      info_array = MiniRecord::Database.execute("PRAGMA table_info(#{table_name.to_s})")
      @attribute_names = info_array.map { |item| item["name"] }.map{ |attr_name| attr_name.to_sym }
      @attribute_names.freeze
    end
    # Attribute names are at the class level since they're "schema" data
    def self.attribute_names
      @attribute_names
    end

    def self.attribute_names=(attribute_names)
      @attribute_names = attribute_names.map { |attr_name| attr_name.to_sym }
      @attribute_names.freeze
    end

    def self.attribute?(attr_name)
      attribute_names.include?(attr_name.to_sym)
    end

    # When we call attribute_names on an instance, just call the class method.
    # For example, @user.attribute_names will call User.attribute_names
    def attribute_names
      self.class.attribute_names
    end

    def attribute?(attr_name)
      self.class.attribute?(attr_name)
    end

    def self.name_underscore
      self.name.split(/(?=[A-Z])/).join("_").downcase
    end

    def self.name_underscore_plural
      self.name_underscore + "s"
    end

    def self.all
      MiniRecord::Database.execute("SELECT * FROM #{self.name_underscore_plural}").map do |row|
        self.new(row)
      end
    end

    def self.where(query, *args)
      MiniRecord::Database.execute("SELECT * FROM #{self.name_underscore_plural} WHERE #{query}", *args).map do |row|
        self.new(row)
      end
    end

    def self.find(pk)
      where('id = ?', pk).first
    end

    def self.create(attributes = {})
      self.new(attributes).tap do |user|
        user.save
      end
    end

    def initialize(attributes = {})
      attributes.symbolize_keys!
      attributes.assert_valid_keys(self.attribute_names)

      @attributes = {}
      self.attribute_names.each do |attr_name|
        @attributes[attr_name] = attributes[attr_name]
      end
    end

    def new_record?
      read_attribute(:id).nil?
    end

    def save
      if new_record?
        insert_record!
      else
        update_record!
      end
    end

    def read_attribute(attr_name)
      @attributes[attr_name]
    end
    alias_method :[], :read_attribute

    def write_attribute(attr_name, value)
      attr_name = attr_name.to_sym

      if attribute?(attr_name)
        @attributes[attr_name] = value
      else
        fail MiniRecord::MissingAttributeError, "can't write unknown attribute '#{attr_name}'"
      end
    end
    alias_method :[]=, :write_attribute

    private

    def insert_record!
      now = DateTime.now

      write_attribute(:created_at, now) if attribute?(:created_at)
      write_attribute(:updated_at, now) if attribute?(:updated_at)

      values = @attributes.values

      MiniRecord::Database.execute(insert_sql, *values).tap do
        write_attribute(:id, MiniRecord::Database.last_insert_row_id)
      end

      true
    end

    def update_record!
      write_attribute(:updated_at, DataTime.now) if attribute?(:updated_at)

      values = @attributes.values
      MiniRecord::Database.execute(update_sql, *values, read_attribute(:id))

      true
    end

    def insert_sql
      columns = @attributes.keys

      placeholders = Array.new(columns.length, '?').join(',')

      "INSERT INTO #{self.class.name_underscore_plural} (#{columns.join(',')}) VALUES (#{placeholders})"
    end

    def update_sql
      columns = @attributes.keys

      set_clause = columns.map{ |col| "#{col} = ?" }.join(',')

      "UPDATE #{self.class.name_underscore_plural} SET #{set_clause} WHERE id = ?"
    end
  end
end
