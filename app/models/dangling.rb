# extended Relation: extracts relation from rows
class Relation < ActiveRecord::Base

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

end
