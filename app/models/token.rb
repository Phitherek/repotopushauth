class Token < ActiveRecord::Base
    validates :content, presence: true, uniqueness: true

    belongs_to :user

    before_validation :generate_content

    private

    def generate_content
        self.content = Forgery(:basic).password(exactly: 30)
    end
end
