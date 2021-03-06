require File.join(File.dirname(__FILE__), '..', 'adapter')

module Flow
  module Workflow
    class SourceControl < Flow::Workflow::Adapter

      def add_comment(repo, number, body)
      end

      def statuses(repo, sha)
      end

      def merge_pull_request(repo, number, body)
      end

      def delete_ref(repo, ref)
      end

      def create_issue(name, title, body, options)
      end

      def pull_requests(name)
      end

      def issues(name)
      end

      def delete_branch(repo, branch)
      end

      def comment!(repo, number, body)
      end

      def pull_request(repo_name, pull_request_number)
      end

      def pull_request_from_request(request)
      end

      def comment_from_request(request)
      end

      def request_status_success?(request)
      end

      def request_status_error?(request)
      end

      def request_status_failed?(request)
      end

      def dependent_repos
      end

      def update_dependent(where, submodule_path, branch, project_name)
      end

      def pull_request_object_from_pull_request(request)
      end
    end
  end
end