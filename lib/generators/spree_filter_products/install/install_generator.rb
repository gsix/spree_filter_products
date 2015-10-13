module SpreeFilterProducts
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      class_option :auto_run_migrations, type: :boolean, default: false

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/frontend/all.js', "\n//= require spree/frontend/spree_filter_products\n"
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "\n//= require spree/backend/spree_filter_products\n"
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_filter_products'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end

      def copy_initializer
        copy_file 'spree_filter_init.rb', 'config/initializers/spree_filter_init.rb'
      end
    end
  end
end
