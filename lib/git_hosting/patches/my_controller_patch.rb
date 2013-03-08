module GitHosting
  module Patches
    module MyControllerPatch
      unloadable

      def self.included(base)
        base.class_eval do
          helper :gitolite_public_keys
        end
        base.send(:alias_method_chain, :account, :public_keys)
      end

      # Add in values for viewing public keys:
      def account_with_public_keys
        # Previous routine
        account_without_public_keys

        @gitolite_user_keys = @user.gitolite_public_keys.active.user_key.find(:all,:order => 'title ASC, created_at ASC')
        @gitolite_deploy_keys = @user.gitolite_public_keys.active.deploy_key.find(:all,:order => 'title ASC, created_at ASC')
        @gitolite_public_keys = @gitolite_user_keys + @gitolite_deploy_keys
        @gitolite_public_key = @gitolite_public_keys.detect{|x| x.id == params[:public_key_id].to_i}
        if @gitolite_public_key.nil?
          if params[:public_key_id]
            # public_key specified that doesn't belong to @user.  Kill off public_key_id and try again
            redirect_to :public_key_id => nil, :tab => nil
            return
          else
            @gitolite_public_key = GitolitePublicKey.new
          end
        end
      end

    end
  end
end

unless MyController.included_modules.include?(GitHosting::Patches::MyControllerPatch)
  MyController.send(:include, GitHosting::Patches::MyControllerPatch)
end
