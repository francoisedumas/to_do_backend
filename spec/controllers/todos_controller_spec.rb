require 'rails_helper'

RSpec.describe Api::V1::TodosController, type: :controller do
  it 'has a max limit of 100' do
    # explanation https://youtu.be/SQhj5gBNTB0 about 7:40
    expect(Todo).to receive(:limit).with(100).and_call_original

    get :index, params: { limit: 999 }
  end
end