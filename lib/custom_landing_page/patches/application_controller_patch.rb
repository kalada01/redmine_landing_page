module CustomLandingPage
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.class_eval do
          before_action :custom_redirect_after_login
        end
      end

      def custom_redirect_after_login
        return unless User.current.logged? && request.path == '/'

        config = Setting.plugin_custom_landing_page['redirect_config_json']
        return unless config

        begin
          rules = JSON.parse(config)
        rescue JSON::ParserError => e
          Rails.logger.warn "[custom_landing_page] JSON parse error: #{e.message}"
          return
        end

        user = User.current
        lang = user.language || I18n.locale.to_s
        login = user.login
        groups = user.groups.map(&:lastname)
        project = Project.find_by_identifier('redmine')
        roles = project.present? ? user.roles_for_project(project).map(&:name) : []

        target =
          rules.dig("user_language", login, lang) ||
          rules.dig("user_redirects", login) ||
          rules.dig("language_redirects", lang) ||
          (groups.map { |g| rules.dig("group_redirects", g) }.compact.first) ||
          (roles.map { |r| rules.dig("role_redirects", r) }.compact.first) ||
          rules["default_redirects"]

        return unless target.present? && target.start_with?('/')

        redirect_to(target)
      end
    end
  end
end
