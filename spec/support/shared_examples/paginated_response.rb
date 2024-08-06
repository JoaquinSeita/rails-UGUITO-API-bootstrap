RSpec.shared_examples 'paginated response' do
  it 'response body resources do not exceed page_size' do
    expect(response_body.size).to be <= page_size
  end
end
