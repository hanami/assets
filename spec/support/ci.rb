module CI
  def self.enabled?
    ENV['CI']
  end
end
