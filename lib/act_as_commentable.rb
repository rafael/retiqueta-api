module ActAsCommentable

  def self.included(klass)
    klass.before_create :generate_converstation
  end

  private

  def generate_converstation
    conversation || build_conversation
  end
end
