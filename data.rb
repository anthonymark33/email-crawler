require 'data_mapper'
require_relative 'constants' 

DataMapper.setup(:default, DATABASE_URL)
# DataMapper.setup(:default, 'sqlite3:data.db')
DataMapper::Property::String.length(4096)

class Site
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime
  property :host,       String

  has n, :addresses
  has n, :pages

  validates_presence_of :host
  validates_uniqueness_of :host
end

class Page
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime
  property :url,        String

  belongs_to :site
  has n, :addresses

  validates_presence_of :url
  validates_uniqueness_of :url
end

class Address
  include DataMapper::Resource

  property :id,         Serial
  property :created_at, DateTime
  property :email,      String
  property :sent_count, Integer, :default  => 0 
  property :sent_at,    DateTime

  belongs_to :site
  belongs_to :page

  validates_presence_of :email
  validates_uniqueness_of :email
end

DataMapper.finalize
DataMapper.auto_upgrade!