class Relation < ActiveRecord::Base
  self.primary_key = nil

  # Object API

  # Adds a directed relationship from +from+ to +to+.
  def self.add(from, to)
    add_raw(*normalize(from, to))
  end

  def self.remove(from, to)
    remove_raw(*normalize(from, to))
  end

  # Returns records of +kind+ referenced by +row+.
  def self.references(row, kind)
    klass, from_name, from_id = normalize_target(kind, row)

    to_name = klass.polymorphic_name
    ids = where(from_name:, from_id:, to_name:).select(:to_id)

    klass.where(klass.primary_key => ids)
  end

  # Returns records of +kind+ that reference +row+.
  def self.followers(row, kind)
    klass, to_name, to_id = normalize_target(kind, row)

    from_name = klass.polymorphic_name
    ids = where(from_name:, to_name:, to_id:).select(:from_id)

    klass.where(klass.primary_key => ids)
  end

  # Raw API operates on polymorphic model names and record IDs.

  def self.add_raw(from_name, from_id, to_name, to_id)
    create_or_find_by!(
      normalize_attrs(from_name:, from_id:, to_name:, to_id:)
    )
  end

  def self.remove_raw(from_name, from_id, to_name, to_id)
    where(normalize_attrs(from_name:, from_id:, to_name:, to_id:)).delete_all
  end

  def self.references_raw(from_name, from_id, to_name)
    where(normalize_attrs(from_name:, from_id:, to_name:)).pluck(:to_id)
  end

  def self.followers_raw(from_name, to_name, to_id)
    where(normalize_attrs(from_name:, to_name:, to_id:)).pluck(:from_id)
  end
end
