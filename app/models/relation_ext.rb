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
    ref_foll(row, kind) { |klass, row|
      references_ids(row, klass)
    }
  end

  def self.followers(kind, row)
    ref_foll(row, kind) { |klass, row|
      followers_ids(klass, row)
    }
  end

 private
  def self.ref_foll(row, kind, &proc)
    klass = kind
    klass = kind.constantize  unless klass.kind_of?(Class)
    ids = proc.call(klass, row)
    klass.where(id: ids)
  end

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


  def self.references_ids(row, klass)
    name_from, id_from = name_id(row)
    name = "#{name_from} #{klass.name}"
    Relation.where(name: name, x_id: id_from).pluck(:y_id)
  end

  def self.followers_ids(klass, row)
    name_to, id_to = name_id(row)
    name = "#{klass.name} #{name_to}"
    Relation.where(name: name, y_id: id_to).pluck(:x_id)
  end
end
