 #auto_require: _esramda
import {$} from "ramda-extras" #auto_require: esramda-extras

# # Uncomment to generate & comment out import countries in sharedUtils - but comment away not to include
# # since countries-intl.json is heavy and it creates a cyclic dependency
# import clmJson from "country-locale-map/countries-intl.json"
# aliases = {US: ['usa'], GB: ['uk', 'england', 'britan']}
# listStr = 'export countryList = [\n'
# byAlpha2Str = 'cL = countryList\nexport countryByAlpha2 = {'

# allCountries = clmJson
# prioCountries = []
# prioCountries.push $ allCountries, _find _whereEq({alpha2: 'US'})
# prioCountries.push $ allCountries, _find _whereEq({alpha2: 'GB'})
# countriesToUse = [...prioCountries, ...allCountries]
# # countriesToUse = [...prioCountries]
# $ countriesToUse, _addIndex(_forEach) (country, i) ->
# 	{default_locale: locale, currency, name, alpha2} = country
# 	curStr = null

# 	nbs = ' ' # non-breaking space
# 	opts = {style: 'currency', currency, minimumFractionDigits: 0, maximumFractionDigits: 0}
# 	curStr = new Intl.NumberFormat(locale, opts).format(1)
# 	currencySymbol = $ curStr, _replace('1', ''), _replace(nbs, '')

# 	extra = ''
# 	if currencySymbol != currency then extra += ", currencySymbol: \"#{currencySymbol}\""
# 	if aliases[country.alpha2] then extra += ", alias: #{sf0 aliases[country.alpha2]}"

# 	listStr += "\t{name: \"#{name}\", alpha2: '#{country.alpha2}', locale: '#{locale}',
# 	currency: '#{currency}'#{extra}}\n"
# 	byAlpha2Str += "#{alpha2}: cL[#{i}], "
# 	if i % 8 == 0 then byAlpha2Str += "\n"

# 	return null

# listStr += ']'
# byAlpha2Str += '}'
# console.log listStr + '\n' + byAlpha2Str






# List of all countries for dropdowns or similar.
# You probably want to lazy load this or the component that uses it so it doesn't add to bundle size
export countryList = [
	{name: "United States", alpha2: 'US', locale: 'en-US', currency: 'USD', currencySymbol: "$", alias: ["usa"]}
	{name: "United Kingdom", alpha2: 'GB', locale: 'en-GB', currency: 'GBP', currencySymbol: "£", alias: ["uk","england","britan"]}
	{name: "Afghanistan", alpha2: 'AF', locale: 'ps-AF', currency: 'AFN'}
	{name: "Albania", alpha2: 'AL', locale: 'sq-AL', currency: 'ALL'}
	{name: "Algeria", alpha2: 'DZ', locale: 'ar-DZ', currency: 'DZD', currencySymbol: "‏د.ج.‏"}
	{name: "American Samoa", alpha2: 'AS', locale: 'en-AS', currency: 'USD', currencySymbol: "$"}
	{name: "Andorra", alpha2: 'AD', locale: 'ca', currency: 'EUR', currencySymbol: "€"}
	{name: "Angola", alpha2: 'AO', locale: 'pt', currency: 'AOA'}
	{name: "Anguilla", alpha2: 'AI', locale: 'en', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Antarctica", alpha2: 'AQ', locale: 'en-US', currency: 'USD', currencySymbol: "$"}
	{name: "Antigua and Barbuda", alpha2: 'AG', locale: 'en', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Argentina", alpha2: 'AR', locale: 'es-AR', currency: 'ARS', currencySymbol: "$"}
	{name: "Armenia", alpha2: 'AM', locale: 'hy-AM', currency: 'AMD'}
	{name: "Aruba", alpha2: 'AW', locale: 'nl', currency: 'AWG'}
	{name: "Australia", alpha2: 'AU', locale: 'en-AU', currency: 'AUD', currencySymbol: "$"}
	{name: "Austria", alpha2: 'AT', locale: 'de-AT', currency: 'EUR', currencySymbol: "€"}
	{name: "Azerbaijan", alpha2: 'AZ', locale: 'az-Cyrl-AZ', currency: 'AZN'}
	{name: "Bahamas", alpha2: 'BS', locale: 'en', currency: 'BSD'}
	{name: "Bahrain", alpha2: 'BH', locale: 'ar-BH', currency: 'BHD', currencySymbol: "‏١د.ب.‏"}
	{name: "Bangladesh", alpha2: 'BD', locale: 'bn-BD', currency: 'BDT', currencySymbol: "১৳"}
	{name: "Barbados", alpha2: 'BB', locale: 'en', currency: 'BBD'}
	{name: "Belarus", alpha2: 'BY', locale: 'be-BY', currency: 'BYN'}
	{name: "Belgium", alpha2: 'BE', locale: 'nl-BE', currency: 'EUR', currencySymbol: "€"}
	{name: "Belize", alpha2: 'BZ', locale: 'en-BZ', currency: 'BZD', currencySymbol: "$"}
	{name: "Benin", alpha2: 'BJ', locale: 'fr-BJ', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Bermuda", alpha2: 'BM', locale: 'en', currency: 'BMD'}
	{name: "Bhutan", alpha2: 'BT', locale: 'dz', currency: 'BTN'}
	{name: "Bolivia", alpha2: 'BO', locale: 'es-BO', currency: 'BTN'}
	{name: "Bonaire", alpha2: 'BQ', locale: 'nl', currency: 'USD', currencySymbol: "US$"}
	{name: "Bosnia and Herzegovina", alpha2: 'BA', locale: 'bs-BA', currency: 'BAM'}
	{name: "Botswana", alpha2: 'BW', locale: 'en-BW', currency: 'BWP', currencySymbol: "P"}
	{name: "Bouvet Island", alpha2: 'BV', locale: 'no', currency: 'NOK', currencySymbol: "kr"}
	{name: "Brazil", alpha2: 'BR', locale: 'pt-BR', currency: 'BRL', currencySymbol: "R$"}
	{name: "British Indian Ocean Territory", alpha2: 'IO', locale: 'en', currency: 'USD', currencySymbol: "$"}
	{name: "Brunei Darussalam", alpha2: 'BN', locale: 'ms-BN', currency: 'BND', currencySymbol: "$"}
	{name: "Bulgaria", alpha2: 'BG', locale: 'bg-BG', currency: 'BGN', currencySymbol: "лв."}
	{name: "Burkina Faso", alpha2: 'BF', locale: 'fr-BF', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Burundi", alpha2: 'BI', locale: 'fr-BI', currency: 'BIF', currencySymbol: "FBu"}
	{name: "Cabo Verde", alpha2: 'CV', locale: 'kea-CV', currency: 'CVE'}
	{name: "Cambodia", alpha2: 'KH', locale: 'km-KH', currency: 'KHR'}
	{name: "Cameroon", alpha2: 'CM', locale: 'fr-CM', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Canada", alpha2: 'CA', locale: 'en-CA', currency: 'CAD', currencySymbol: "$"}
	{name: "Cayman Islands", alpha2: 'KY', locale: 'en', currency: 'KYD'}
	{name: "Central African Republic", alpha2: 'CF', locale: 'fr-CF', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Chad", alpha2: 'TD', locale: 'fr-TD', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Chile", alpha2: 'CL', locale: 'es-CL', currency: 'CLF'}
	{name: "China", alpha2: 'CN', locale: 'zh-CN', currency: 'CNY', currencySymbol: "¥"}
	{name: "Christmas Island", alpha2: 'CX', locale: 'en', currency: 'AUD', currencySymbol: "A$"}
	{name: "Cocos Islands", alpha2: 'CC', locale: 'en', currency: 'AUD', currencySymbol: "A$"}
	{name: "Colombia", alpha2: 'CO', locale: 'es-CO', currency: 'COU'}
	{name: "Comoros", alpha2: 'KM', locale: 'fr-KM', currency: 'KMF', currencySymbol: "CF"}
	{name: "Democratic Republic of the Congo", alpha2: 'CD', locale: 'fr-CD', currency: 'CDF', currencySymbol: "FC"}
	{name: "Congo", alpha2: 'CG', locale: 'fr-CG', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Cook Islands", alpha2: 'CK', locale: 'en', currency: 'NZD', currencySymbol: "NZ$"}
	{name: "Costa Rica", alpha2: 'CR', locale: 'es-CR', currency: 'CRC', currencySymbol: "₡"}
	{name: "Croatia", alpha2: 'HR', locale: 'hr-HR', currency: 'HRK', currencySymbol: "kn"}
	{name: "Cuba", alpha2: 'CU', locale: 'es', currency: 'CUC'}
	{name: "Curaçao", alpha2: 'CW', locale: 'nl', currency: 'ANG'}
	{name: "Cyprus", alpha2: 'CY', locale: 'el-CY', currency: 'EUR', currencySymbol: "€"}
	{name: "Czechia", alpha2: 'CZ', locale: 'cs-CZ', currency: 'CZK', currencySymbol: "Kč"}
	{name: "Côte d'Ivoire", alpha2: 'CI', locale: 'fr-CI', currency: 'CZK'}
	{name: "Denmark", alpha2: 'DK', locale: 'da-DK', currency: 'DKK', currencySymbol: "kr."}
	{name: "Djibouti", alpha2: 'DJ', locale: 'fr-DJ', currency: 'DJF', currencySymbol: "Fdj"}
	{name: "Dominica", alpha2: 'DM', locale: 'en', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Dominican Republic", alpha2: 'DO', locale: 'es-DO', currency: 'DOP', currencySymbol: "RD$"}
	{name: "Ecuador", alpha2: 'EC', locale: 'es-EC', currency: 'USD', currencySymbol: "$"}
	{name: "Egypt", alpha2: 'EG', locale: 'ar-EG', currency: 'EGP', currencySymbol: "‏١ج.م.‏"}
	{name: "El Salvador", alpha2: 'SV', locale: 'es-SV', currency: 'USD', currencySymbol: "$"}
	{name: "Equatorial Guinea", alpha2: 'GQ', locale: 'fr-GQ', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Eritrea", alpha2: 'ER', locale: 'ti-ER', currency: 'ERN'}
	{name: "Estonia", alpha2: 'EE', locale: 'et-EE', currency: 'EUR', currencySymbol: "€"}
	{name: "Eswatini", alpha2: 'SZ', locale: 'en', currency: 'EUR', currencySymbol: "€"}
	{name: "Ethiopia", alpha2: 'ET', locale: 'am-ET', currency: 'ETB', currencySymbol: "ብር"}
	{name: "Falkland Islands", alpha2: 'FK', locale: 'en', currency: 'DKK'}
	{name: "Faroe Islands", alpha2: 'FO', locale: 'fo-FO', currency: 'DKK'}
	{name: "Fiji", alpha2: 'FJ', locale: 'en', currency: 'FJD'}
	{name: "Finland", alpha2: 'FI', locale: 'fi-FI', currency: 'EUR', currencySymbol: "€"}
	{name: "France", alpha2: 'FR', locale: 'fr-FR', currency: 'EUR', currencySymbol: "€"}
	{name: "French Guiana", alpha2: 'GF', locale: 'fr', currency: 'EUR', currencySymbol: "€"}
	{name: "French Polynesia", alpha2: 'PF', locale: 'fr', currency: 'XPF', currencySymbol: "FCFP"}
	{name: "French Southern Territories", alpha2: 'TF', locale: 'fr', currency: 'EUR', currencySymbol: "€"}
	{name: "Gabon", alpha2: 'GA', locale: 'fr-GA', currency: 'XAF', currencySymbol: "FCFA"}
	{name: "Gambia", alpha2: 'GM', locale: 'en', currency: 'GMD'}
	{name: "Georgia", alpha2: 'GE', locale: 'ka-GE', currency: 'GEL'}
	{name: "Germany", alpha2: 'DE', locale: 'de-DE', currency: 'EUR', currencySymbol: "€"}
	{name: "Ghana", alpha2: 'GH', locale: 'ak-GH', currency: 'GHS'}
	{name: "Gibraltar", alpha2: 'GI', locale: 'en', currency: 'GIP'}
	{name: "Greece", alpha2: 'GR', locale: 'el-GR', currency: 'EUR', currencySymbol: "€"}
	{name: "Greenland", alpha2: 'GL', locale: 'kl-GL', currency: 'DKK'}
	{name: "Grenada", alpha2: 'GD', locale: 'en', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Guadeloupe", alpha2: 'GP', locale: 'fr-GP', currency: 'EUR', currencySymbol: "€"}
	{name: "Guam", alpha2: 'GU', locale: 'en-GU', currency: 'USD', currencySymbol: "$"}
	{name: "Guatemala", alpha2: 'GT', locale: 'es-GT', currency: 'GTQ', currencySymbol: "Q"}
	{name: "Guernsey", alpha2: 'GG', locale: 'en', currency: 'GBP', currencySymbol: "£"}
	{name: "Guinea", alpha2: 'GN', locale: 'fr-GN', currency: 'GNF', currencySymbol: "FG"}
	{name: "Guinea-Bissau", alpha2: 'GW', locale: 'pt-GW', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Guyana", alpha2: 'GY', locale: 'en', currency: 'GYD'}
	{name: "Haiti", alpha2: 'HT', locale: 'fr', currency: 'USD', currencySymbol: "$US"}
	{name: "Heard Island and McDonald Islands", alpha2: 'HM', locale: 'en', currency: 'AUD', currencySymbol: "A$"}
	{name: "Holy See", alpha2: 'VA', locale: 'it', currency: 'EUR', currencySymbol: "€"}
	{name: "Honduras", alpha2: 'HN', locale: 'es-HN', currency: 'HNL', currencySymbol: "L"}
	{name: "Hong Kong", alpha2: 'HK', locale: 'en-HK', currency: 'HKD', currencySymbol: "HK$"}
	{name: "Hungary", alpha2: 'HU', locale: 'hu-HU', currency: 'HUF', currencySymbol: "Ft"}
	{name: "Iceland", alpha2: 'IS', locale: 'is-IS', currency: 'ISK'}
	{name: "India", alpha2: 'IN', locale: 'hi-IN', currency: 'INR', currencySymbol: "₹"}
	{name: "Indonesia", alpha2: 'ID', locale: 'id-ID', currency: 'IDR', currencySymbol: "Rp"}
	{name: "Iran", alpha2: 'IR', locale: 'fa-IR', currency: 'XDR', currencySymbol: "‎XDR۱"}
	{name: "Iraq", alpha2: 'IQ', locale: 'ar-IQ', currency: 'IQD', currencySymbol: "‏١د.ع.‏"}
	{name: "Ireland", alpha2: 'IE', locale: 'en-IE', currency: 'EUR', currencySymbol: "€"}
	{name: "Isle of Man", alpha2: 'IM', locale: 'en', currency: 'GBP', currencySymbol: "£"}
	{name: "Israel", alpha2: 'IL', locale: 'he-IL', currency: 'ILS', currencySymbol: "‏‏₪"}
	{name: "Italy", alpha2: 'IT', locale: 'it-IT', currency: 'EUR', currencySymbol: "€"}
	{name: "Jamaica", alpha2: 'JM', locale: 'en-JM', currency: 'JMD', currencySymbol: "$"}
	{name: "Japan", alpha2: 'JP', locale: 'ja-JP', currency: 'JPY', currencySymbol: "￥"}
	{name: "Jersey", alpha2: 'JE', locale: 'en', currency: 'GBP', currencySymbol: "£"}
	{name: "Jordan", alpha2: 'JO', locale: 'ar-JO', currency: 'JOD', currencySymbol: "‏١د.أ.‏"}
	{name: "Kazakhstan", alpha2: 'KZ', locale: 'kk-Cyrl-KZ', currency: 'KZT'}
	{name: "Kenya", alpha2: 'KE', locale: 'ebu-KE', currency: 'KES'}
	{name: "Kiribati", alpha2: 'KI', locale: 'en', currency: 'AUD', currencySymbol: "A$"}
	{name: "North Korea", alpha2: 'KP', locale: 'ko', currency: 'KPW'}
	{name: "South Korea", alpha2: 'KR', locale: 'ko-KR', currency: 'KRW', currencySymbol: "₩"}
	{name: "Kuwait", alpha2: 'KW', locale: 'ar-KW', currency: 'KWD', currencySymbol: "‏١د.ك.‏"}
	{name: "Kyrgyzstan", alpha2: 'KG', locale: 'ky', currency: 'KGS'}
	{name: "Lao People's Democratic Republic", alpha2: 'LA', locale: 'lo', currency: 'LAK'}
	{name: "Latvia", alpha2: 'LV', locale: 'lv-LV', currency: 'EUR', currencySymbol: "€"}
	{name: "Lebanon", alpha2: 'LB', locale: 'ar-LB', currency: 'LBP', currencySymbol: "‏١ل.ل.‏"}
	{name: "Lesotho", alpha2: 'LS', locale: 'en', currency: 'ZAR'}
	{name: "Liberia", alpha2: 'LR', locale: 'en', currency: 'LRD'}
	{name: "Libya", alpha2: 'LY', locale: 'ar-LY', currency: 'LYD', currencySymbol: "‏د.ل.‏"}
	{name: "Liechtenstein", alpha2: 'LI', locale: 'de-LI', currency: 'CHF'}
	{name: "Lithuania", alpha2: 'LT', locale: 'lt-LT', currency: 'EUR', currencySymbol: "€"}
	{name: "Luxembourg", alpha2: 'LU', locale: 'fr-LU', currency: 'EUR', currencySymbol: "€"}
	{name: "Macao", alpha2: 'MO', locale: 'zh-Hans-MO', currency: 'MOP', currencySymbol: "MOP$"}
	{name: "Madagascar", alpha2: 'MG', locale: 'fr-MG', currency: 'MGA', currencySymbol: "Ar"}
	{name: "Malawi", alpha2: 'MW', locale: 'en', currency: 'MWK'}
	{name: "Malaysia", alpha2: 'MY', locale: 'ms-MY', currency: 'MYR', currencySymbol: "RM"}
	{name: "Maldives", alpha2: 'MV', locale: 'dv', currency: 'MVR'}
	{name: "Mali", alpha2: 'ML', locale: 'fr-ML', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Malta", alpha2: 'MT', locale: 'en-MT', currency: 'EUR', currencySymbol: "€"}
	{name: "Marshall Islands", alpha2: 'MH', locale: 'en-MH', currency: 'USD', currencySymbol: "$"}
	{name: "Martinique", alpha2: 'MQ', locale: 'fr-MQ', currency: 'EUR', currencySymbol: "€"}
	{name: "Mauritania", alpha2: 'MR', locale: 'ar', currency: 'MRU', currencySymbol: "‏أ.م."}
	{name: "Mauritius", alpha2: 'MU', locale: 'en-MU', currency: 'MUR', currencySymbol: "Rs"}
	{name: "Mayotte", alpha2: 'YT', locale: 'fr', currency: 'EUR', currencySymbol: "€"}
	{name: "Mexico", alpha2: 'MX', locale: 'es-MX', currency: 'MXV'}
	{name: "Micronesia", alpha2: 'FM', locale: 'en', currency: 'RUB'}
	{name: "Moldova", alpha2: 'MD', locale: 'ro-MD', currency: 'MDL', currencySymbol: "L"}
	{name: "Monaco", alpha2: 'MC', locale: 'fr-MC', currency: 'EUR', currencySymbol: "€"}
	{name: "Mongolia", alpha2: 'MN', locale: 'mn', currency: 'MNT'}
	{name: "Montenegro", alpha2: 'ME', locale: 'sr-Cyrl-ME', currency: 'EUR', currencySymbol: "€"}
	{name: "Montserrat", alpha2: 'MS', locale: 'en', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Morocco", alpha2: 'MA', locale: 'ar-MA', currency: 'MAD', currencySymbol: "‏د.م.‏"}
	{name: "Mozambique", alpha2: 'MZ', locale: 'pt-MZ', currency: 'MZN', currencySymbol: "MTn"}
	{name: "Myanmar", alpha2: 'MM', locale: 'my-MM', currency: 'MMK'}
	{name: "Namibia", alpha2: 'NA', locale: 'en-NA', currency: 'ZAR'}
	{name: "Nauru", alpha2: 'NR', locale: 'en', currency: 'AUD', currencySymbol: "A$"}
	{name: "Nepal", alpha2: 'NP', locale: 'ne-NP', currency: 'NPR'}
	{name: "Netherlands", alpha2: 'NL', locale: 'nl-NL', currency: 'EUR', currencySymbol: "€"}
	{name: "New Caledonia", alpha2: 'NC', locale: 'fr', currency: 'XPF', currencySymbol: "FCFP"}
	{name: "New Zealand", alpha2: 'NZ', locale: 'en-NZ', currency: 'NZD', currencySymbol: "$"}
	{name: "Nicaragua", alpha2: 'NI', locale: 'es-NI', currency: 'NIO', currencySymbol: "C$"}
	{name: "Niger", alpha2: 'NE', locale: 'fr-NE', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Nigeria", alpha2: 'NG', locale: 'ha-Latn-NG', currency: 'NGN'}
	{name: "Niue", alpha2: 'NU', locale: 'en', currency: 'NZD', currencySymbol: "NZ$"}
	{name: "Norfolk Island", alpha2: 'NF', locale: 'en', currency: 'AUD', currencySymbol: "A$"}
	{name: "North Macedonia", alpha2: 'MK', locale: 'mk-MK', currency: 'AUD', currencySymbol: "A$"}
	{name: "Northern Mariana Islands", alpha2: 'MP', locale: 'en-MP', currency: 'USD', currencySymbol: "$"}
	{name: "Norway", alpha2: 'NO', locale: 'nb-NO', currency: 'NOK', currencySymbol: "kr"}
	{name: "Oman", alpha2: 'OM', locale: 'ar-OM', currency: 'OMR', currencySymbol: "‏١ر.ع.‏"}
	{name: "Pakistan", alpha2: 'PK', locale: 'en-PK', currency: 'PKR', currencySymbol: "Rs"}
	{name: "Palau", alpha2: 'PW', locale: 'en', currency: 'USD', currencySymbol: "$"}
	{name: "Palestine", alpha2: 'PS', locale: 'ar', currency: 'USD', currencySymbol: "‏US$"}
	{name: "Panama", alpha2: 'PA', locale: 'es-PA', currency: 'USD'}
	{name: "Papua New Guinea", alpha2: 'PG', locale: 'en', currency: 'PGK'}
	{name: "Paraguay", alpha2: 'PY', locale: 'es-PY', currency: 'PYG', currencySymbol: "Gs."}
	{name: "Peru", alpha2: 'PE', locale: 'es-PE', currency: 'PEN', currencySymbol: "S/"}
	{name: "Philippines", alpha2: 'PH', locale: 'en-PH', currency: 'PHP', currencySymbol: "₱"}
	{name: "Pitcairn", alpha2: 'PN', locale: 'en', currency: 'NZD', currencySymbol: "NZ$"}
	{name: "Poland", alpha2: 'PL', locale: 'pl-PL', currency: 'PLN', currencySymbol: "zł"}
	{name: "Portugal", alpha2: 'PT', locale: 'pt-PT', currency: 'EUR', currencySymbol: "€"}
	{name: "Puerto Rico", alpha2: 'PR', locale: 'es-PR', currency: 'USD', currencySymbol: "$"}
	{name: "Qatar", alpha2: 'QA', locale: 'ar-QA', currency: 'QAR', currencySymbol: "‏١ر.ق.‏"}
	{name: "Romania", alpha2: 'RO', locale: 'ro-RO', currency: 'RON'}
	{name: "Russia", alpha2: 'RU', locale: 'ru-RU', currency: 'RUB', currencySymbol: "₽"}
	{name: "Rwanda", alpha2: 'RW', locale: 'fr-RW', currency: 'RWF', currencySymbol: "RF"}
	{name: "Réunion", alpha2: 'RE', locale: 'fr-RE', currency: 'RWF'}
	{name: "Saint Barthélemy", alpha2: 'BL', locale: 'fr-BL', currency: 'EUR', currencySymbol: "€"}
	{name: "Saint Helena", alpha2: 'SH', locale: 'en', currency: 'SHP'}
	{name: "Saint Kitts and Nevis", alpha2: 'KN', locale: 'en', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Saint Lucia", alpha2: 'LC', locale: 'en', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Saint Martin", alpha2: 'MF', locale: 'fr-MF', currency: 'EUR', currencySymbol: "€"}
	{name: "Saint Pierre and Miquelon", alpha2: 'PM', locale: 'fr', currency: 'EUR', currencySymbol: "€"}
	{name: "Saint Vincent and the Grenadines", alpha2: 'VC', locale: 'en', currency: 'XCD', currencySymbol: "EC$"}
	{name: "Samoa", alpha2: 'WS', locale: 'sm', currency: 'WST'}
	{name: "San Marino", alpha2: 'SM', locale: 'it', currency: 'EUR', currencySymbol: "€"}
	{name: "Sao Tome and Principe", alpha2: 'ST', locale: 'pt', currency: 'STN'}
	{name: "Saudi Arabia", alpha2: 'SA', locale: 'ar-SA', currency: 'SAR', currencySymbol: "‏١ر.س.‏"}
	{name: "Senegal", alpha2: 'SN', locale: 'fr-SN', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Serbia", alpha2: 'RS', locale: 'sr-Cyrl-RS', currency: 'RSD'}
	{name: "Seychelles", alpha2: 'SC', locale: 'fr', currency: 'SCR'}
	{name: "Sierra Leone", alpha2: 'SL', locale: 'en', currency: 'SLL'}
	{name: "Singapore", alpha2: 'SG', locale: 'en-SG', currency: 'SGD', currencySymbol: "$"}
	{name: "Sint Maarten", alpha2: 'SX', locale: 'nl', currency: 'ANG'}
	{name: "Slovakia", alpha2: 'SK', locale: 'sk-SK', currency: 'EUR', currencySymbol: "€"}
	{name: "Slovenia", alpha2: 'SI', locale: 'sl-SI', currency: 'EUR', currencySymbol: "€"}
	{name: "Solomon Islands", alpha2: 'SB', locale: 'en', currency: 'SBD'}
	{name: "Somalia", alpha2: 'SO', locale: 'so-SO', currency: 'SOS'}
	{name: "South Africa", alpha2: 'ZA', locale: 'af-ZA', currency: 'ZAR', currencySymbol: "R"}
	{name: "South Georgia and the South Sandwich Islands", alpha2: 'GS', locale: 'en', currency: 'USD', currencySymbol: "$"}
	{name: "South Sudan", alpha2: 'SS', locale: 'en', currency: 'SSP'}
	{name: "Spain", alpha2: 'ES', locale: 'es-ES', currency: 'EUR', currencySymbol: "€"}
	{name: "Sri Lanka", alpha2: 'LK', locale: 'si-LK', currency: 'LKR'}
	{name: "Sudan", alpha2: 'SD', locale: 'ar-SD', currency: 'SDG', currencySymbol: "‏١ج.س."}
	{name: "Suriname", alpha2: 'SR', locale: 'nl', currency: 'SRD'}
	{name: "Svalbard and Jan Mayen", alpha2: 'SJ', locale: 'no', currency: 'NOK', currencySymbol: "kr"}
	{name: "Sweden", alpha2: 'SE', locale: 'sv-SE', currency: 'SEK', currencySymbol: "kr"}
	{name: "Switzerland", alpha2: 'CH', locale: 'fr-CH', currency: 'CHW'}
	{name: "Syrian Arab Republic", alpha2: 'SY', locale: 'ar-SY', currency: 'SYP', currencySymbol: "‏١ل.س.‏"}
	{name: "Taiwan", alpha2: 'TW', locale: 'zh-Hant-TW', currency: 'TWD', currencySymbol: "$"}
	{name: "Tajikistan", alpha2: 'TJ', locale: 'tg', currency: 'TJS'}
	{name: "Tanzania", alpha2: 'TZ', locale: 'asa-TZ', currency: 'TZS'}
	{name: "Thailand", alpha2: 'TH', locale: 'th-TH', currency: 'THB', currencySymbol: "฿"}
	{name: "Timor-Leste", alpha2: 'TL', locale: 'pt', currency: 'USD', currencySymbol: "US$"}
	{name: "Togo", alpha2: 'TG', locale: 'fr-TG', currency: 'XOF', currencySymbol: "F CFA"}
	{name: "Tokelau", alpha2: 'TK', locale: 'en', currency: 'NZD', currencySymbol: "NZ$"}
	{name: "Tonga", alpha2: 'TO', locale: 'to-TO', currency: 'TOP'}
	{name: "Trinidad and Tobago", alpha2: 'TT', locale: 'en-TT', currency: 'TTD', currencySymbol: "$"}
	{name: "Tunisia", alpha2: 'TN', locale: 'ar-TN', currency: 'TND', currencySymbol: "‏د.ت.‏"}
	{name: "Turkey", alpha2: 'TR', locale: 'tr-TR', currency: 'TRY', currencySymbol: "₺"}
	{name: "Turkmenistan", alpha2: 'TM', locale: 'tk', currency: 'TMT'}
	{name: "Turks and Caicos Islands", alpha2: 'TC', locale: 'en', currency: 'USD', currencySymbol: "$"}
	{name: "Tuvalu", alpha2: 'TV', locale: 'en', currency: 'AUD', currencySymbol: "A$"}
	{name: "Uganda", alpha2: 'UG', locale: 'cgg-UG', currency: 'UGX'}
	{name: "Ukraine", alpha2: 'UA', locale: 'uk-UA', currency: 'UAH', currencySymbol: "грн"}
	{name: "United Arab Emirates", alpha2: 'AE', locale: 'ar-AE', currency: 'AED', currencySymbol: "‏د.إ.‏"}
	{name: "United Kingdom", alpha2: 'GB', locale: 'en-GB', currency: 'GBP', currencySymbol: "£", alias: ["uk","england","britan"]}
	{name: "United States Minor Outlying Islands", alpha2: 'UM', locale: 'en-UM', currency: 'USD', currencySymbol: "$"}
	{name: "United States", alpha2: 'US', locale: 'en-US', currency: 'USD', currencySymbol: "$", alias: ["usa"]}
	{name: "Uruguay", alpha2: 'UY', locale: 'es-UY', currency: 'UYW'}
	{name: "Uzbekistan", alpha2: 'UZ', locale: 'uz-Cyrl-UZ', currency: 'UZS'}
	{name: "Vanuatu", alpha2: 'VU', locale: 'bi', currency: 'VUV'}
	{name: "Venezuela", alpha2: 'VE', locale: 'es-VE', currency: 'VUV'}
	{name: "Viet Nam", alpha2: 'VN', locale: 'vi-VN', currency: 'VND', currencySymbol: "₫"}
	{name: "Virgin Islands (British)", alpha2: 'VG', locale: 'en', currency: 'USD', currencySymbol: "$"}
	{name: "Virgin Islands (U.S.)", alpha2: 'VI', locale: 'en-VI', currency: 'USD', currencySymbol: "$"}
	{name: "Wallis and Futuna", alpha2: 'WF', locale: 'fr', currency: 'XPF', currencySymbol: "FCFP"}
	{name: "Western Sahara", alpha2: 'EH', locale: 'es', currency: 'MAD'}
	{name: "Yemen", alpha2: 'YE', locale: 'ar-YE', currency: 'YER', currencySymbol: "‏١ر.ي.‏"}
	{name: "Zambia", alpha2: 'ZM', locale: 'bem-ZM', currency: 'ZMW'}
	{name: "Zimbabwe", alpha2: 'ZW', locale: 'en-ZW', currency: 'ZWL'}
	{name: "Åland Islands", alpha2: 'AX', locale: 'sv', currency: 'EUR', currencySymbol: "€"}
]
cL = countryList
export countryByAlpha2 = {US: cL[0], 
GB: cL[1], AF: cL[2], AL: cL[3], DZ: cL[4], AS: cL[5], AD: cL[6], AO: cL[7], AI: cL[8], 
AQ: cL[9], AG: cL[10], AR: cL[11], AM: cL[12], AW: cL[13], AU: cL[14], AT: cL[15], AZ: cL[16], 
BS: cL[17], BH: cL[18], BD: cL[19], BB: cL[20], BY: cL[21], BE: cL[22], BZ: cL[23], BJ: cL[24], 
BM: cL[25], BT: cL[26], BO: cL[27], BQ: cL[28], BA: cL[29], BW: cL[30], BV: cL[31], BR: cL[32], 
IO: cL[33], BN: cL[34], BG: cL[35], BF: cL[36], BI: cL[37], CV: cL[38], KH: cL[39], CM: cL[40], 
CA: cL[41], KY: cL[42], CF: cL[43], TD: cL[44], CL: cL[45], CN: cL[46], CX: cL[47], CC: cL[48], 
CO: cL[49], KM: cL[50], CD: cL[51], CG: cL[52], CK: cL[53], CR: cL[54], HR: cL[55], CU: cL[56], 
CW: cL[57], CY: cL[58], CZ: cL[59], CI: cL[60], DK: cL[61], DJ: cL[62], DM: cL[63], DO: cL[64], 
EC: cL[65], EG: cL[66], SV: cL[67], GQ: cL[68], ER: cL[69], EE: cL[70], SZ: cL[71], ET: cL[72], 
FK: cL[73], FO: cL[74], FJ: cL[75], FI: cL[76], FR: cL[77], GF: cL[78], PF: cL[79], TF: cL[80], 
GA: cL[81], GM: cL[82], GE: cL[83], DE: cL[84], GH: cL[85], GI: cL[86], GR: cL[87], GL: cL[88], 
GD: cL[89], GP: cL[90], GU: cL[91], GT: cL[92], GG: cL[93], GN: cL[94], GW: cL[95], GY: cL[96], 
HT: cL[97], HM: cL[98], VA: cL[99], HN: cL[100], HK: cL[101], HU: cL[102], IS: cL[103], IN: cL[104], 
ID: cL[105], IR: cL[106], IQ: cL[107], IE: cL[108], IM: cL[109], IL: cL[110], IT: cL[111], JM: cL[112], 
JP: cL[113], JE: cL[114], JO: cL[115], KZ: cL[116], KE: cL[117], KI: cL[118], KP: cL[119], KR: cL[120], 
KW: cL[121], KG: cL[122], LA: cL[123], LV: cL[124], LB: cL[125], LS: cL[126], LR: cL[127], LY: cL[128], 
LI: cL[129], LT: cL[130], LU: cL[131], MO: cL[132], MG: cL[133], MW: cL[134], MY: cL[135], MV: cL[136], 
ML: cL[137], MT: cL[138], MH: cL[139], MQ: cL[140], MR: cL[141], MU: cL[142], YT: cL[143], MX: cL[144], 
FM: cL[145], MD: cL[146], MC: cL[147], MN: cL[148], ME: cL[149], MS: cL[150], MA: cL[151], MZ: cL[152], 
MM: cL[153], NA: cL[154], NR: cL[155], NP: cL[156], NL: cL[157], NC: cL[158], NZ: cL[159], NI: cL[160], 
NE: cL[161], NG: cL[162], NU: cL[163], NF: cL[164], MK: cL[165], MP: cL[166], NO: cL[167], OM: cL[168], 
PK: cL[169], PW: cL[170], PS: cL[171], PA: cL[172], PG: cL[173], PY: cL[174], PE: cL[175], PH: cL[176], 
PN: cL[177], PL: cL[178], PT: cL[179], PR: cL[180], QA: cL[181], RO: cL[182], RU: cL[183], RW: cL[184], 
RE: cL[185], BL: cL[186], SH: cL[187], KN: cL[188], LC: cL[189], MF: cL[190], PM: cL[191], VC: cL[192], 
WS: cL[193], SM: cL[194], ST: cL[195], SA: cL[196], SN: cL[197], RS: cL[198], SC: cL[199], SL: cL[200], 
SG: cL[201], SX: cL[202], SK: cL[203], SI: cL[204], SB: cL[205], SO: cL[206], ZA: cL[207], GS: cL[208], 
SS: cL[209], ES: cL[210], LK: cL[211], SD: cL[212], SR: cL[213], SJ: cL[214], SE: cL[215], CH: cL[216], 
SY: cL[217], TW: cL[218], TJ: cL[219], TZ: cL[220], TH: cL[221], TL: cL[222], TG: cL[223], TK: cL[224], 
TO: cL[225], TT: cL[226], TN: cL[227], TR: cL[228], TM: cL[229], TC: cL[230], TV: cL[231], UG: cL[232], 
UA: cL[233], AE: cL[234], GB: cL[235], UM: cL[236], US: cL[237], UY: cL[238], UZ: cL[239], VU: cL[240], 
VE: cL[241], VN: cL[242], VG: cL[243], VI: cL[244], WF: cL[245], EH: cL[246], YE: cL[247], ZM: cL[248], 
ZW: cL[249], AX: cL[250]}