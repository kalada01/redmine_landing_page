require_relative 'lib/custom_landing_page/patches/application_controller_patch'

ActiveSupport.on_load(:action_controller) do
  unless ApplicationController.included_modules.include?(CustomLandingPage::Patches::ApplicationControllerPatch)
    ApplicationController.send(:include, CustomLandingPage::Patches::ApplicationControllerPatch)
    Rails.logger.info "[custom_landing_page] Patch included via on_load"
  end
end

Redmine::Plugin.register :custom_landing_page do
  name 'Custom Landing Page'
  author 'ak'
  description 'Redirect users to a custom landing page based on login, language, group, or role'
  version '0.0.2'
  requires_redmine version_or_higher: '6.0.0'
  settings default: {
    'redirect_config_json' => {
      "default_redirect": "/projects/project_page/wiki"
    }.to_json
  }, partial: 'settings/custom_landing_page_settings'
end
