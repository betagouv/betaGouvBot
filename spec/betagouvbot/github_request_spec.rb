# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::GithubRequest do
  let(:yesterday)     { Date.today - 1 }
  let(:tomorrow)      { Date.today + 1 }

  let(:ann)     { { id: 'ann', github: 'ann-gh', end: yesterday.iso8601 } }
  let(:bob)     { { id: 'bob', github: 'bob-gh', end: tomorrow.iso8601 } }
  let(:members) { [bob, ann] }

  it 'ensures all active members are invited to Github org SGMAP' do
    actions = described_class.(members, Date.today)
    expect(actions).to have(1).items
    matching = be_a_kind_of(BetaGouvBot::OrganizationAction)
               .and have_attributes(user: 'bob-gh')
               .and have_attributes(org: 'sgmap')
               .and have_attributes(team: '2348627')
    expect(actions).to include(matching)
  end
end
