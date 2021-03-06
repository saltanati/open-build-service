require 'rails_helper'

RSpec.describe Statistics::MaintenanceStatistic do
  describe '.find_by_project' do
    context 'with a review assigned by a user' do
      include_context 'a project with maintenance statistics'

      subject(:maintenance_statistics) { Statistics::MaintenanceStatistic.find_by_project(project) }

      it 'contains issue_created' do
        expect(maintenance_statistics[-7].type).to eq(:issue_created)
        expect(maintenance_statistics[-7].when).to eq(issue.created_at)
      end

      it 'contains review_declined' do
        expect(maintenance_statistics[-6].type).to eq(:review_declined)
        expect(maintenance_statistics[-6].when).to eq(history_element_review_declined.created_at)
      end

      it 'contains review_opened' do
        expect(maintenance_statistics[-5].type).to eq(:review_opened)
        expect(maintenance_statistics[-5].when).to eq(review.created_at)
      end

      it 'contains release_request_request_accepted' do
        expect(maintenance_statistics[-4].type).to eq('release_request_request_accepted')
        expect(maintenance_statistics[-4].when).to eq(history_element_request_accepted.created_at)
      end

      it 'contains release_request_request_created' do
        expect(maintenance_statistics[-3].type).to eq('release_request_request_created')
        expect(maintenance_statistics[-3].when).to eq(history_element_request_created.created_at)
      end

      it 'contains release_request_created' do
        expect(maintenance_statistics[-2].type).to eq(:release_request_created)
        expect(maintenance_statistics[-2].when).to eq(bs_request.created_at)
      end

      it 'contains project_created' do
        expect(maintenance_statistics[-1].type).to eq(:project_created)
        expect(maintenance_statistics[-1].when).to eq(project.created_at)
      end
    end

    context 'with a review by a group assigned to a user' do
      let!(:user) { create(:confirmed_user) }
      let!(:group) { create(:group) }

      let!(:project) do
        create(
          :project_with_repository,
          name: 'ProjectWithRepo',
          created_at: 10.days.ago
        )
      end
      let!(:bs_request) do
        create(
          :bs_request,
          source_project: project,
          type: 'maintenance_release',
          creator: user.login,
          created_at: 9.days.ago
        )
      end
      let!(:review) do
        create(
          :review,
          bs_request: bs_request,
          by_group: group.title,
          created_at: 6.days.ago,
          state: :accepted
        )
      end

      before do
        login(user)
        bs_request.assignreview({ by_group: group.title, reviewer: user.login })
        new_review = Review.last
        create(
          :history_element_review_accepted,
          review: new_review,
          user: user,
          created_at: Faker::Time.forward(2)
        )
        new_review.state = :accepted
        new_review.save!
      end

      subject(:maintenance_statistics) { Statistics::MaintenanceStatistic.find_by_project(project) }

      it 'contains review_accepted for the review assigned to the user' do
        new_review = Review.last
        expect(maintenance_statistics[-4].type).to eq(:review_accepted)
        expect(maintenance_statistics[-4].when).to eq(new_review.accepted_at)
        expect(maintenance_statistics[-4].who).to eq(group.title)
      end

      it 'contains review_opened for the original review assigned to the group' do
        expect(maintenance_statistics[-3].type).to eq(:review_opened)
        expect(maintenance_statistics[-3].when).to eq(review.created_at)
        expect(maintenance_statistics[-3].who).to eq(group.title)
      end

      it 'contains release_request_created' do
        expect(maintenance_statistics[-2].type).to eq(:release_request_created)
        expect(maintenance_statistics[-2].when).to eq(bs_request.created_at)
      end

      it 'contains project_created' do
        expect(maintenance_statistics[-1].type).to eq(:project_created)
        expect(maintenance_statistics[-1].when).to eq(project.created_at)
      end
    end
  end
end
