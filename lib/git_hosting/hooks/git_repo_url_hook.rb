module GitHosting
  module Hooks
    class GitRepoUrlHook < Redmine::Hook::ViewListener
      render_on :view_repositories_show_contextual, :partial => 'git_urls'
    end
  end
end
