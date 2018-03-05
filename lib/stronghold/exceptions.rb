module Exceptions
  class GlacierError < StandardError; end
  class VaultNotFoundError < GlacierError; end
  class InvalidIoModeError < GlacierError; end
end