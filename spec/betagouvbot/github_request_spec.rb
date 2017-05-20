# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::GithubRequest do
  subject(:actions) { described_class.(members, Date.today) }

  let(:yesterday)   { Date.today - 1 }
  let(:tomorrow)    { Date.today + 1 }

  let(:ann)         { { id: 'ann', github: 'ann-gh', end: yesterday.iso8601 } }
  let(:bob)         { { id: 'bob', github: 'bob-gh', end: tomorrow.iso8601 } }
  let(:ted)         { { id: 'ted', fullname: 'Ted', end: tomorrow.iso8601 } }
  let(:members)     { [bob, ann, ted] }

  it 'ensures all active members are invited to Github org SGMAP' do
    is_expected.to have(1).items.and include(
      be_a_kind_of(BetaGouvBot::GithubOrgAction)
        .and(have_attributes(user: 'bob-gh', org: 'sgmap', team: '2348627'))
    )
  end
end
