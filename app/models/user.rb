class User < ApplicationRecord
  #(joinable: false)
  # callback
  # after_commit :notify_update, on: :update
  # after_save :trigger_rollback
  validates :money, presence: true, numericality: true
  def notify_update
    puts "Done commit..."
  end

  def trigger_rollback
    raise ActiveRecord::Rollback
  end

  def self.transfer_has_no_transaction user1, user2
    user1.update!(money: user1.money + 100)
    user2.update!(money: "")
  end

  def self.transfer_has_ex user1, user2
    ActiveRecord::Base.transaction do
      user1.update!(money: user1.money + 100)
      user2.update!(money: "")
    end
  end

  def self.transfer user1, user2
    ActiveRecord::Base.transaction do
      user1.update!(money: user1.money + 100)
      user2.update!(money: user2.money - 100)
      raise ActiveRecord::Rollback if user2.money < 1500
    end
  end

  def self.transfer_handle_ex user1, user2
    ActiveRecord::Base.transaction do
      user1.update!(money: user1.money + 100)
      user2.update!(money: "")
    end
  rescue ActiveRecord::RecordInvalid
    puts "Opp! Money can't be blank"
  end

  # def self.transfer_handle_ex_1 user1, user2
  #   ActiveRecord::Base.transaction do
  #     user1.update!(money: user1.money + 100)
  #     user2.update!(money: user2.money1 - 100)
  #   end
  # rescue NoMethodError
  #   puts "Opp! Has errors"
  # end

  def self.nested_transaction user1, user2
    ActiveRecord::Base.transaction do
      user1.update!(money: user1.money + 100)
      ActiveRecord::Base.transaction(requires_new: true) do
        user2.update!(money: user2.money - 100)
        raise ActiveRecord::Rollback
      end
    end
  end

  # def self.nested_transaction_demo user1, user2
  #   ActiveRecord::Base.transaction do
  #     user1.update!(money: user1.money + 100)
  #     ActiveRecord::Base.transaction(requires_new: true) do
  #       user2.update!(money: user2.money - 100)
  #       raise ActiveRecord::Rollback
  #     end
  #     user2.update!(money: user2.money - 100)
  #   end
  # end
end
