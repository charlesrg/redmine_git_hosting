module RedmineGitHosting
  module Patches
    module UserPatch
      unloadable

      def self.included(base)
        base.class_eval do
          # initialize association from user -> gitolite_public_keys
          has_many :gitolite_public_keys, :dependent => :destroy
        end
      end

    end
  end
end

unless User.included_modules.include?(RedmineGitHosting::Patches::UserPatch)
  User.send(:include, RedmineGitHosting::Patches::UserPatch)
end
