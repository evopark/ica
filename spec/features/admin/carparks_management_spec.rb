# frozen_string_literal: true

feature 'Creating a parking garage' do
  let!(:garage_system) { create(:garage_system) }

  context 'with an unconfigured garage' do
    let!(:unconfigured_garage) { create(:parking_garage) }

    scenario 'creates a carpark when all information is submitted' do
      visit new_carpark_path
      expect(page).to have_content 'Configure parking garage for the ICA API'
      select garage_system.to_s, from: 'carpark[garage_system_id]'
      select unconfigured_garage.name, from: 'carpark[parking_garage_id]'
      fill_in 'carpark[carpark_id]', with: '321'
      find('input[type=submit]').click
      expect(page).to have_content "Configuration for #{unconfigured_garage.name}"
    end
  end
end
