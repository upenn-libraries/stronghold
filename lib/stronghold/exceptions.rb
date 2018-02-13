module Exceptions
  class GlacierError < StandardError; end
  class VaultNotFoundError < GlacierError; end
end