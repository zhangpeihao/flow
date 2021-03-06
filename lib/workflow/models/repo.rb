require File.join(File.dirname(__FILE__), '..', '..', 'config')

module Flow
  module Workflow
    class Repo
      attr_accessor :scm, :name

      def initialize(repo_name)
        @name = repo_name
      end

      def pull_requests
        pulls
      end

      def pull_request_by_name(name)
        pulls.find { |pull| pull.issue_tracker_id.to_s == name }
      end

      def pull_request_by_name_closed(name)
        closed_pulls.find { |pull| pull.issue_tracker_id.to_s == name }
      end
      
      def issue_exists(issue_name)
        issues.any? { |issue| issue.title.include? issue_name }
      end

      def issue!(title, body = '', options = {})
        return if issue_exists(title)
        scm.create_issue(@name, title, body, options)
      end

      def related_repos
        scm.related_repos
      end

      def dependent_repos
        scm.dependent_repos
      end

      def update_dependent(where,submodule_path, branch)
        scm.update_dependent(where, submodule_path,branch, project_name)
      end

      def create_pull_request(where, submodule_path, branch, comment)
        scm.create_pull_request(where,submodule_path,branch,comment, project_name)
      end

      def clone_into(path)
          scm.clone_project_into(repo_url, path, project_name)
      end


      protected

      def project_name
        name.split('/').last
      end


      def repo_url
        'git@github.com:'+name+'.git'
      end

      def pulls
        @__pull_requests__ ||= scm.pull_requests self
      end

      def closed_pulls
        @__closed_pull_requests__ ||= scm.closed_pull_requests self
      end

      def issues
        @__issues__ ||= scm.issues @name
      end

      def scm
        @__client__ ||= Flow::Workflow::Factory.instance(@name, :source_control)
      end
    end
  end
end
