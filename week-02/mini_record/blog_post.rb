class BlogPost < MiniRecord::Model
  self.attribute_names = [:id, :user_id, :title, :content, :created_at, :updated_at]

  def user
    User.find(self[:user_id])
  end

  def user=(user)
    self[:user_id] = user[:id]
    self.save
    user
  end

  def save
    if new_record?
      inser_record!
    else
      update_record!
    end
  end

  # def read_attribute(attr_name)
  #   @attributes[attr_name]
  # end
  # alias_method :[], :read_attribute

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

  def inser_record!
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

    "INSERT INTO blog_posts (#{columns.join(',')}) VALUES (#{placeholders})"
  end

  def update_sql
    columns = @attributes.keys

    set_clause = columns.map { |col| "#{col} = ?" }.join(',')

    "UPDATE blog_posts SET #{set_clause} WHERE id = ?"
  end
end
