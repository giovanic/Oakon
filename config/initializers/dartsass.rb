# Only the ActiveAdmin stylesheet is compiled through Dart Sass.
# The storefront's own CSS is built separately via Tailwind CLI (see package.json).
Rails.application.config.dartsass.builds = {
  "active_admin.scss" => "active_admin.css"
}
