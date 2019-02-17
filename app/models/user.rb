class User < ApplicationRecord
    has_many :watchlists

    has_many :favorites
    has_many :cards, :through => :favorites
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
