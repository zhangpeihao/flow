require 'spec_helper'
require File.join(base_path, 'lib', 'workflow', 'adapters', 'issue_tracker', 'jira')

describe 'Flow::Workflow::Jira' do

  let!(:config)   do
    { 'user'                  => 'user',
      'pass'                  => 'pass',
      'url'                   => 'url',
      'min_unassigned_uats'   => 'min_uats',
      'transitions'           => { 'ready_uat'  => 1,
                                   'uat_nok'    => 2,
                                   'done'       => 3, }
    }
  end
  let!(:subject)  { Flow::Workflow::Jira.new(config) }

  describe '#do_move' do
    let!(:issue)          { 'xxx' }
    let!(:status_id)      { :ready_uat}
    let!(:status)         { 1 }
    let!(:json)           { "{\"transition\":{\"id\" : \"#{status}\"}}" }
    let!(:url)            { "url/rest/api/latest/issue/#{issue}/transitions\?expand\=transitions.fields\&transitionId\=#{status}" }
    let!(:curl_response)  { :success }
    before do
      subject.stub(:curl).with(config['user'], config['pass'], json, url).and_return(curl_response)
    end
    describe 'with a valid remote response' do
      it 'should return success' do
        subject.do_move(status_id, issue).should be(:success)
      end
    end
    describe 'with a non valid remote response' do
      let!(:curl_response)  { :fail }
      it 'should return fail' do
        subject.do_move(status_id, issue).should be(:fail)
      end
    end
    describe 'with a non valid provided status_id' do
      let!(:status_id)  { :supu }
      let!(:status)     { 'xxx' }
      it 'should return fail' do
        subject.do_move(status_id, issue).should be(:fail)
      end
    end
    describe 'with a non valid provided issue' do
      let!(:issue)  { nil }
      it 'should return fail' do
        subject.do_move(status_id, issue).should be(:fail)
      end
    end
  end

  describe '#issues_by_status' do
    let!(:status_name)  { 'status_name' }
    let!(:issue)        { { 'key' => 'a', 'fields' => { 'summary' => 'summary', 'assignee' => 'me' } } }
    before do
      url = "#{config['url']}/rest/api/latest/search?jql='status'='#{status_name}'"
      subject.stub(:do_request).with(url).and_return(jira_response)
    end
    describe 'for a valid response' do
      let!(:jira_response) { { 'issues' => [issue, issue, issue] } }
      it 'should return an array' do
        issues = subject.issues_by_status(status_name)
        issues.is_a?(Array).should be_true
        issues.length.should be 3
      end
    end
    describe 'for a valid and empty response' do
      let!(:jira_response) { { 'issues' => [] } }
      it 'should return an empty array' do
        issues = subject.issues_by_status(status_name)
        issues.is_a?(Array).should be_true
        issues.length.should be 0
      end
    end
    describe 'for an invalid response' do
      let!(:jira_response) { nil }
      it 'should return an empty array' do
        issues = subject.issues_by_status(status_name)
        issues.is_a?(Array).should be_true
        issues.length.should be 0
      end
    end
  end

  describe '#branch_to_id' do
    describe 'for a valid jira issue id' do
      it 'should return a valid jira issue_id' do
        subject.branch_to_id('xxx:RTF-54').should == 'RTF-54'
      end
      it 'should return a valid jira issue_id' do
        subject.branch_to_id('xxx:RTF-54_hola_que_hase').should == 'RTF-54'
      end
    end
  end

  describe '#unassigned_issues_by_status' do
    let!(:issues)   { [ issue, issue ] }
    let!(:issue)    { double('issue', assignee: assignee) }
    let!(:assignee) { nil }

    before do
      subject.stub(:issues_by_status).and_return issues
    end

    describe 'when no issues for the given status' do
      let!(:issues)   { [] }
      it 'none issues should be returned' do
        subject.unassigned_issues_by_status('supu').should eq issues
      end
    end

    describe 'when no unassigned issues for the given status' do
      let!(:assignee) { 'pedro' }
      it 'none issues should be returned' do
        subject.unassigned_issues_by_status('supu').should eq []
      end
    end

    describe 'when multiple unassigned issues for the given status' do
      it 'multiple issues should be returned' do
        subject.unassigned_issues_by_status('supu').should eq issues
      end
    end
  end

end