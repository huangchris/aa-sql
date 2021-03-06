require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || (name.to_s + "_id").to_sym
    @class_name = options[:class_name] || name.to_s.capitalize
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || (self_class_name.downcase + "_id").to_sym
    @class_name = options[:class_name] || name.to_s.capitalize[0...-1]
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      f_key = self.send(options.foreign_key)
      table = options.table_name
      p_key = options.primary_key

      options.model_class.where(p_key => f_key).first
    end
  end

  def has_many(name, options = {})
    # debugger
    options = HasManyOptions.new(name, self.to_s, options)
    assoc_options[name] = options
    define_method(name) do
      f_key = options.foreign_key
      table = options.table_name
      p_key = self.send(options.primary_key)

      options.model_class.where(f_key => p_key)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
