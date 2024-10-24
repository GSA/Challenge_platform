# frozen_string_literal: true

module DashboardHelper
  def dashboard_cards_by_role
    {
      challenge_manager: [
        { image_path: 'emoji_events', href: Rails.configuration.phx_interop[:phx_uri],
          alt: 'challenges', title: 'Challenges', subtitle: 'Create and manage challenges.' },
        { image_path: 'star_half', href: 'manage_submissions',
          alt: 'submissions and evaluations', title: 'Submissions & Evaluations', subtitle:
           'Manage submissions, evaluations, and evaluators.' },
        { image_path: 'check_circle_outline', href: 'evaluation_forms',
          alt: 'evaluation forms', title: 'Evaluation Forms', subtitle: 'Create and manage evaluation forms.' },
        { image_path: 'mail', href: "#{Rails.configuration.phx_interop[:phx_uri]}/messages",
          alt: 'help', title: 'Message Center', subtitle: 'View and send messages to Challenge.gov users.' },
        { image_path: 'assessment', href: "#{Rails.configuration.phx_interop[:phx_uri]}/analytics",
          alt: 'help', title: 'Analytics', subtitle: 'View web analytics data related to your challenges.' },
        { image_path: 'support', href: 'https://www.challenge.gov/cm-user-guide/',
          alt: 'resources', title: 'Resources', subtitle: 'Learn how to make the most of the platform.' }
      ],
      evaluator: [
        { image_path: 'star_half', href: 'evaluations',
          alt: 'submissions and evaluations', title: 'Submissions & Evaluations',
          subtitle: 'View submissions assigned to me and provide evaluations.' },
        { image_path: 'support', href: 'https://www.challenge.gov/cm-user-guide/',
          alt: 'resources', title: 'Resources', subtitle: 'Learn how to make the most of the platform.' }
      ],
      solver: []
    }
  end

  def dashboard_title
    {
      challenge_manager: "Challenge Manager Evaluation Dashboard",
      evaluator: "Evaluator Dashboard"
    }
  end
end
