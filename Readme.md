## JsRoutes

Generates javascript file that defines all Rails named routes as javascript helpers

### Intallation

Your Rails Gemfile:

``` ruby
gem "js-routes"
```

Your application initializer, like `config/initializers/jsroutes.rb`:

``` ruby
JsRoutes.generate!(
    :file => "#{Rails.root}app/assets/javascripts/routes.js",
    :default_format => "json",
    :exclude => [/^admin_/, /paypal/, /^api_/]
)
```

Available options:

* `:file` - the file to generate the routes. Default: 
  * `#{Rails.root}/app/assets/javascripts/routes.js` for Rails >= 3.1
  * `#{Rails.root}/public/javascripts/routes.js` for Rails < 3.1
* `:default_format` - Format to append to urls. Default: blank
* `:exclude` - Array of regexps to exclude form js routes. Default: []
  * Note that regexp applied to **named route** not to *URL*
* `:namespace` - global object used to access routes. Default: `Routes`
  * Possible variants: `MyProject.routes`, `window` (to make global).

In order to generate routes to string and manipulate them yourself:

``` ruby
JsRoutes.generate(options)
```

### Usage

This will create a nice javascript file with `Routes` object that has all the rails routes available:

``` js
Routes.users_path() // => "/users"
Routes.user_path(1, {format: 'json'}) // => "/users/1.json"
Routes.user_project_path(1,2, {q: 'hello', custom: true}) // => "/users/1/projects/2?q=hello&custom=true"
```

In order to make routes helpers available globally:

``` js
$.extend(window, Routes)
```

#### Have fun 
