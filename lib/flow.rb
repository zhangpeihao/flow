require 'rubygems'
require 'thor'

require File.join(File.dirname(__FILE__), 'config')
require File.join(File.dirname(__FILE__), 'workflow/jenkins')
require File.join(File.dirname(__FILE__), 'workflow/workflow')
require File.join(File.dirname(__FILE__), 'workflow/jira')
require File.join(File.dirname(__FILE__), 'workflow/notifier')

def current_path
  @current_path ||= File.expand_path(File.dirname(__FILE__) + '/..')
end

class Kod < Thor
  include Thor::Actions

  desc 'flow', <<E
KodiFlow:
To be executed periodically, this will apply kodiflow over the given repository.

kod flow <repo_name>

E
  def flow(repo)
    workflow = Flow::Workflow::Workflow.new self
    workflow.flow repo
  end

  desc 'can_deploy', 'Notify kodify room if deploy is available or not'
  def can_deploy(repo, branch = 'master')
    jenkins = Flow::Workflow::Jenkins.new
    if jenkins.is_green?(repo, branch)
      notifier.say_green_balls
    end
  end

  desc 'uat_checker', 'Alert of unassigned uat message'
  def uat_checker
    issues = Flow::Workflow::Jira.new.issues_by_status('UAT')
    issues_unassigned_on_uat = []
    html_message = ""
    issue_url = config['jira']['url'] + config['jira']['issue_path']

    issues.each do |issue|
      if issue['fields']['assignee'].nil?
        html_message += "<br /> <a href='#{issue_url}#{issue['key']}'>#{issue['key']}</a> -  #{issue['fields']['summary']}"
        issues_unassigned_on_uat << issue['fields']['assignee']
      end
    end

    if issues_unassigned_on_uat.length >= config['jira']['min_unassigned_uats']
      html_message = "There are #{issues_unassigned_on_uat.length} PR ready to be uated in #{@repo_name} repo: #{html_message}"
      notifier.room = config['hipchat']['uat_room']
      notifier.say html_message, :notify => true, :message_format => 'html'
    end
  end

  protected

  def notifier
    @__notifier__ ||= Flow::Workflow::Notifier.new self
  end

  def config
    @__config__ ||= Flow::Config.get
  end

end

Kod.start
