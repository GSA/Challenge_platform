module ChallengesHelper
  def challenge_slug(challenge)
    challenge.custom_url || challenge.id
  end

  # Returns the URL for the challenge logo.
  # If the challenge has a logo uploaded by the Challenge Manager, it returns the URL for that logo.
  # Otherwise, it returns the URL logo of the Challenge agency.
  #
  # @param [Challenge] challenge The challenge object.
  # @return [String] The URL for the challenge logo.
  def challenge_logo_url(challenge)
    return agency_logo_url(challenge) if challenge.logo_key.nil?

    Storage.url(challenge_logo_path(challenge, "original"))
  end

  def agency_logo_url(challenge)
    if (challenge.sub_agency && challenge.sub_agency.avatar_key)
      Storage.url(agency_avatar_path(challenge.sub_agency, "original"))
    elsif (challenge.agency && challenge.agency.avatar_key)
      Storage.url(agency_avatar_path(challenge.agency, "original"))
    else
      # Fallback to Challenge.gov logo if no agency logo is found
      image_path("challenge-logo.svg")
    end
  end

  def agency_avatar_path(agency, size="original")
    "agencies/#{size}-#{agency.avatar_key}#{agency.avatar_extension}"
  end

  def challenge_logo_path(challenge, size="original")
    "challenges/#{size}-#{challenge.logo_key}#{challenge.logo_extension}"
  end
end
