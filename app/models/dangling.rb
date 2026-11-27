class Relation < ActiveRecord::Base
  # Returns missing record IDs grouped by polymorphic model name.
  def self.dangling
    names = distinct.pluck(:from_name, :to_name).flatten.uniq

    names.each_with_object({}) do |name, result|
      klass = name.safe_constantize

      next unless valid_model?(klass)

      primary_key = klass.primary_key

      from_ids = where(from_name: name)
        .where.not(from_id: klass.select(primary_key))
        .distinct
        .pluck(:from_id)

      to_ids = where(to_name: name)
        .where.not(to_id: klass.select(primary_key))
        .distinct
        .pluck(:to_id)

      ids = from_ids | to_ids

      result[name] = ids if ids.any?
    end
  end

  def self.remove_dangling(dangling)
    raise ArgumentError, "expected a Hash" unless dangling.is_a?(Hash)

    transaction do
      dangling.each do |name, ids|
        name = normalize_name(name)

        raise ArgumentError, "IDs must be an Array" unless ids.is_a?(Array)

        ids = ids.uniq
        next if ids.empty?

        where(from_name: name, from_id: ids).delete_all
        where(to_name: name, to_id: ids).delete_all
      end
    end
  end
end
