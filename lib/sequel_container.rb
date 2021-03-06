require 'tmpdir'
require 'image_size'

module Sequel
  module Plugins
    module Container
      def self.apply(model, options = {})
        model.const_set "CONTAINER_TMPDIR", options[:tmp] || Dir.tmpdir
      end

      module ClassMethods
        def contains(object, options = {})
          return object.each { |o| contains(o, options) } if object.is_a? Array

          container = table_name
          url_template = options[:url] || '/:container/:id/:filename'

          class_eval <<-CONTAINED_PATH, __FILE__, __LINE__ + 1
            def #{object}_path
              return unless #{object}?
              @#{object}_path ||= write_#{object}
            end
          CONTAINED_PATH

          class_eval <<-CONTAINED_URL, __FILE__, __LINE__ + 1
            def #{object}_url
              return unless #{object}?
              @#{object}_path ||= write_#{object}
              @#{object}_url ||= "#{url_template}".gsub(/:(\\w+)/) do |m|
                sym = $1.to_sym
                case sym
                when :container
                  "#{container}"
                when :filename
                  send("#{object}_filename")
                when :extension
                  send("#{object}_extension")
                else
                  send(sym)
                end
              end
            end
          CONTAINED_URL

          class_eval <<-CONTAINED_ASSIGNMENT, __FILE__, __LINE__ + 1
            def #{object}=(value)
              return if value.nil?
              self.#{object}_type = content_type = value[:type]
              self.#{object}_data = data = value[:tempfile].read
              if content_type =~ /^image\\\/.*/
                size = ImageSize.new(data)
                self.#{object}_height = size.height
                self.#{object}_width = size.width
              end
            end
          CONTAINED_ASSIGNMENT

          class_eval <<-CONTAINED_QUERY, __FILE__, __LINE__ + 1
            def #{object}?
              !#{object}_type.nil? && !#{object}_type.empty?
            end
          CONTAINED_QUERY

          class_eval <<-CONTAINED_IMAGE, __FILE__, __LINE__ + 1
            def #{object}_image?
              #{object}? && #{object}_type[0,6] == 'image/'
            end
          CONTAINED_IMAGE

          class_eval <<-CONTAINED_DIRECTORY, __FILE__, __LINE__ + 1
            def #{object}_directory
              @asset_directory ||= FileUtils.mkdir_p(File.join(CONTAINER_TMPDIR, "#{container}", id.to_s))
            end
            protected :#{object}_directory
          CONTAINED_DIRECTORY

          class_eval <<-CONTAINED_FILENAME, __FILE__, __LINE__ + 1
            def #{object}_filename
              @#{object}_filename ||= "#{object}.\#{#{object}_extension}"
            end
            protected :#{object}_filename
          CONTAINED_FILENAME

          class_eval <<-CONTAINED_EXTENSION, __FILE__, __LINE__ + 1
            def #{object}_extension
              @#{object}_extension ||= case #{object}_type
                when /^text\\\/plain/
                  'txt'
                when /^(?:image|text)\\\/(.*)/
                  $1
                else
                  raise "unhandled asset type \#{#{object}_type}"
                end
            end
            protected :#{object}_extension
          CONTAINED_EXTENSION

          class_eval <<-WRITE_CONTAINED, __FILE__, __LINE__ + 1
            def write_#{object}
              path = File.join(#{object}_directory, #{object}_filename)
              File.open(path, 'w') { |file| file.write #{object}_data }
              path
            end
            protected :write_#{object}
          WRITE_CONTAINED
        end
      end
    end
  end
end
