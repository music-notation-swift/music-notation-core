Pod::Spec.new do |s|
  s.name         = "MusicNotationCore"
  s.version      = "0.1.1"
  s.summary      = "Cross-platform Music Notation library."
  s.description  = <<-DESC
                    This is a cross-platform Music Notation library.
                    This is the core functionality. Please see MusicNotationKit
                    for the full library with rendering and playability.
                   DESC

  s.homepage     = "https://github.com/drumnkyle/music-notation-core"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = { :type => "GPLv3", :file => "LICENSE" }
  
  s.authors      = { "Kyle Sherman" => "kyledsherman@gmail.com", "Miguel Osorio" => "migue48@gmail.com" }
  s.social_media_url   = "http://twitter.com/drumnkyle"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/drumnkyle/music-notation-core.git", :tag => "#{s.version}" }

  s.source_files  = "Sources", "Sources/**/*.swift"

    # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
