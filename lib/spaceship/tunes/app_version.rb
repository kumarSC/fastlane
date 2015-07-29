module Spaceship
  module Tunes
    # Represents an editable version of an iTunes Connect Application
    # This can either be the live or the edit version retrieved via the app
    class AppVersion < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      #   this version is for
      attr_accessor :application

      # @return (String) The version number of this version
      attr_accessor :version

      # @return (String) The copyright information of this app
      attr_accessor :copyright

      # @return (Spaceship::Tunes::AppStatus) What's the current status of this app
      #   e.g. Waiting for Review, Ready for Sale, ...
      attr_reader :app_status

      # @return (Bool) Is that the version that's currently available in the App Store?
      attr_accessor :is_live

      # Categories (e.g. MZGenre.Business)
      attr_accessor :primary_category

      attr_accessor :primary_first_sub_category

      attr_accessor :primary_second_sub_category

      attr_accessor :secondary_category

      attr_accessor :secondary_first_sub_category

      attr_accessor :secondary_second_sub_category

      # @return (String) App Status (e.g. 'readyForSale'). You should use `app_status` instead
      attr_accessor :raw_status

      # @return (Bool)
      attr_accessor :can_reject_version

      # @return (Bool)
      attr_accessor :can_prepare_for_upload

      # @return (Bool)
      attr_accessor :can_send_version_live

      # @return (Bool) Should the app automatically be released once it's approved?
      attr_accessor :release_on_approval

      # @return (Bool)
      attr_accessor :can_beta_test

      # @return (Bool) Does the binary contain a watch binary?
      attr_accessor :supports_apple_watch

      # @return (String) URL to the full resolution 1024x1024 app icon
      attr_accessor :app_icon_url

      # @return (String) Name of the original file
      attr_accessor :app_icon_original_name

      # @return (String) URL to the full resolution 1024x1024 app icon
      attr_accessor :watch_app_icon_url

      # @return (String) Name of the original file
      attr_accessor :watch_app_icon_original_name

      # @return (Integer) a unqiue ID for this version generated by iTunes Connect
      attr_accessor :version_id

      # @return TODO
      attr_accessor :company_information

      ####
      # App Review Information
      ####
      # @return (String) App Review Information First Name
      attr_accessor :review_first_name

      # @return (String) App Review Information Last Name
      attr_accessor :review_last_name

      # @return (String) App Review Information Phone Number
      attr_accessor :review_phone_number

      # @return (String) App Review Information Email Address
      attr_accessor :review_email

      # @return (String) App Review Information Demo Account User Name
      attr_accessor :review_demo_user

      # @return (String) App Review Information Demo Account Password
      attr_accessor :review_demo_password

      # @return (String) App Review Information Notes
      attr_accessor :review_notes

      ####
      # Localized values
      ####

      # @return (Array) Raw access the all available languages. You shouldn't use it probbaly
      attr_accessor :languages

      # @return (Hash) A hash representing the app name in all languages
      attr_reader :name

      # @return (Hash) A hash representing the keywords in all languages
      attr_reader :keywords

      # @return (Hash) A hash representing the description in all languages
      attr_reader :description

      # @return (Hash) The changelog
      attr_reader :release_notes

      # @return (Hash) A hash representing the keywords in all languages
      attr_reader :privacy_url

      # @return (Hash) A hash representing the keywords in all languages
      attr_reader :support_url

      # @return (Hash) A hash representing the keywords in all languages
      attr_reader :marketing_url

      # @return (Hash) Represents the screenshots of this app version (read-only)
      attr_reader :screenshots


      attr_mapping({
        'canBetaTest' => :can_beta_test,
        'canPrepareForUpload' => :can_prepare_for_upload,
        'canRejectVersion' => :can_reject_version,
        'canSendVersionLive' => :can_send_version_live,
        'copyright.value' => :copyright,
        'details.value' => :languages,
        'largeAppIcon.value.originalFileName' => :app_icon_original_name,
        'largeAppIcon.value.url' => :app_icon_url,
        'primaryCategory.value' => :primary_category,
        'primaryFirstSubCategory.value' => :primary_first_sub_category,
        'primarySecondSubCategory.value' => :primary_second_sub_category,
        'releaseOnApproval.value' => :release_on_approval,
        'secondaryCategory.value' => :secondary_category,
        'secondaryFirstSubCategory.value' => :secondary_first_sub_category,
        'secondarySecondSubCategory.value' => :secondary_second_sub_category,
        'status' => :raw_status,
        'supportsAppleWatch' => :supports_apple_watch,
        'versionId' => :version_id,
        'version.value' => :version,
        'watchAppIcon.value.originalFileName' => :watch_app_icon_original_name,
        'watchAppIcon.value.url' => :watch_app_icon_url,

        # App Review Information
        'appReviewInfo.firstName.value' => :review_first_name,
        'appReviewInfo.lastName.value' => :review_last_name,
        'appReviewInfo.phoneNumber.value' => :review_phone_number,
        'appReviewInfo.emailAddress.value' => :review_email,
        'appReviewInfo.reviewNotes.value' => :review_notes,
        'appReviewInfo.userName.value' => :review_demo_user,
        'appReviewInfo.password.value' => :review_demo_password
      })

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          orig = attrs.dup
          obj = self.new(attrs)
          obj.unfold_languages

          return obj
        end

        # @param application (Spaceship::Tunes::Application) The app this version is for
        # @param app_id (String) The unique Apple ID of this app
        # @param is_live (Boolean) Is that the version that's live in the App Store?
        def find(application, app_id, is_live = false)
          attrs = client.app_version(app_id, is_live)
          attrs.merge!(application: application)
          attrs.merge!(is_live: is_live)

          return self.factory(attrs)
        end
      end

      # @return (Bool) Is that version currently available in the App Store?
      def is_live?
        is_live
      end

      # Call this method to make sure the given languages are available for this app
      # You should call this method before accessing the name, description and other localized values
      # This will create the new language if it's not available yet and do nothing if everything's there
      # def create_languages!(languages)
      #   raise "Please pass an array" unless languages.kind_of?Array

      #   copy_from = self.languages.first
      #   languages.each do |language|
      #     # First, see if it's already available
      #     found = self.languages.find do |local|
      #       local['language'] == language
      #     end

      #     unless found
      #       new_language = copy_from.dup
      #       new_language['language'] = language
      #       [:description, :releaseNotes, :keywords].each do |key|
      #         new_language[key.to_s]['value'] = nil
      #       end

      #       self.languages << new_language
      #       unfold_languages

      #       # Now we need to set a useless `pageLanguageValue` value because iTC says so, after adding a new version
      #       self.languages.each do |current|
      #         current['pageLanguageValue'] = current['language']
      #       end
      #     end
      #   end

      #   languages
      # end

      # Push all changes that were made back to iTunes Connect
      def save!
        client.update_app_version!(application.apple_id, is_live?, raw_data)
      end

      # @return (String) An URL to this specific resource. You can enter this URL into your browser
      def url
        "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/#{self.application.apple_id}/" + (self.is_live? ? "cur" : "")
      end


      # Private methods
      def setup
        # Properly parse the AppStatus
        status = raw_data['status']
        @app_status = Tunes::AppStatus.get_from_string(status)

        # Setup the screenshots
        @screenshots = {}
        raw_data['details']['value'].each do |row|
          # Now that's one language right here
          @screenshots[row['language']] = setup_screenshots(row)
        end
      end


      # Prefill name, keywords, etc...
      def unfold_languages
        {
          name: :name,
          keywords: :keywords,
          description: :description,
          privacyURL: :privacy_url,
          supportURL: :support_url,
          marketingURL: :marketing_url,
          releaseNotes: :release_notes
        }.each do |json, attribute|
          instance_variable_set("@#{attribute}".to_sym, LanguageItem.new(json, languages))
        end
      end

      # These methods takes care of properly parsing values that
      # are not returned in the right format, e.g. boolean as string
      def release_on_approval
        super == 'true'
      end

      def supports_apple_watch
        (super != nil)
      end

      def primary_category=(value)
        value = "MZGenre.#{value}" unless value.include? "MZGenre"
        super(value)
      end

      def primary_category=(value)
        value = "MZGenre.#{value}" unless value.include? "MZGenre"
        super(value)
      end

      def primary_second_sub_category=(value)
        value = "MZGenre.#{value}" unless value.include? "MZGenre"
        super(value)
      end

      def secondary_category=(value)
        value = "MZGenre.#{value}" unless value.include? "MZGenre"
        super(value)
      end

      def secondary_first_sub_category=(value)
        value = "MZGenre.#{value}" unless value.include? "MZGenre"
        super(value)
      end

      def secondary_second_sub_category=(value)
        value = "MZGenre.#{value}" unless value.include? "MZGenre"
        super(value)
      end

      private
        # generates the nested data structure to represent screenshots
        def setup_screenshots(row)
          screenshots = row.fetch('screenshots', {}).fetch('value', nil)
          return [] unless screenshots

          result = []

          screenshots.each do |device_type, value|
            value['value'].each do |screenshot|
              screenshot = screenshot['value']
              result << Tunes::AppScreenshot.new({
                url: screenshot['url'],
                thumbnail_url: screenshot['thumbNailUrl'],
                sort_order: screenshot['sortOrder'],
                original_file_name: screenshot['originalFileName'],
                device_type: device_type,
                language: row['language']
              })
            end
          end

          return result
        end
    end
  end
end
