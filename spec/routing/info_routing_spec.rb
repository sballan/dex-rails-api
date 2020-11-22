require "rails_helper"

RSpec.describe InfoController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/info").to route_to("infos#index")
    end

    it "routes to #show" do
      expect(get: "/info/1").to route_to("infos#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/info").to route_to("infos#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/info/1").to route_to("infos#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/info/1").to route_to("infos#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/info/1").to route_to("infos#destroy", id: "1")
    end
  end
end
