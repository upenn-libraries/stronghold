module Exceptions
  class GlacierError < StandardError; end
  class MissingGlacierCredentialsError < GlacierError; end
  class VaultNotFoundError < GlacierError; end
  class InvalidIoModeError < GlacierError; end
  class JobNotReadyError < GlacierError; end
end