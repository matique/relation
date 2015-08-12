class Relation < ActiveRecord::Base
  VERSION = '0.0.1'

  def self.add(row_from, row_to)
    name_from, id_from = name_id(row_from)
    name_to, id_to     = name_id(row_to)
    name = "#{name_from} #{name_to}"
    hsh = { name: name, x_id: id_from, y_id: id_to }

    Connection.create!(hsh)  if Connection.where(hsh).first == nil
  end

  def self.remove(row_from, row_to)
    name_from, id_from = name_id(row_from)
    name_to, id_to     = name_id(row_to)
    name = "#{name_from} #{name_to}"
    hsh = { name: name, x_id: id_from, y_id: id_to }
    Connection.where(hsh).delete_all
  end

  def self.ancestors_ids(row, klass)
    name_from, id_from = name_id(row)
    name = "#{name_from} #{klass.name}"
    Connection.where(name: name, x_id: id_from).pluck(:y_id)
  end

  def self.descendents_ids(row, klass)
    name_from, id_from = name_id(row)
    name = "#{klass.name} #{name_from}"
    Connection.where(name: name, y_id: id_from).pluck(:x_id)
  end

  def self.ancestors(row, klass)
    ids = self.ancestors_ids(row, klass)
    klass.where(id: ids)
  end

  def self.descendents(row, klass)
    ids = self.descendents_ids(row, klass)
    klass.where(id: ids)
  end

  def self.dangling
    names = Connection.pluck(:name).uniq
    models = []
    names.each { |name|
      models |= name.split(' ')
    }
    hsh = {}
    models.each { |class_name|
      klass = class_name.constantize
      ids = klass.pluck(:id)
      idx = Connection.where('name like ?', "#{class_name} %").pluck(:x_id)
      idy = Connection.where('name like ?', "% #{class_name}").pluck(:y_id)
      arr = (idx | idy) - ids
      hsh[class_name] = arr  if arr.length > 0
    }
    hsh
  end

  def self.remove_dangling(hsh)
    hsh.each { |name, arr|
      arr.each { |idx|
	Connection.where(x_id: idx).where('name like ?', "#{name} %").delete_all
	Connection.where(y_id: idx).where('name like ?', "% #{name}").delete_all
      }
    }
  end

 private
  def self.name_id(resource)
    raise 'missing resource'  unless resource
    [resource.class.name, resource.id]
  end
end
