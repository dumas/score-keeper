require File.dirname(__FILE__) + '/../spec_helper'

describe GamesController, "not logged in" do
  before(:each) do
    @game = mock_model(Game)
    Game.stub!(:find_recent).and_return([@game])
  end
  
  it "should render" do
    get :index
    response.should be_success
  end
  
  it "should load games" do
    get :index
    assigns('games').first.should be_an_instance_of(Game)
  end
  
  it "should require login when trying to create a game" do
    post :create
    response.should be_redirect
    response.should redirect_to(login_path)
  end
end

describe GamesController, "creating a game (logged in)" do
  before(:each) do
    login_as Factory.create_user
    @game = mock_model(Game)
    @params = 
      { :teams =>
        { 
          :score1 => 10,
          :person11 => mock_model(Person).id,
          :person12 => mock_model(Person).id,
          :score2 => 8,
          :person21 => mock_model(Person).id,
          :person22 => mock_model(Person).id
        }
      }
      
      Game.stub!(:save).and_return(@game)
  end
  
  def do_post
    post :create, @params
  end
  
  it "should set a default time for played_at" do
    Game.should_receive(:played_at=).with(anything())
    do_post
  end
  
  it "should call Game model with new values" do
    Game.should_receive(:create).with(anything()).and_return(@game)
    do_post
  end
  
  it "should redirect to Games" do
    do_post
    response.should be_redirect
    response.should redirect_to(games_path)
  end
end