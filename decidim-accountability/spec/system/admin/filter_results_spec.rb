# frozen_string_literal: true

require "spec_helper"

describe "Admin filters results", type: :system do
  include_context "when managing a component as an admin"
  include_context "with filterable context"

  let(:manifest_name) { "accountability" }
  let(:model_name) { Decidim::Accountability::Result.model_name }

  # Override :filterable_concern used by decidim-admin/lib/decidim/admin/test/filterable_examples.rb,
  # which would include a :route_key value of "results", rather than "accountability".
  let(:filterable_concern) { "Decidim::Accountability::Admin::Filterable".constantize }

  context "when filtering by scope" do
    let!(:scope1) { create(:scope, organization: component.organization, name: { "en" => "Scope1" }) }
    let!(:scope2) { create(:scope, organization: component.organization, name: { "en" => "Scope2" }) }
    let!(:result_with_scope1) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      scope: scope1)
    end
    let(:result_with_scope1_title) { translated(result_with_scope1.title) }
    let!(:result_with_scope2) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      scope: scope2)
    end
    let(:result_with_scope2_title) { translated(result_with_scope2.title) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit_component_admin
    end

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope1" do
      let(:in_filter) { result_with_scope1_title }
      let(:not_in_filter) { result_with_scope2_title }
    end

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope2" do
      let(:in_filter) { result_with_scope2_title }
      let(:not_in_filter) { result_with_scope1_title }
    end
  end

  context "when filtering by category" do
    let!(:category1) { create(:category, participatory_space: participatory_space, name: { "en" => "Category1" }) }
    let!(:category2) { create(:category, participatory_space: participatory_space, name: { "en" => "Category2" }) }
    let!(:result_with_category1) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      category: category1)
    end
    let(:result_with_category1_title) { translated(result_with_category1.title) }
    let!(:result_with_category2) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      category: category2)
    end
    let(:result_with_category2_title) { translated(result_with_category2.title) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit_component_admin
    end

    it_behaves_like "a filtered collection", options: "Category", filter: "Category1" do
      let(:in_filter) { result_with_category1_title }
      let(:not_in_filter) { result_with_category2_title }
    end

    it_behaves_like "a filtered collection", options: "Category", filter: "Category2" do
      let(:in_filter) { result_with_category2_title }
      let(:not_in_filter) { result_with_category1_title }
    end
  end

  context "when searching by ID or title" do
    let!(:result1) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) })
    end
    let!(:result2) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) })
    end
    let!(:result1_title) { translated(result1.title) }
    let!(:result2_title) { translated(result2.title) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit_component_admin
    end

    it "can be searched by ID" do
      search_by_text(result1.id)

      expect(page).to have_content(result1_title)
    end

    it "can be searched by title" do
      search_by_text(result2_title)

      expect(page).to have_content(result2_title)
    end
  end

  context "when listing results" do
    it_behaves_like "paginating a collection" do
      let!(:collection) { create_list(:result, 50, component: current_component) }
    end
  end
end