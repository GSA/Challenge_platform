# spec/helpers/challenge_helper_spec.rb

require 'rails_helper'

RSpec.describe ChallengeHelper, type: :helper do
  let(:challenge) { create(:challenge) }

  describe '#types_text' do
    context 'when challenge has multiple types' do
      before do
        allow(challenge).to receive(:types).and_return(['Type 1', 'Type 2'])
        allow(challenge).to receive(:primary_type).and_return('Primary Type')
      end

      it 'returns combined types string' do
        expect(helper.types_text(challenge)).to eq('Primary Type; Type 1; Type 2')
      end
    end

    context 'when challenge has only primary type' do
      before do
        allow(challenge).to receive(:types).and_return([])
        allow(challenge).to receive(:primary_type).and_return('Primary Type')
      end

      it 'returns only primary type' do
        expect(helper.types_text(challenge)).to eq('Primary Type')
      end
    end
  end

  describe '#follow_button_text' do
    context 'when challenge has subscribers' do
      before { allow(challenge).to receive(:gov_delivery_subscribers).and_return(5) }

      it 'returns text with subscriber count' do
        expect(helper.follow_button_text(challenge)).to eq('Follow challenge (5)')
      end
    end

    context 'when challenge has no subscribers' do
      before { allow(challenge).to receive(:gov_delivery_subscribers).and_return(0) }

      it 'returns basic text' do
        expect(helper.follow_button_text(challenge)).to eq('Follow challenge')
      end
    end
  end

  describe '#show_monetary_prizes?' do
    context 'when prize type is monetary' do
      it 'returns true when prize total is positive' do
        challenge.prize_type = 'monetary'
        challenge.prize_total = 1000
        expect(helper.show_monetary_prizes?(challenge)).to be true
      end

      it 'returns false when prize total is zero' do
        challenge.prize_type = 'monetary'
        challenge.prize_total = 0
        expect(helper.show_monetary_prizes?(challenge)).to be false
      end
    end

    context 'when prize type is both' do
      it 'returns true when prize total is positive' do
        challenge.prize_type = 'both'
        challenge.prize_total = 1000
        expect(helper.show_monetary_prizes?(challenge)).to be true
      end
    end

    context 'when prize type is non_monetary' do
      it 'returns false regardless of prize total' do
        challenge.prize_type = 'non_monetary'
        challenge.prize_total = 1000
        expect(helper.show_monetary_prizes?(challenge)).to be false
      end
    end
  end

  describe '#show_non_monetary_prizes?' do
    context 'when prize type is non_monetary' do
      it 'returns true when non_monetary_prizes are present' do
        challenge.prize_type = 'non_monetary'
        challenge.non_monetary_prizes = ['Prize 1']
        expect(helper.show_non_monetary_prizes?(challenge)).to be true
      end

      it 'returns false when non_monetary_prizes are empty' do
        challenge.prize_type = 'non_monetary'
        challenge.non_monetary_prizes = nil
        expect(helper.show_non_monetary_prizes?(challenge)).to be false
      end
    end

    context 'when prize type is both' do
      it 'returns true when non_monetary_prizes are present' do
        challenge.prize_type = 'both'
        challenge.non_monetary_prizes = ['Prize 1']
        expect(helper.show_non_monetary_prizes?(challenge)).to be true
      end
    end
  end

  describe '#safe_how_to_enter_link' do
    context 'with valid URLs' do
      it 'returns the URL when it starts with http' do
        challenge.how_to_enter_link = 'http://example.com'
        expect(helper.safe_how_to_enter_link(challenge)).to eq('http://example.com')
      end

      it 'adds https when URL does not start with http' do
        challenge.how_to_enter_link = 'example.com'
        expect(helper.safe_how_to_enter_link(challenge)).to eq('https://example.com')
      end
    end

    context 'with invalid URLs' do
      it 'returns nil for blank links' do
        challenge.how_to_enter_link = ''
        expect(helper.safe_how_to_enter_link(challenge)).to be_nil
      end

      it 'returns nil for invalid URLs' do
        challenge.how_to_enter_link = 'not a url'
        expect(helper.safe_how_to_enter_link(challenge)).to be_nil
      end
    end
  end

  describe '#phase_winner_data?' do
    let(:phase_winner) { double('PhaseWinner') }
    let(:winner) { double('Winner') }

    it 'returns true when overview is present' do
      allow(phase_winner).to receive_messages(
        overview: 'Overview text',
        overview_image_key: nil,
        winners: []
      )
      expect(helper.phase_winner_data?(phase_winner)).to be true
    end

    it 'returns true when overview_image_key is present' do
      allow(phase_winner).to receive_messages(
        overview: nil,
        overview_image_key: 'some_key.jpg',
        winners: []
      )
      expect(helper.phase_winner_data?(phase_winner)).to be true
    end

    it 'returns true when winners are present' do
      allow(winner).to receive(:image_key).and_return('winner_image.jpg')
      allow(phase_winner).to receive_messages(
        overview: nil,
        overview_image_key: nil,
        winners: [winner]
      )
      expect(helper.phase_winner_data?(phase_winner)).to be true
    end

    it 'returns false when no data is present' do
      allow(phase_winner).to receive_messages(
        overview: nil,
        overview_image_key: nil,
        winners: []
      )
      expect(helper.phase_winner_data?(phase_winner)).to be false
    end
  end

  describe '#show_apply_button?' do
    context 'with external links' do
      it 'returns true when external_url is present' do
        allow(challenge).to receive(:external_url).and_return('http://example.com')
        expect(helper.show_apply_button?(challenge)).to be true
      end

      it 'returns true when how_to_enter_link is present' do
        allow(challenge).to receive(:how_to_enter_link).and_return('http://example.com')
        expect(helper.show_apply_button?(challenge)).to be true
      end
    end

    context 'without external links' do
      let(:current_phase) { build(:phase) }
      let(:next_phase) { build(:phase, start_date: 1.day.from_now) }

      before do
        allow(challenge).to receive_messages(external_url: nil, how_to_enter_link: nil)
      end

      it 'returns true when current phase allows submissions' do
        allow(helper).to receive(:get_current_phase).and_return(current_phase)
        allow(current_phase).to receive(:open_to_submissions).and_return(true)
        expect(helper.show_apply_button?(challenge)).to be true
      end

      it 'returns true when next phase exists' do
        allow(helper).to receive_messages(get_current_phase: nil, get_next_phase: next_phase)
        expect(helper.show_apply_button?(challenge)).to be true
      end

      it 'returns false when no phases allow apply' do
        allow(helper).to receive_messages(get_current_phase: nil, get_next_phase: nil)
        expect(helper.show_apply_button?(challenge)).to be false
      end
    end
  end

  describe '#apply_button_url' do
    context 'with phases' do
      let(:current_phase) { build(:phase) }
      let(:expected_path) { "/challenges/#{challenge.id}/submissions/new" }

      it 'returns submission URL when phase is open' do
        challenge.external_url = nil
        challenge.how_to_enter_link = nil
        allow(helper).to receive(:get_current_phase).and_return(current_phase)
        allow(current_phase).to receive(:open_to_submissions).and_return(true)

        expect(helper.apply_button_url(challenge)).to eq("#{Rails.configuration.phx_interop[:phx_uri]}#{expected_path}")
      end
    end
  end

  describe '#apply_button_text' do
    context 'with phases' do
      let(:current_phase) { build(:phase) }
      let(:next_phase) { build(:phase, start_date: 1.day.from_now) }

      before do
        challenge.external_url = nil
        challenge.how_to_enter_link = nil
      end

      it 'returns in challenge gov text when current phase is open' do
        allow(helper).to receive_messages(
          get_current_phase: current_phase,
          get_next_phase: nil
        )
        allow(current_phase).to receive(:open_to_submissions).and_return(true)
        expect(helper.apply_button_text(challenge)).to eq(I18n.t('challenge_listing.apply.in_challenge_gov'))
      end

      it 'returns future phase text when only next phase exists' do
        allow(helper).to receive_messages(
          get_current_phase: nil,
          get_next_phase: next_phase
        )
        allow(helper).to receive(:format_date).with(next_phase.start_date).and_return('Jan 1, 2024')
        expect(helper.apply_button_text(challenge)).to eq(I18n.t('challenge_listing.apply.future_phase', date: 'Jan 1, 2024'))
      end
    end
  end
end
