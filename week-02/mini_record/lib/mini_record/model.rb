module MiniRecord

  class Model
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
  end
end

# class BlogPost < MiniRecord::Model
# end

# class User < MiniRecord::Model
# end

# me = User.new
# p User.name_underscore
# p User.name_underscore_plural

# blog = BlogPost.new
# p BlogPost.name_underscore
# p BlogPost.name_underscore_plural
