require 'formula'

class CopyPasta < Formula
  homepage 'https://github.com/jutkko/copy-pasta'
  url 'https://github.com/jutkko/copy-pasta/releases/download/0.1.1/copy-pasta-0.1.1'
  sha256 '268dd24c528abdbe7acffefa1ff620bb4c7fcc85626f3384bb46394148ee5e0f'

  depends_on 'go'

  def install
    mkdir_p "src/github.com/jutkko/copy-pasta"
    system "bash", "-c", "GOPATH=\"$PWD\" go build -o copy-pasta github.com/jutkko/copy-pasta"
    bin.install "copy-pasta"
  end
end
