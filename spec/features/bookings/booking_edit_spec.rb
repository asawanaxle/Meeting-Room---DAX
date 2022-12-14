require 'rails_helper' 

feature "Booking Edit", :devise do 
  let(:tomorrow_at_ten) { DateTime.now.midnight + 34.hours }
  let(:four_days_later) { DateTime.now.midnight + 18.hours + 4.days }
 
  scenario "users can edit bookings they created" do 
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    new_client = user.clients.create(name: 'my new client')
    new_booking = user.bookings.create(appointment_time: { "date" => tomorrow_at_ten.strftime("%Y-%m-%d"), "hour" => tomorrow_at_ten.strftime("%l"), "min" => tomorrow_at_ten.strftime("%M") }, duration: 3600, price: 80, client: new_client)
    visit edit_booking_path(new_booking)
    fill_in "booking_client_attributes_name", with: "my edited client"
    fill_in "booking_appointment_time_date", with: four_days_later.strftime("%Y-%m-%d")
    select "6 PM", from: "booking_appointment_time_hour"
    select "30", from: "booking_appointment_time_min"
    select "1 hr", from: "booking_duration_hour"
    select "30 min", from: "booking_duration_min"
    fill_in "booking_price", with: 100
    click_button "Update Booking" 
    visit booking_path(new_booking)
    expect(page).to have_content("my edited client")
    expect(page).to have_content("6:30 PM")
    expect(page).to have_content("1 hour and 30 minutes")
    expect(page).to have_content("$100.00")
  end
  
  scenario "bookings should show the current time on the edit form" do 
    user = FactoryGirl.create(:user)
    signin(user.email, user.password)
    new_client = user.clients.create(name: 'my new client')
    new_booking = user.bookings.create(appointment_time: { "date" => tomorrow_at_ten.strftime("%Y-%m-%d"), "hour" => (tomorrow_at_ten - 1.hour).strftime("%l"), "min" => tomorrow_at_ten.strftime("%M") }, duration: 3600, price: 80, client: new_client)
    visit edit_booking_path(new_booking)
    expect( find(:css, 'select#booking_appointment_time_hour').value ).to eq("9")
  end
  
  scenario "users can't edit bookings made by other users" do 
    user = FactoryGirl.create(:user)
    other_user = FactoryGirl.create(:user, email: "other@email.com")
    signin(user.email, user.password)
    new_client = user.clients.create(name: 'my new client')
    new_booking = user.bookings.create(appointment_time: { "date" => tomorrow_at_ten.strftime("%Y-%m-%d"), "hour" => tomorrow_at_ten.strftime("%l"), "min" => tomorrow_at_ten.strftime("%M") }, duration: 3600, price: 80, client: new_client)
    click_link "Sign out"
    signin(other_user.email, other_user.password)
    visit edit_booking_path(new_booking)
    expect(page.current_path).to eq(bookings_path)
  end
    
end