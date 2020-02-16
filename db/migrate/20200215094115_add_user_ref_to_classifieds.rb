class AddUserRefToClassifieds < ActiveRecord::Migration[6.0]
  def change
    add_reference :classifieds, :user, foreign_key: true
  end
end
