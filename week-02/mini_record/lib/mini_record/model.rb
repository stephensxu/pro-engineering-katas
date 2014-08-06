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
  end

end
