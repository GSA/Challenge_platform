# frozen_string_literal: true

module DashboardHelper
  def dashboard_cards_by_role
    {
      challenge_manager: [
        { image_path: 'emoji_events', href: 'http://localhost:4000/', alt: 'challenges', title: 'Challenges',
          subtitle: 'Create and manage challenges.' },
        { image_path: 'folder_open', href: 'manage_submissions', alt: 'submissions', title: 'Submissions',
          subtitle: 'Manage submissions, evaluations, and evaluators.' },
        { image_path: 'content_copy', href: 'evaluation_forms', alt: 'evaluation forms', title: 'Evaluation Forms',
          subtitle: 'Create and manage evaluation forms.' },
        { image_path: 'map', href: 'user_guide', alt: 'user guides', title: 'User Guides',
          subtitle: 'Learn how to make the most of the platform.' },
        { image_path: 'support_agent', href: 'federal-agency-faqs', alt: 'help', title: 'Help',
          subtitle: 'Get support on the Challenge.Gov platform.' }
      ],
      solver: [],
      evaluator: []
    }
  end

  def dashboard_title
    {
      challenge_manager: "Challenge Manager Evaluation Dashboard"
    }
  end
end
