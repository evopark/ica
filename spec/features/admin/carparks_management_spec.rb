# frozen_string_literal: true

feature 'Creating a parking garage' do
  context 'with an unconfigured garage' do
    let!(:unconfigured_garage) { create(:parking_garage) }

    scenario 'with the carpark id' do
      visit new_carpark_path
      expect(page).to have_content 'Configure parking garage for the ICA API'
      select unconfigured_garage.name, from: 'carpark[parking_garage_id]'
      fill_in 'garage_settings[carpark_id]', with: '321'
      find('input[type=submit]').click
      expect(page).to have_content "Configuration for #{unconfigured_garage.name}"
    end
  end
end
