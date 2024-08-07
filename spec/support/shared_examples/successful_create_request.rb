shared_examples 'successful create response' do
  it 'creates the resource and persists it to the database' do
    expect(created_resource).to be_present
  end

  it 'responds with 201 status' do
    expect(response).to have_http_status(:created)
  end
end
