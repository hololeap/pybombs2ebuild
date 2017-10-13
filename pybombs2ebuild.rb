#!/usr/bin/env ruby

require 'pp'
require 'yaml'

dir="#{__dir__}/gr-recipes"

files = Dir.entries(dir).grep_v(/^\./).grep_v(/^README/).map {|f| "#{dir}/#{f}" }
files = Hash[*files.map {|f| [f, YAML.load_file(f)] }.flatten]

files = files.select {|k,v| v['source'] and v['source'] =~ /github\.com\/[^\/]+\/gr-/}
files = files.select {|k,v| v['depends'] and (v['depends'] == 'gnuradio' or v['depends'] == ['gnuradio'] ) }

Dir.mkdir("#{__dir__}/net-wireless") rescue nil
files.each do |k,v|
  name = File.basename(k)[/(.*)(\.[^.]*)/,1]
  source = v['source'][/^(git\+)?(.+?)(\.git)?$/,2]
  desc = v['description']

  dir = "#{__dir__}/net-wireless/#{name}"
  file = "#{dir}/#{name}-9999.ebuild"

  Dir.mkdir(dir) rescue nil

  File.write(file, <<~EBUILD
            # Copyright 1999-2017 Gentoo Foundation
            # Distributed under the terms of the GNU General Public License v2

            EAPI=6

            DESCRIPTION="#{desc}"
            HOMEPAGE="#{source}"

            EGIT_REPO_URI="#{source}"
            KEYWORDS=""

            inherit gnuradio git-r3
        EBUILD
    )

  github = source[/github\.com\/([^\/]+\/[^\/]+)/,1]

  File.write("#{dir}/metadata.xml", <<~METADATA
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">
      <pkgmetadata>
          <maintainer type="person">
              <email>hololeap@gmail.com</email>
              <name>hololeap</name>
          </maintainer>
          <upstream>
              <remote-id type="github">#{github}</remote-id>
          </upstream>
      </pkgmetadata>
      METADATA
    )
end
