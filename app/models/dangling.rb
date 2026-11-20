require "ricecream"

class Relation < ActiveRecord::Base
  # dangling relations
  def self.dangling
    names = Relation.pluck(:name).uniq
    models = []
    names.each { |name| models |= name.split(" ") }
    hsh = {}
    models.each do |class_name|
      klass = class_name.constantize
if nil
      ids = klass.pluck(:id)
      idx = Relation.where("name like ?", "#{class_name} %").pluck(:from_id)
      idy = Relation.where("name like ?", "% #{class_name}").pluck(:to_id)
      arr = (idx | idy) - ids
#ic arr, idx, idy, ids
else
#ic "#{class_name} %"
      pattern = "#{ActiveRecord::Base.sanitize_sql_like(class_name)} %"
      idx = Relation.where("name LIKE ?", pattern)
              .where.not(from_id: klass.select(:id))
              .pluck(:from_id)
      pattern = "% #{ActiveRecord::Base.sanitize_sql_like(class_name)}"
      idy = Relation.where("name LIKE ?", pattern)
              .where.not(to_id: klass.select(:id))
              .pluck(:to_id)
      arr = idx | idy
#ic arr, idx, idy
end
      hsh[class_name] = arr if arr.length.positive?
    end
    hsh
  end

  def self.remove_dangling(hsh)
    hsh.each do |name, arr|
      arr.each do |idx|
if true
#if nil
        Relation.where(from_id: idx).where("name like ?", "#{name} %").delete_all
        Relation.where(to_id: idx).where("name like ?", "% #{name}").delete_all
else
  next if ids.empty?

  transaction do
    where(from_id: ids)
      .where("name LIKE ?", "#{name} %")
      .delete_all

    where(to_id: ids)
      .where("name LIKE ?", "% #{name}")
      .delete_all
  end
end
      end
    end
  end
end
