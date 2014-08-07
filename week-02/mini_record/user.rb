class User < MiniRecord::Model
  self.attribute_names = [:id, :first_name, :last_name, :email, :birth_date, :created_at, :updated_at]

  def self.find(pk)
    where('id = ?', pk).first
  end

  def self.create(attributes = {})
    # See http://ruby-doc.org/core-2.1.2/Object.html#method-i-tap
    User.new(attributes).tap do |user|
      user.save
    end
  end

  def initialize(attributes = {})
    # See lib/mini_record/ext/hash.rb for how these methods are defined.
    attributes.symbolize_keys!
    attributes.assert_valid_keys(User.attribute_names)

    @attributes = {}

    User.attribute_names.each do |attr_name|
      @attributes[attr_name] = attributes[attr_name]
    end
  end

  def blog_posts
    BlogPost.where('user_id = ?', self[:id])
  end

  # e.g.,
  #   user.create_blog_post(title: 'My Post', content: 'Best blog post ever!')
  def create_blog_post(attributes = {})
    attributes[:user_id] = self[:id]
    BlogPost.create(attributes)
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
      fail MiniRecord::MissingAttributeError, "can't write unknown attribute `#{attr_name}'"
    end
  end
  alias_method :[]=, :write_attribute

  private

  def insert_record!
    now = DateTime.now

    write_attribute(:created_at, now) if attribute?(:created_at)
    write_attribute(:updated_at, now) if attribute?(:updated_at)

    values  = @attributes.values

    MiniRecord::Database.execute(insert_sql, *values).tap do
      # We don't have a value for id until we insert the database, so fetch
      # the last insert ID after a successful insert and update our Ruby model.
      write_attribute(:id, MiniRecord::Database.last_insert_row_id)
    end

    true
  end

  def update_record!
    write_attribute(:updated_at, DateTime.now) if attribute?(:updated_at)

    values  = @attributes.values
    MiniRecord::Database.execute(update_sql, *values, read_attribute(:id))

    true
  end

  def insert_sql
    columns = @attributes.keys

    placeholders  = Array.new(columns.length, '?').join(',')

    "INSERT INTO users (#{columns.join(',')}) VALUES (#{placeholders})"
  end

  def update_sql
    columns = @attributes.keys

    set_clause = columns.map { |col| "#{col} = ?" }.join(',')

    "UPDATE users SET #{set_clause} WHERE id = ?"
  end
end
