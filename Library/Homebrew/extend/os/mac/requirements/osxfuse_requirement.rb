# typed: false
# frozen_string_literal: true

require "requirement"

class OsxfuseRequirement < Requirement
  extend T::Sig

  download "https://osxfuse.github.io/"

  satisfy(build_env: false) { self.class.binary_osxfuse_installed? }

  sig { returns(T::Boolean) }

  def self.exist_include_osxfuse?
    File.exist?("/usr/local/include/osxfuse/fuse.h") &&
      !File.symlink?("/usr/local/include/osxfuse")
  end

  def self.exist_include_fuse?
    File.exist?("/usr/local/include/fuse/fuse.h") &&
      !File.symlink?("/usr/local/include/fuse")
  end

  def self.binary_osxfuse_installed?
    exist_include_osxfuse? || exist_include_fuse?
  end

  env do
    ENV.append_path "PKG_CONFIG_PATH", HOMEBREW_LIBRARY/"Homebrew/os/mac/pkgconfig/fuse"

    unless HOMEBREW_PREFIX.to_s == "/usr/local"
      ENV.append_path "HOMEBREW_LIBRARY_PATHS", "/usr/local/lib"
      ENV.append_path "HOMEBREW_INCLUDE_PATHS",
        "/usr/local/include/#{self.exist_include_osxfuse? ? "osxfuse" : "fuse"}"
    end
  end

  def message
    "FUSE for macOS is required for this software. #{super}"
  end
end
