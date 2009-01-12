require 'tmpdir'

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

          class_eval <<-CONTAINED_PATH, __FILE__, __LINE__ + 1
            def #{object}_path
              return if #{object}_data.nil? || #{object}_data.empty?
              @#{object}_path ||= write_#{object}
            end
          CONTAINED_PATH

          class_eval <<-CONTAINED_URL, __FILE__, __LINE__ + 1
            def #{object}_url
              return if #{object}_data.nil? || #{object}_data.empty?
              @#{object}_path ||= write_#{object}
              @#{object}_url ||= "/#{container}/\#{id}/\#{#{object}_filename}"
            end
          CONTAINED_URL

          class_eval <<-CONTAINED_IMAGE, __FILE__, __LINE__ + 1
            def #{object}_image?
              #{object}_type[0,6] == 'image/'
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
