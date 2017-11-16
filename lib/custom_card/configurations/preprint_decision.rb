module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    class PreprintDecision < Base
      def self.name
        "Preprint Decision"
      end

      def self.view_role_names
        ["Staff Admin"]
      end

      def self.edit_role_names
        ["Staff Admin"]
      end

      def self.publish
        true
      end

      def self.do_not_create_in_production_environment
        false
      end
    end
  end
end
