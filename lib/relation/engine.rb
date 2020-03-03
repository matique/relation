module ModRelation
  class Engine < Rails::Engine
    isolate_namespace ModRelation

    # # https://github.com/rails/rails/issues/22261
    #     initializer :append_migrations do |app|
    #       config.paths['db/migrate'].expanded.each do |path|
    #         app.config.paths['db/migrate'] << path
    #         ActiveRecord::Migrator.migrations_paths << path
    #       end
    #     end

    # # https://github.com/rails/rails/issues/22261
    # module ActiveRecord
    # #module ActiveRecord::Current
    #   class Schema < Migration
    #     def migrations_paths
    #       (ActiveRecord::Migrator.migrations_paths +
    #        Rails.application.paths['db/migrate'].to_a).uniq
    #     end
    #   end
    # end
  end
end
