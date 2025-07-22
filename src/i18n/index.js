import { createI18n } from 'vue-i18n'
import tr from '../locales/tr.json'
import en from '../locales/en.json'

const messages = {
  tr,
  en
}

const i18n = createI18n({
  locale: localStorage.getItem('locale') || 'tr',
  fallbackLocale: 'tr',
  messages
})

export default i18n
