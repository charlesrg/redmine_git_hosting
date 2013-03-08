module GitHosting
  module Patches
    module GitRepositoryPatch
      unloadable

      def self.included(base)
        base.class_eval do
          before_validation :set_git_urls
        end

        begin
          base.send(:alias_method_chain, :report_last_commit, :always_true)
          base.send(:alias_method_chain, :extra_report_last_commit, :always_true)
          base.send(:alias_method_chain, :fetch_changesets, :disable_update)
        rescue
        end
      end

      # Set up git urls for new repositories
      def set_git_urls
        self.url = GitHosting.repository_path(self) if url.blank?
        self.root_url = url if root_url.blank?
      end

      def report_last_commit_with_always_true
        true
      end

      def extra_report_last_commit_with_always_true
        true
      end

      def fetch_changesets_with_disable_update
        # Turn of updates during repository update
        GitHostingObserver.set_update_active(false);

        # Do actual update
        fetch_changesets_without_disable_update

        # Reenable updates to perform a single update
        GitHostingObserver.set_update_active(true);
      end

    end
  end
end

unless Repository.included_modules.include?(GitHosting::Patches::GitRepositoryPatch)
  Repository::Git.send(:include, GitHosting::Patches::GitRepositoryPatch)
end
