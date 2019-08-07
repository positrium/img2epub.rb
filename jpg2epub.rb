#!/usr/bin/env ruby

require 'erb'
require 'fileutils'
require 'securerandom'
require 'zip'

class EPubMaker
    def initialize(path)
        @root_path = path
        @title = path
        @direction = "rtl"

        @files = Dir.children(@root_path).sort
        @files.each do |file|
            @files.delete(file) if file.match?(/^\./)
        end
        @files.freeze
    end

    def root_path
        @root_path
    end

    def title
        @title
    end

    def name
        "#{@title}.epub"
    end

    def direction_detail
        if @direction == 'rtl'
            'right to left'
        else
            'left to right'
        end
    end

    def direction
        @direction
    end

    def cover_image
        @files[0]
    end

    def contents
        list = []

        @files.each do |file|
            next if file == cover_image
            list << {name: File.basename(file, '.*'), path: file}
        end

        list
    end

    def resources
        list = []

        @files.each do |file|
            list << {name: File.basename(file, '.*'), path: file}
        end

        list
    end

    def convert
        clean_tmp

        # TODO: replace to Dir.mktmpdir()
        create_epub_container
        create_navigate_xhtml
        create_content_xhtml
        compress_epub

        clean_tmp
    end

    private

    def clean_tmp
        FileUtils.rm_rf("tmp")
    end

    def create_epub_container
        # create tmp/
        Dir.mkdir("tmp")

        # create tmp/META-INF/
        Dir.mkdir("tmp/META-INF")

        # create tmp/META-INF/container.xml
        erb = ERB.new(IO.read("./template/META-INF/container.xml"), nil, "%")
        File.open("tmp/META-INF/container.xml", "w"){ |f|
            f.write(erb.result(binding))
        }

        # create tmp/EPUB/
        Dir.mkdir("tmp/EPUB")

        # create tmp/EPUB/images/
        Dir.mkdir("tmp/EPUB/images")

        # copy images
        resources.each do |img|
            FileUtils.cp("#{root_path}/#{img[:path]}", "tmp/EPUB/images/#{img[:path]}")
        end

        # create tmp/EPUB/package.opf
        uuid = SecureRandom.uuid
        modifiedAt = Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
        erb = ERB.new(IO.read("./template/EPUB/package.opf"), nil, "%")
        File.open("tmp/EPUB/package.opf", "w"){ |f|
            f.write(erb.result(binding))
        }
    end

    def create_navigate_xhtml
        # create tmp/EPUB/nav.xhtml
        erb = ERB.new(IO.read("./template/EPUB/nav.xhtml"), nil, "%")
        File.open("tmp/EPUB/nav.xhtml", "w"){ |f|
            f.write(erb.result(binding))
        }
    end

    def create_content_xhtml
        # create tmp/EPUB/doc*.xhml
        erb = ERB.new(IO.read("./template/EPUB/content.xhtml"), nil, "%")
        contents.each do |content|
            File.open("tmp/EPUB/#{content[:name]}.xhtml", "w"){ |f|
                f.write(erb.result(binding))
            }
        end
    end

    def compress_epub
        File.delete(name) if File.exist?(name)

        # create *.epub
        # create mimetype to store
        Zip::OutputStream.open(name) do |epub|
            epub.put_next_entry('mimetype', '', '', Zip::Entry::STORED)
            epub.write "application/epub+zip"
        end

        # copy resources
        Zip::File.open(name) do |epub|
            list = recursive_directory_walk("tmp")

            list.each do |f|
                if File.directory?("tmp/#{f}")
                    epub.mkdir(f)
                else
                    epub.add(f, "tmp/#{f}")
                end
            end
        end
    end

    def recursive_directory_walk(path, files = [])
        children = Dir.children(path).sort!

        children.each do |e|
            entry = "#{path}/#{e}".gsub(/^tmp\//, '')

            recursive_directory_walk("#{path}/#{e}", files) if File.directory?("#{path}/#{e}")
            files << entry unless files.include?(entry)
        end

        files
    end

end

doc = EPubMaker.new(ARGV[0])
puts "document name:\n\t#{doc.name}\n\n"
puts "document title:\n\t#{doc.title}\n\n"
puts "document direction:\n\t#{doc.direction_detail}\n\n"
puts "document cover-image:\n\t#{doc.root_path}/#{doc.cover_image}\n\n"
puts "document content:\n"
doc.contents.each do |content|
    puts "\t#{content[:name]}.xhtml(#{doc.root_path}/#{content[:path]})\n"
end

doc.convert

puts "\nconverted."


