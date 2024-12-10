# frozen_string_literal: true

Hanami::CygUtils::LoadPaths.class_eval do
  def empty?
    @paths.empty?
  end

  def clear
    @paths.clear
  end

  def include?(path)
    @paths.include?(path)
  end

  def delete(path)
    @paths.delete(path)
  end
end
