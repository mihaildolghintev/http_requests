require 'rack/test'
require_relative '../../manager'
require_relative '../../models/playlist'

RSpec.describe Manager do
  context 'with created session' do
    Manager.create_session
    it 'token is not null' do
      expect(Manager.token).not_to equal nil
    end

    it 'creates playlist' do
    end
  end
end
