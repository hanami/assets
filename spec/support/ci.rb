module CI
  def self.enabled?
    ENV['TRAVIS']
  end
end
