require 'spec_helper'

describe "Product scopes" do
  let!(:product) { create(:product) }

  context "A product assigned to parent and child taxons" do
    before do
      @taxonomy = create(:taxonomy)
      @root_taxon = @taxonomy.root

      @parent_taxon = create(:taxon, :name => 'Parent', :taxonomy_id => @taxonomy.id, :parent => @root_taxon)
      @child_taxon = create(:taxon, :name =>'Child 1', :taxonomy_id => @taxonomy.id, :parent => @parent_taxon)
      @parent_taxon.reload # Need to reload for descendents to show up

      product.taxons << @parent_taxon
      product.taxons << @child_taxon
    end

    it "calling Product.in_taxon returns products in child taxons" do
      product.taxons -= [@child_taxon]
      product.taxons.count.should == 1

      Spree::Product.in_taxon(@parent_taxon).should include(product)
    end

    it "calling Product.in_taxon should not return duplicate records" do
      Spree::Product.in_taxon(@parent_taxon).to_a.count.should == 1
    end

    it "orders products based on their ordering within the classification" do
      product_2 = create(:product)
      product_2.taxons << @parent_taxon

      product_root_classification = Spree::Classification.find_by(:taxon => @parent_taxon, :product => product)
      product_root_classification.update_column(:position, 1)

      product_2_root_classification = Spree::Classification.find_by(:taxon => @parent_taxon, :product => product_2)
      product_2_root_classification.update_column(:position, 2)

      Spree::Product.in_taxon(@parent_taxon).should == [product, product_2]
      product_2_root_classification.insert_at(1)
      Spree::Product.in_taxon(@parent_taxon).should == [product_2, product]
    end
  end
end
