class Relation < ActiveRecord::Base
  def self.dangling
    names = pluck(:name).uniq
    models = []
    names.each { |name| models |= name.split(" ") }
    hsh = {}
    models.each do |class_name|
      klass = class_name.constantize
      pattern = name_pattern(class_name, :from)
      idx = where("name LIKE ?", pattern)
              .where.not(from_id: klass.select(:id))
              .pluck(:from_id)
      pattern = name_pattern(class_name, :to)
      idy = where("name LIKE ?", pattern)
              .where.not(to_id: klass.select(:id))
              .pluck(:to_id)
      arr = idx | idy
      hsh[class_name] = arr if arr.length.positive?
    end
    hsh
  end

  def self.remove_dangling(hsh)
    hsh.each do |name, ids|
      ids = ids.uniq
      next if ids.empty?

      from_pattern = name_pattern(name, :from)
      to_pattern = name_pattern(name, :to)

      transaction do
        where(from_id: ids).where("name LIKE ?", from_pattern).delete_all
        where(to_id: ids).where("name LIKE ?", to_pattern).delete_all
      end
    end
  end

  def self.name_pattern(name, position)
    escaped = ActiveRecord::Base.sanitize_sql_like(name)

    case position
    when :from then "#{escaped} %"
    when :to then "% #{escaped}"
    else
      raise ArgumentError, "invalid position: #{position}"
    end
  end
end
