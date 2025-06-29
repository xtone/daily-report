require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end
  end

  describe 'before_action' do
    describe '#set_locale' do
      it 'sets locale from params' do
        get :index, params: { locale: 'en' }
        expect(I18n.locale).to eq(:en)
      end

      it 'uses default locale when no locale param' do
        get :index
        expect(I18n.locale).to eq(I18n.default_locale)
      end
    end
  end

  describe 'error handling' do
    controller do
      def index
        case params[:error_type]
        when 'pundit'
          raise Pundit::NotAuthorizedError
        when 'not_found'
          raise ActiveRecord::RecordNotFound
        when 'missing_template'
          raise ActionView::MissingTemplate.new([], 'test', [], false, 'html')
        when 'standard'
          raise StandardError, 'test error'
        else
          render plain: 'success'
        end
      end
    end

    context 'in development environment' do
      before { allow(Rails.env).to receive(:production?).and_return(false) }

      it 'raises Pundit::NotAuthorizedError' do
        expect do
          get :index, params: { error_type: 'pundit' }
        end.to raise_error(Pundit::NotAuthorizedError)
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          get :index, params: { error_type: 'not_found' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises ActionView::MissingTemplate' do
        expect do
          get :index, params: { error_type: 'missing_template' }
        end.to raise_error(ActionView::MissingTemplate)
      end

      it 'raises StandardError' do
        expect do
          get :index, params: { error_type: 'standard' }
        end.to raise_error(StandardError)
      end
    end

    context 'in production environment' do
      before { allow(Rails.env).to receive(:production?).and_return(true) }

      it 'handles Pundit::NotAuthorizedError gracefully' do
        expect do
          get :index, params: { error_type: 'pundit' }
        end.not_to raise_error
      end

      it 'handles ActiveRecord::RecordNotFound gracefully' do
        expect do
          get :index, params: { error_type: 'not_found' }
        end.not_to raise_error
      end

      it 'handles ActionView::MissingTemplate gracefully' do
        expect do
          get :index, params: { error_type: 'missing_template' }
        end.not_to raise_error
      end

      it 'handles StandardError gracefully' do
        expect do
          get :index, params: { error_type: 'standard' }
        end.not_to raise_error
      end
    end
  end

  describe 'CSRF protection' do
    it 'protects from forgery with exception' do
      expect(controller.class.forgery_protection_strategy).to eq(ActionController::RequestForgeryProtection::ProtectionMethods::Exception)
    end
  end
end
