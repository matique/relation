class Relation < ActiveRecord::Base
  self.primary_key = nil

  def self.add_raw(name, from_id, to_id)
    create_or_find_by!(name: name.to_s, from_id:, to_id:)
  end

  def self.delete_raw(name, from_id, to_id)
    hsh = {name: name, from_id:, to_id:}
    Relation.where(hsh).delete_all
  end

  def self.references_raw(name, from_id)
    Relation.where(name:, from_id:).pluck(:to_id)
  end

  def self.followers_raw(name, to_id)
    Relation.where(name:, to_id:).pluck(:from_id)
  end
end
