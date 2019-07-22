class Webhook < ApplicationRecord
  validates :name,
            :inclusion  => { :in => [ 'watch', 'warning'],
                             :message    => "%{value} is not a valid name" }
end
