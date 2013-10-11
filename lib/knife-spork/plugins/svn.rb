require 'knife-spork/plugins/plugin'

module KnifeSpork
  module Plugins
    class Svn < Plugin
      name :svn
      
      def perform; end
      
      def before_bump
        svn_update
      end
      
      def before_upload
        svn_commit
      end
      
      def before_promote
        
      end
      
      def after_bump
      end
      
      def after_promote_local
        
      end
      
      private
      def svn
        safe_require 'svn-command'
        log = Logger.new(STDOUT)
        log.level = Logger::WARN
        @svn ||= begin
          ::SVN.open('.',:log => log)
        rescue
          ui.error 'You are not currently in an svn repository. Please ensure you are in the correct subdirectory, or remove the svn plugin from you KnifeSpork Configuration!'
          exit(0)
        end
      end

      def svn_update
        ui.msg "Pulling latest changes from SVN Repository (if any)"
        output = IO.popen("svn update 2>&1")
        Process.wait
        exit_code = $?
        if !exit_code.exitstatus == 0
          ui.error "#{output.read()}\n"
          exit 1
        end
      end
      
      def svn_add(filepath,filename)
        ui.msg "SVN add'ing #{filepath} && svn add #{filename}"
        output = IO.popen("git add #{filename}")
        Process.wait
        exit_code = $?
        if !exit_code.exitstatus == 0
          ui.error "#{output.read()}\n"
          exit 1
        end
        
      end
      
      def svn_commit
        ui.msg "Committing to SVN..."
        output = IO.popen('svn commit --message "[KnifeSpork] Bumping Cookbooks:\n#{cookbooks.collect{|c| " #{c.name}@{c.version}"}.join("\n")}"')
        Process.wait
        exit_code = $?
        if !exit_code.exitstatus == 0
          ui.error "#{output.read()}\n"
          exit 1
        end
      end
        
    end
  end
end