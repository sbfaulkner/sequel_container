require 'rubygems'
require 'test/unit'
require 'sequel'

DB = Sequel.connect('postgres://postgres:p0stgr3s@localhost:5432/sequel_container_test')

class Company < Sequel::Model
  set_schema do
    primary_key :id
    varchar :logo_type, :size => 255
    bytea :logo_data
    varchar :biography_type, :size => 255
    bytea :biography_data
  end
  create_table!
  is :container
  contains [ :logo, :biography ]
end

class User < Sequel::Model
  set_schema do
    primary_key :id
    varchar :avatar_type, :size => 255
    bytea :avatar_data
  end
  create_table!
  is :container, :tmp => File.dirname(__FILE__) + '/tmp'
  contains :avatar
end

class SequelCascadingTest < Test::Unit::TestCase
  def test_should_create_empty_container
    company = Company.create
    assert company.reload
    assert_nil company.logo_type
    assert_nil company.logo_data
    assert_nil company.logo_path
    assert_nil company.logo_url
    assert !company.logo_image?
  end

  def test_should_contain_image
    logo = File.read(File.dirname(__FILE__)+'/data/logo.gif')
    company = Company.create :logo_type => 'image/gif', :logo_data => logo
    assert company.reload
    assert company.logo_image?
    assert_equal logo, company.logo_data
    assert_equal Dir.tmpdir+"/companies/#{company.id}/logo.gif", company.logo_path
    assert_equal "/companies/#{company.id}/logo.gif", company.logo_url
  end

  def test_should_contain_text
    bio = File.read(File.dirname(__FILE__)+'/data/bio.txt')
    company = Company.create :biography_type => 'text/plain', :biography_data => bio
    assert company.reload
    assert !company.biography_image?
    assert_equal bio, company.biography_data
    assert_equal Dir.tmpdir+"/companies/#{company.id}/biography.txt", company.biography_path
    assert_equal "/companies/#{company.id}/biography.txt", company.biography_url
  end

  def test_should_contain_html
    bio = File.read(File.dirname(__FILE__)+'/data/bio.html')
    company = Company.create :biography_type => 'text/html', :biography_data => bio
    assert company.reload
    assert !company.biography_image?
    assert_equal bio, company.biography_data
    assert_equal Dir.tmpdir+"/companies/#{company.id}/biography.html", company.biography_path
    assert_equal "/companies/#{company.id}/biography.html", company.biography_url
  end
end
