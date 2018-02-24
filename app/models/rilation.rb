class Rilation < ActiveRecord::Base
  set_table_name 'relation'

  def self.add(row_from, row_to)
    name_from, id_from = name_id(row_from)
    name_to, id_to     = name_id(row_to)
    name = "#{name_from} #{name_to}"
    hsh = { name: name, x_id: id_from, y_id: id_to }

    Relation.create!(hsh)  if Relation.where(hsh).first == nil
  end

  def self.delete(row_from, row_to)
    name_from, id_from = name_id(row_from)
    name_to, id_to     = name_id(row_to)
    name = "#{name_from} #{name_to}"
    hsh = { name: name, x_id: id_from, y_id: id_to }
    Relation.where(hsh).delete_all
  end

  def self.references(row, kind)
    klass = kind
    klass = kind.constantize  unless klass.kind_of?(Class)
    ids = self.references_ids(row, klass)
    klass.where(id: ids)
  end

  def self.followers(kind, row)
    klass = kind
    klass = kind.constantize  unless klass.kind_of?(Class)
    ids = self.followers_ids(klass, row)
    klass.where(id: ids)
  end

  def self.dangling
    names = Relation.pluck(:name).uniq
    models = []
    names.each { |name|
      models |= name.split(' ')
    }
    hsh = {}
    models.each { |class_name|
      klass = class_name.constantize
      ids = klass.pluck(:id)
      idx = Relation.where('name like ?', "#{class_name} %").pluck(:x_id)
      idy = Relation.where('name like ?', "% #{class_name}").pluck(:y_id)
      arr = (idx | idy) - ids
      hsh[class_name] = arr  if arr.length > 0
    }
    hsh
  end

  def self.remove_dangling(hsh)
    hsh.each { |name, arr|
      arr.each { |idx|
	Relation.where(x_id: idx).where('name like ?', "#{name} %").delete_all
	Relation.where(y_id: idx).where('name like ?', "% #{name}").delete_all
      }
    }
  end

 private
  def self.name_id(resource)
    raise 'missing resource'  unless resource
    [resource.class.name, resource.id]
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
