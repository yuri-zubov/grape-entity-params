class Grape::Entity::Params::FakeRequiredParam < Grape::Entity
  expose :id, using: Integer, documentation: { type: Integer, desc: 'ID', required: true }
end

class Grape::Entity::Params::FakeName < Grape::Entity
  expose :first_name, using: String, documentation: { type: String, desc: 'First Name', required: true }
  expose :last_name, using: String, documentation: { type: String, desc: 'Last Name', required: true }
end


class Grape::Entity::Params::FakeUser < Grape::Entity
  expose :id, using: Integer, documentation: { type: Integer, desc: 'ID', required: true }
  expose :name, using: Grape::Entity::Params::FakeName, documentation: { type: Grape::Entity::Params::FakeName, desc: 'Name' }
end

class Grape::Entity::Params::FakeSubject < Grape::API
  helpers do
    params :pagination do
      optional :page, type: Integer
      optional :per_page, type: Integer
    end
  end

  namespace :votes do
    # params with: Grape::Entity::Params::FakeUser
    desc 'Return a status.'
    params do
      use :pagination # aliases: includes, use_scope
      requires :id, type: Integer, desc: 'Status ID.'
    end
    post do
      'Created a Vote'
    end
  end
end

RSpec.describe Grape::Entity::Params do
  # subject { Grape::Entity::Params::FakeSubject }

  subject { Class.new(Grape::API) }

  def app
    subject
  end

  let(:name_entity) do
    Class.new(Grape::Entity) do
      expose :first_name, using: String, documentation: { type: String, desc: 'First Name', required: true }
      expose :last_name, using: String, documentation: { type: String, desc: 'Last Name', required: true }
    end
  end

  let(:user_entity) do
    Class.new(Grape::Entity) do
      expose :id, using: Integer, documentation: { type: Integer, desc: 'ID', required: true }
      expose :name, using: name_entity, documentation: { type: name_entity, desc: 'Name', required: true }
    end
  end

  let(:user_request) do
    Class.new(Grape::Entity) do
      expose :user, documentation: { type: user_entity, desc: 'User to find', required: true }
    end
  end

  # let(:name) do
  #   name = Class.new(Grape::Entity)
  #   name.instance_eval do
  #     expose :first, using: String, documentation: { type: String, desc: 'First Name' }
  #     expose :last, using: String, documentation: { type: String, desc: 'Last Name' }
  #   end
  #   name
  # end
  #
  # let(:user) do
  #   user = Class.new(Grape::Entity)
  #   user.instance_eval do
  #     expose :id, using: Integer, documentation: { type: Integer, desc: 'ID', required: true }
  #     expose :name, using: name, documentation: { type: name, desc: 'Name' }
  #   end
  #   user
  # end

  def app
    subject
  end
  
  it "has a version number" do
    expect(Grape::Entity::Params::VERSION).not_to be nil
  end

  it "creates a nested required option" do
    name_entity = Class.new(Grape::Entity) do
      expose :first_name, using: String, documentation: { type: String, desc: 'First Name', required: true }
      expose :last_name, using: String, documentation: { type: String, desc: 'Last Name', required: true }
    end

    user_entity = Class.new(Grape::Entity) do
      expose :id, using: Integer, documentation: { type: Integer, desc: 'ID', required: true }
      expose :name, using: name_entity, documentation: { type: name_entity, desc: 'Name', required: true }
    end

    user_request = Class.new(Grape::Entity) do
      expose :user, documentation: { type: user_entity, desc: 'User to find', required: true }
    end

    subject.namespace :votes do
      params do
        use user_request
      end
      post do
        'Created a Vote'
      end
    end

    post '/votes', '{"user": {"id": 1}}', 'CONTENT_TYPE' => 'application/json'
    expect(last_response.body).to eq("user[name] is missing, user[name][first_name] is missing, user[name][last_name] is missing")
  end

end

