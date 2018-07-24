Hanami::Assets::Config::GlobalSources.class_eval do
  def clear
    @paths.each do |path|
      Hanami::Assets.configuration.sources.delete(path)

      Hanami::Assets.duplicates.each do |duplicate|
        duplicate.configuration.sources.delete(path)
      end
    end

    super
  end
end
