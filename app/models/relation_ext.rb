# extended Relation: extracts relation from rows
class Relation < ActiveRecord::Base

  def self.add(row_from, row_to)
    hsh = normalize(row_from, row_to)
    Relation.create!(hsh)  if Relation.where(hsh).first == nil
  end

  def self.delete(row_from, row_to)
    hsh = normalize(row_from, row_to)
    Relation.where(hsh).delete_all
  end

  def self.references(row, kind)
    klass, name, id_from = normalize2(kind, row)
    name = "#{name} #{klass.name}"
    ids = references_raw(name, id_from)
    klass.where(id: ids)
  end

  def self.followers(kind, row)
    klass, name, id_to = normalize2(kind, row)
    name = "#{klass.name} #{name}"
    ids = followers_raw(name, id_to)
    klass.where(id: ids)
  end

 private
  def self.name_id(resource)
    raise 'missing resource'  unless resource
    [resource.class.name, resource.id]
  end

  def self.normalize(row_from, row_to)
    name_from, id_from = name_id(row_from)
    name_to, id_to     = name_id(row_to)
    name = "#{name_from} #{name_to}"
    { name: name, x_id: id_from, y_id: id_to }
  end

  def self.normalize2(kind, row)
    klass = kind
    klass = kind.constantize  unless klass.kind_of?(Class)
    name, id = name_id(row)
    [klass, name, id]
  end

end
