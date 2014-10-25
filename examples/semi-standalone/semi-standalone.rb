require 'lotus/view'
require 'lotus/assets'

module ArticleRepository
  module_function

  def all
    ['test', 'test1', 'test2']
  end
end

Lotus::Assets.configure do
end

module Articles
  class Index
    include Lotus::View
    include Lotus::Assets::Helpers
  end

  class AtomIndex < Index
    format :atom
  end
end

Lotus::View.configure do
end

Lotus::View.load!

articles = ArticleRepository.all

p Articles::Index.render(format: :html, articles: articles)
