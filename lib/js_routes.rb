module JsRoutes
  class << self


    def generate(options = {})
      js = File.read(File.dirname(__FILE__) + "/routes.js")
      options[:namespace] ||= "Routes"
      js.gsub!("NAMESPACE", options[:namespace])
      js.gsub!("ROUTES", js_routes(options))
    end

    def generate!(options = {})
      file = options[:file] || default_file
      File.open(file, 'w') do |f|
        f.write generate(options)
      end
    end

    #
    # Implementation
    #

    protected
    def js_routes(options = {})

      options[:default_format] ||= ""
      exclude = Array(options[:exclude])

      Rails.application.reload_routes!
      Rails.application.routes.named_routes.routes.map do |name, route|
        if exclude.find {|e| name.to_s =~ e}
          ""
        else
          build_js(name, route, options)
        end
      end.join("\n")
    end

    def build_js(name, route, options)
      _ = <<-JS
  // #{route.name} => #{route.path}
  #{name.to_s}_path: function(#{build_params route}) {
    var opts = options || {};
    var format = opts.format || '#{options[:default_format]}';
    delete opts.format;
  #{build_default_params route};
    return Routes.check_path('#{build_path route}' + format) + Routes.serialize(opts);
  },
JS
    end


    def build_params route
      route.conditions[:path_info].captures.map do |cap|
        if cap.is_a?(Rack::Mount::GeneratableRegexp::DynamicSegment)
          if cap.name.to_s == "format"
            nil
          else
            cap.name.to_s.gsub(':', '')
          end
        end
      end.compact.<<("options").join(', ')
    end

    def build_default_params route
      route.conditions[:path_info].captures.map do |cap|
        if cap.is_a?(Rack::Mount::GeneratableRegexp::DynamicSegment)
          segg = cap.name.to_s.gsub(':', '')
          "#{segg} = Routes.check_parameter(#{segg});"
        end
      end.join("\n")
    end

    def build_path route
      s = route.path.gsub(/\(\.:format\)$/, ".")

      route.conditions[:path_info].captures.each do |cap|
        unless cap.name.to_s == "format"
          if route.conditions[:path_info].required_params.include?(cap.name)
            s.gsub!(/:#{cap.name.to_s}/){ "' + #{cap.name.to_s.gsub(':','')} + '" }
          else
            s.gsub!(/\((\.)?:#{cap.name.to_s}\)/){ "#{$1}' + #{cap.name.to_s.gsub(':','')} + '" }
          end
        end
      end
      s

    end

    def default_file
      if Rails.version >= "3.1"
        "#{Rails.root}/app/assets/javascripts/routes.js"
      else
        "#{Rails.root}/public/javascripts/routes.js"
      end
    end

  end
end
