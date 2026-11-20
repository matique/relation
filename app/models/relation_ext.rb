require "ricecream"

class Relation < ActiveRecord::Base
  self.primary_key = nil

  # Object-based relations

  def self.add(row_from, row_to)
    create_or_find_by!(normalize(row_from, row_to))
  end

  def self.delete_connection(row_from, row_to)
    where(normalize(row_from, row_to)).delete_all
  end

  def self.references(row, kind)
    klass, name, from_id = normalize2(kind, row)
    ids = where(name: "#{name} #{klass.name}", from_id:).select(:to_id)

    klass.where(id: ids)
  end

  def self.followers(kind, row)
    klass, name, to_id = normalize2(kind, row)
    ids = where(name: "#{klass.name} #{name}", to_id:).select(:from_id)

    klass.where(id: ids)
  end

  # Normalization

  def self.name_id(resource)
    raise ArgumentError, "missing resource" unless resource

    unless resource.is_a?(ActiveRecord::Base)
      raise ArgumentError, "resource must be an ActiveRecord model"
    end

    unless resource.persisted?
      raise ArgumentError, "resource must be persisted"
    end

    unless resource.class.name.present?
      raise ArgumentError, "resource must have a named model class"
    end

    [resource.class.name, resource.id]
  end

  def self.normalize(row_from, row_to)
    name_from, from_id = name_id(row_from)
    name_to, to_id = name_id(row_to)

    name = "#{name_from} #{name_to}"
    {name: name, from_id: from_id, to_id: to_id}
  end

  def self.normalize2(kind, row)
    klass = kind.is_a?(Class) ? kind : kind.to_s.constantize

    unless klass < ActiveRecord::Base
      raise ArgumentError, "kind must be an ActiveRecord model"
    end

    name, id = name_id(row)
    [klass, name, id]
  end
end
