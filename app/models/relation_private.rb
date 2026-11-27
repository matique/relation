class Relation < ActiveRecord::Base
  def self.valid_model?(klass)
    klass.is_a?(Class) &&
      klass < ActiveRecord::Base &&
      klass.name.present? &&
      !klass.abstract_class? &&
      klass.primary_key.present?
  end

  def self.normalize_kind(kind)
    unless kind.is_a?(Class) || kind.is_a?(String) || kind.is_a?(Symbol)
      raise ArgumentError, "kind must be a model class, string or symbol"
    end

    klass = kind.is_a?(Class) ? kind : kind.to_s.safe_constantize

    unless valid_model?(klass)
      raise ArgumentError,
        "kind must be a named ActiveRecord model with a primary key"
    end

    klass
  end

  def self.normalize_name(name)
    unless name.is_a?(String) || name.is_a?(Symbol)
      raise ArgumentError, "model name must be a string or symbol"
    end

    name = name.to_s

    raise ArgumentError, "model name cannot be blank" if name.blank?

    name
  end

  def self.model_name_and_id(resource)
    raise ArgumentError, "missing resource" unless resource
    unless resource.is_a?(ActiveRecord::Base)
      raise ArgumentError, "resource must be an ActiveRecord model"
    end
    unless resource.persisted?
      raise ArgumentError, "resource must be persisted"
    end

    klass = resource.class
    unless valid_model?(klass)
      raise ArgumentError,
        "resource must be a named ActiveRecord model with a primary key"
    end

    [klass.polymorphic_name, resource.id]
  end

  def self.normalize(from, to)
    [*model_name_and_id(from), *model_name_and_id(to)]
  end

  def self.normalize_target(kind, row)
    [normalize_kind(kind), *model_name_and_id(row)]
  end

  def self.normalize_attrs(attrs)
    %i[from_id to_id].each do |key|
      if attrs.key?(key) && attrs[key].nil?
        raise ArgumentError, "#{key} cannot be nil"
      end
    end

    attrs.merge(
      from_name: normalize_name(attrs[:from_name]),
      to_name: normalize_name(attrs[:to_name])
    )
  end

  private_class_method :valid_model?, :model_name_and_id,
    :normalize, :normalize_target,
    :normalize_kind, :normalize_attrs, :normalize_name
end
